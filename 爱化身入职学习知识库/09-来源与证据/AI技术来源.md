---
title: AI技术来源
tags: [爱化身, 入职准备, 来源, AI技术, 证据]
created: 2026-09-10
status: 学习中
---

# AI 技术来源与证据说明

[[00-爱化身入职学习地图]]

## 如何使用这些来源

本索引对应 `02-AI技术基础` 的 6 篇教材。网页核实日期：**2026-09-10**。教材采用自己的中文解释、教学架构与虚构环卫案例，结合以下原始论文、官方规范和厂商工程文档。案例字段、价格、数量、流程、Schema、验收表均为学习设计，不能视为原论文实验结果或 Agentrix 的产品事实。

证据分三类：**原始论文**支持机制与原始实验边界；**协议/产品官方文档**支持特定版本接口与约束；**厂商工程文章**提供工程经验，不能当成跨产品必然规律。行业术语、模式建议与案例推演不等于对公司私有实现的核验。

模型名称、价格、上下文窗口、SDK 字段、支持的 Schema 子集和协议版本都可能变化。笔记有意不固化厂商排名和实时价格；真正实施时重查所选模型/SDK/客户端的当前兼容性。MCP 章节固定引用 **2025-11-25 版本**以便学习与追溯，不将它标为最新版本。

## 原理与模型适配

| 来源 | 类型与时间 | 本笔记使用范围 | 不能据此推出 |
|---|---|---|---|
| [Attention Is All You Need](https://arxiv.org/abs/1706.03762) | 原始论文，2017 | Transformer、缩放点积注意力和多头注意力的经典来源 | 所有现代模型都完全采用原版结构；注意力等于事实核验 |
| [Training language models to follow instructions with human feedback](https://arxiv.org/abs/2203.02155) | 原始论文，2022 | 人类示范、监督微调与人类偏好反馈的训练范式 | 对齐后不再犯错；Agentrix 使用相同训练流水线 |
| [LoRA: Low-Rank Adaptation of Large Language Models](https://arxiv.org/abs/2106.09685) | 原始论文，2021 | 冻结预训练权重并训练低秩增量的基本思路 | 微调可以替代企业实时数据接入；原实验收益适用所有模型 |
| [Lost in the Middle: How Language Models Use Long Contexts](https://arxiv.org/abs/2307.03172) | 原始论文，2023 | 长上下文中证据位置可能影响任务表现，需进行实际评测 | 所有后来模型具有相同下降幅度；固定排版适用于所有任务 |

对应笔记：[[AI-01-LLM原理与模型选型]]、[[AI-02-Prompt与上下文工程]]。

## 上下文、检索与结构化输出

| 来源 | 类型与时间 | 本笔记使用范围 | 不能据此推出 |
|---|---|---|---|
| [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | 厂商工程文章，2025-09-29 | 将指令、证据、历史、工具和状态作为整体管理 | 上下文越短永远越好；其经验等于所有模型的固定规律 |
| [Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks](https://arxiv.org/abs/2005.11401) | 原始论文，2020 | 参数模型与外部检索结合的经典机制 | 当代所有 RAG 工程都等于原论文训练结构；检索能消灭幻觉 |
| [Dense Passage Retrieval for Open-Domain Question Answering](https://arxiv.org/abs/2004.04906) | 原始论文，2020 | 使用双编码器进行密集段落检索的机制 | 向量搜索总优于关键词搜索；语义相似就是实体相同 |
| [From Local to Global: A Graph RAG Approach to Query-Focused Summarization](https://arxiv.org/abs/2404.16130) | 原始论文，2024 | 图结构和社区级摘要用于全局总结的具体研究路线 | GraphRAG 与本体相同；所有多跳必须用图；Agentrix 已采用该实现 |
| [pgvector 官方仓库](https://github.com/pgvector/pgvector) | 软件官方文档，动态 | 精确/近似向量检索及过滤行为的工程参考 | 教材推荐所有项目选用 pgvector；某参数组合可不经压测上线 |
| [Structured outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs) | 厂商官方 API 文档，动态 | 格式约束、严格工具输入、Schema 支持边界与拒答/截断处理 | 字段符合 Schema 就是真实、已授权、业务有效；所有模型支持相同字段 |
| [PostgreSQL 18：Row Security Policies](https://www.postgresql.org/docs/18/ddl-rowsecurity.html) | 数据库官方文档，固定主版本 | 服务端/数据库强制控制行访问的具体例子及角色例外 | 仅配置一条策略就涵盖缓存、检索、日志和所有应用权限 |

对应笔记：[[AI-02-Prompt与上下文工程]]、[[AI-03-RAG从检索到可信回答]]、[[AI-04-Function Calling与API工具设计]]。

## 工具、Agent、MCP 与 Skills

| 来源 | 类型与时间 | 本笔记使用范围 | 不能据此推出 |
|---|---|---|---|
| [Tool use with Claude](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview) | 厂商官方 API 文档，动态 | 模型提出调用、应用或服务方执行、工具结果回传的往返机制 | 生成调用即动作成功；厂商示例模型名与价格可永久沿用 |
| [Writing effective tools for AI agents](https://www.anthropic.com/engineering/writing-tools-for-agents) | 厂商工程文章，2025-09-11 | 工具职责、描述、参数语义、返回内容与评测设计 | 只读名称与行为注解能替代真实权限；工具越多越强 |
| [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) | 厂商工程文章，2024-12-19 | 工作流与 Agent 的控制路径区别、从简单方案开始的工程取舍 | 所有业务都要 Agent；多 Agent 一定提高效果 |
| [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629) | 原始论文，2022 | 推理与环境行动交替的经典设计思想 | 必须公开模型完整内在推理才能审计；该模式天然安全 |
| [MCP Architecture 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/architecture) | 协议官方规范，固定版本 | Host、Client、Server 的分工与连接关系 | 支持 MCP 的产品实现了全部可选能力 |
| [MCP Tools 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/server/tools) | 协议官方规范，固定版本 | tools/list、tools/call、输入输出结构、工具注解的信任边界 | 注解自称只读就可信；MCP 自动完成业务鉴权 |
| [MCP Authorization 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization) | 协议官方规范，固定版本 | HTTP 授权、令牌目标资源校验、下游令牌边界 | 所有本地和远程传输采用相同认证流程；登录即拥有全部业务权限 |
| [Agent Skills specification](https://agentskills.io/specification) | 开放规范，动态 | SKILL.md、可选脚本/参考/资产目录、渐进加载 | 读入技能等于训练模型或获得接口权限；Agentrix 的 Skill 必然完全同构 |
| [Agent Skills overview](https://agentskills.io/home) | 开放规范官方概览，动态 | 技能作为可复用任务能力包的整体说明 | 不经测试就能保证跨客户端行为完全一致 |

对应笔记：[[AI-04-Function Calling与API工具设计]]、[[AI-05-Agent工作流MCP与Skills]]。

## 评测与可观测性

| 来源 | 类型与时间 | 本笔记使用范围 | 不能据此推出 |
|---|---|---|---|
| [Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) | 厂商工程文章，2026-01-09 | 测试任务、重复尝试、评分器、轨迹与环境最终结果的区分 | 一次过关等于稳定生产表现；模型评审永远准确 |
| [OpenTelemetry：Traces](https://opentelemetry.io/docs/concepts/signals/traces/) | 官方技术文档，动态 | Trace/Span 与跨组件运行记录的概念 | 必须采用某一观测平台；记录全部敏感原文是必要条件 |

对应笔记：[[AI-06-评测可观测性与成本性能]]。教材中的成本公式、条件独立概率演示、状态机、故障定位表和环卫练习属于教学推导；前提已在正文写明，不能将虚构数值引用为任何厂商的测量结果。

## 本地岗位与产品依据

- [AI Native 售前技术专家岗位详情](<F:/cluade_code/AI面试/爱化身/AI Native 售前技术专家_岗位详情.txt>)：职责直接要求 LLM、RAG、Agent、Function Calling、Workflow、MCP、API、数据建模、Demo/POC、技术边界管理。正文按这些工作任务确定深度，并未把基础模型研究能力列为入职必要条件。
- [爱化身介绍 PDF](<F:/cluade_code/AI面试/爱化身/爱化身介绍.pdf>)：第 11 页涉及编排、权限、Trace 和生命周期；第 15—18 页展示 Data OS、Agent OS、Agent Workforce；第 22—25 页涉及城市环卫、动态调度、智能督查、洞察到执行和低空场景。教材只引用这些产品叙述来选择学习主题。
- [公司介绍文本提取](<F:/cluade_code/AI面试/爱化身/爱化身介绍_text.txt>)：用于全文检索和页码定位。产品资料中的客户效果、架构与能力属于公司材料陈述，不能视为本次独立实测。

## 入职后最值得补齐的验证资料

1. 当前产品版本与真实可用模型、部署方式、是否包含外部服务依赖。
2. Data OS 的检索、对象权限、版本更新、数据同步和动作接口说明。
3. Agent OS 的任务状态、暂停恢复、工具调用、MCP 兼容版本、Skill 结构与日志样例。
4. 一套脱敏的真实 POC 数据、验收报告和失败案例，验证产品宣传与实际测试条件的关系。
5. 成本计量、容量压测、上线责任与故障协同流程；没有原始依据的指标暂标待核实。

这些缺口不需要靠猜测补齐。售前的专业性体现在知道应该验证什么，并把不确定性转成可执行的验证步骤。
