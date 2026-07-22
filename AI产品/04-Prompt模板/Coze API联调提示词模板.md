---
title: Coze API联调提示词模板
tags:
  - AI产品经理
  - Prompt模板
  - Coze
source: [[05-demo搭建：用Vibe Coding构建产品Demo#19. Coze API 联调提示词示例]]
---

# Coze API 联调提示词模板

```text
目标：
把现在写死的假回复，改成调用我的 Coze 工作流 API 拿真实回复。

接口：
POST 到 [你的 Coze API 地址]
请求头带 Authorization: Bearer <我的Token>。

传参：
把用户输入作为 parameters 里的 [字段名] 字段传过去。

接收：
返回结果里的 [返回字段路径] 就是要显示的回复，解析出来填进 AI 消息气泡。

要求：
- Token 不要写死在前端，放到环境变量。
- 调用时显示加载状态。
- 失败时显示“稍后再试”。
- 如果前端跨域报错，加一个轻量后端中转。
- 一次只替换一处假数据，换一处测一次。
```
