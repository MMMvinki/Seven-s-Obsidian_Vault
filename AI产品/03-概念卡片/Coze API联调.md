---
title: Coze API联调
tags:
  - AI产品经理
  - 概念卡片
  - Coze
  - API
---

# Coze API 联调

来源：[[05-demo搭建：用Vibe Coding构建产品Demo#17. 接上 Coze：从假数据到真实回复]]

Coze API 联调是把前端 Demo 的假回复换成 Coze 工作流的真实回复。

完整链路：

`前端 Demo → 轻量后端中转 → Coze 工作流 → 回复原路返回 → 显示到对话界面`

核心原则：

> ==Coze 当后端，前端只管收发消息和显示，逻辑一行都不用重写。==

注意：

- Token 是调用钥匙，要保密。
- 不要把 Token 写死在前端。
- 调用失败要有错误提示。
- 一处处把假数据换真调用，换一处测一次。
