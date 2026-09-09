"""Offline teaching example. No LLM, network, real identity, or real dispatch.

The actor fixture and approval flag are trusted in-process teaching inputs only.
Production must load authorization and durable, payload-bound approvals on the
server and enforce concurrency and idempotency in a transactional datastore.
"""
import copy
import json
from datetime import datetime
from pathlib import Path


def rejection_reasons(vehicle, event, now, freshness_minutes):
    reasons = []
    if vehicle['district_id'] != event['district_id']:
        reasons.append('outside authorized district')
    if event['required_capability'] not in vehicle['capabilities']:
        reasons.append('missing capability')
    if vehicle['state'] != 'idle':
        reasons.append('not idle')
    age = (now - datetime.fromisoformat(vehicle['observed_at'])).total_seconds() / 60
    if not 0 <= age <= freshness_minutes:
        reasons.append('stale or future observation')
    return reasons


def recommend(scenario):
    if not scenario['event']['verified']:
        return {'candidate': None, 'reason': 'event must be verified'}
    now = datetime.fromisoformat(scenario['now'])
    candidates, excluded = [], {}
    for vehicle in scenario['vehicles']:
        reasons = rejection_reasons(vehicle, scenario['event'], now,
                                    scenario['freshness_minutes'])
        if reasons:
            excluded[vehicle['id']] = reasons
        else:
            candidates.append(vehicle)
    selected = min(candidates, key=lambda v: (v['eta_minutes'], v['id'])) if candidates else None
    return {'candidate': copy.deepcopy(selected), 'excluded': excluded,
            'data_time': scenario['now'], 'rule_version': 'teaching-rule-v1'}


class SimulatedDispatcher:
    """Single-process model; deliberately not a production service."""
    def __init__(self, scenario):
        self.scenario = copy.deepcopy(scenario)
        self.by_request = {}
        self.active_event_orders = {}

    def dispatch(self, actor, event_id, vehicle_id, expected_version, key, approved):
        event = self.scenario['event']
        if (not actor or actor.get('role') != 'dispatcher'
                or event['district_id'] not in actor.get('districts', [])):
            raise PermissionError('authorization required')
        payload = (event_id, vehicle_id, expected_version)
        namespace = (actor['id'], key)
        if namespace in self.by_request:
            old_payload, order = self.by_request[namespace]
            if old_payload != payload:
                raise ValueError('idempotency payload conflict')
            return copy.deepcopy(order)
        if not approved:
            raise PermissionError('approval required')
        if event_id != event['id'] or not event['verified']:
            raise ValueError('invalid or unverified event')
        if event_id in self.active_event_orders:
            raise ValueError('event already has an active order')
        vehicle = next((v for v in self.scenario['vehicles'] if v['id'] == vehicle_id), None)
        if vehicle is None:
            raise ValueError('unknown vehicle')
        if vehicle['version'] != expected_version:
            raise ValueError('stale resource version')
        reasons = rejection_reasons(vehicle, event,
                                    datetime.fromisoformat(self.scenario['now']),
                                    self.scenario['freshness_minutes'])
        if reasons:
            raise ValueError(', '.join(reasons))
        # Production needs a transaction/lock across this check and mutation.
        order = {'id': f'SIM-WO-{len(self.by_request)+1:03d}',
                 'event_id': event_id, 'vehicle_id': vehicle_id,
                 'status': 'dispatched', 'simulation': True}
        vehicle['state'] = 'busy'
        vehicle['version'] += 1
        self.active_event_orders[event_id] = order['id']
        self.by_request[namespace] = (payload, copy.deepcopy(order))
        return order


def run_checks(scenario):
    total = 0
    def expect_error(fn, error_type):
        nonlocal total
        try:
            fn()
        except error_type:
            total += 1
            return
        raise AssertionError('expected rejection')
    actor = {'id': 'SIM-USER', 'role': 'dispatcher', 'districts': ['D-01']}
    choice = recommend(scenario)
    assert choice['candidate']['id'] == 'V-02'
    assert set(choice['excluded']) == {'V-01', 'V-03', 'V-04', 'V-05'}
    total += 1
    d = SimulatedDispatcher(scenario)
    expect_error(lambda: d.dispatch(None, 'I-101', 'V-02', 1, 'k1', True), PermissionError)
    expect_error(lambda: d.dispatch({'id':'R','role':'viewer','districts':['D-01']},
                                   'I-101','V-02',1,'k1',True), PermissionError)
    expect_error(lambda: d.dispatch(actor,'I-101','V-02',1,'k1',False), PermissionError)
    expect_error(lambda: d.dispatch(actor,'I-101','V-02',0,'k1',True), ValueError)
    expect_error(lambda: d.dispatch(actor,'I-101','V-04',1,'k1',True), ValueError)
    first = d.dispatch(actor, 'I-101', 'V-02', 1, 'k1', True)
    repeated = d.dispatch(actor, 'I-101', 'V-02', 1, 'k1', True)
    assert first == repeated and len(d.by_request) == 1
    assert first['status'] == 'dispatched'
    total += 1
    expect_error(lambda: d.dispatch(actor,'I-101','V-01',1,'k1',True), ValueError)
    expect_error(lambda: d.dispatch(actor,'I-101','V-02',2,'new-key',True), ValueError)
    changed = copy.deepcopy(scenario)
    changed['event']['verified'] = False
    assert recommend(changed)['candidate'] is None
    total += 1
    for vehicle in changed['vehicles']:
        vehicle['observed_at'] = '2026-09-10T08:00:00+08:00'
    changed['event']['verified'] = True
    assert recommend(changed)['candidate'] is None
    total += 1
    future = copy.deepcopy(scenario)
    future['vehicles'][1]['observed_at'] = '2026-09-10T10:00:00+08:00'
    assert recommend(future)['candidate'] is None
    total += 1
    print(json.dumps({'simulation': True, 'candidate': choice['candidate']['id'],
                      'excluded': choice['excluded'], 'order': first,
                      'checks_passed': total}, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    scenario_path = Path(__file__).with_name('scenario.json')
    run_checks(json.loads(scenario_path.read_text(encoding='utf-8')))
