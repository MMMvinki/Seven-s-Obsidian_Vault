# DataOS八层技术架构

## 来源
- raw/DataOS 技术白皮书.md（第三章 3.1–3.2）

## 核心内容
DataOS 技术架构分八层，全部采用开源组件自下而上构建，这是它与百度胜算、火山引擎自研路线的根本区别。数据源（企业已有资产）→ 数据接入层（DataHub+Kafka+Flink+Dagster+dbt）→ 数据存储层（PostgreSQL+Apache AGE+Elasticsearch+StarRocks）→ 本体语义层（OMS+Hasura+Keycloak+OPA+Drools/LLM，核心）→ 语义应用层（Hasura GraphQL+Temporal.io）→ AI/决策层（LlamaIndex+Qdrant，RAG+图推理）→ 执行层（MCP/Skill/API 封装）→ 应用展现层（AppSmith+React）。

## 关键数据/事实
- 接入：DataHub（元数据/血缘）；Kafka+Flink（流批一体，Materialize 备选）；Dagster+dbt（批处理编排与 SQL 模型）
- 存储：PostgreSQL（业务表/JSONB/版本/审计）+ Apache AGE（图扩展，openCypher，零额外运维）+ Elasticsearch（全文检索）；OLTP 经实时 ETL 进 StarRocks（亚秒级 OLAP）
- 语义层权限：Keycloak（认证）+ OPA（Rego 声明式策略，行级/字段级控制）；语义增强 Drools 或 LLM（LLM 需人工校验迭代）
- AI 层：RAG 流程（Chunk→Embedding→Qdrant→相似检索→拼上下文→生成）；深度推理流程（NER+关系抽取→知识图谱→路径/子图检索→多跳推理→生成）
- OLTP 走 Hasura GraphQL，OLAP 由 LMM 自动生成标准 SQL
- 组件总数超过 10 个开源件，集成复杂度是已知短板（见 [[DataOS竞品对比分析]]）

## 关联
- [[DataOS产品定位与业务架构]]
- [[本体四张核心元数据表]]
- [[DataOS竞品对比分析]]
- [[DataOS实施口径与模型选型]]

## 标签
#爱化身 #产品 #技术架构 #数据平台 #2026
