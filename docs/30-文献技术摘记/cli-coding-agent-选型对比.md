# 技术摘记：终端/IDE 类 Coding Agent 选型对比

> 日期：2026-10-17　来源：AI-Lab 通识文档 4.3 节 + 本机实测落地情况

## 一、候选清单

| 工具 | 形态 | 关键特点 | 适合谁 |
|---|---|---|---|
| **Trae** | AI 原生 IDE | 字节出品，国内网络友好，开箱即用，多模态 Agent 编码 | 不想折腾环境、直接要"能用"的人 |
| **Antigravity** | AI Agent 原生 IDE | Google 系 Agent 架构，工具链协同完整 | 想体验 Agent 原生工作流的人 |
| **WorkBuddy** | 桌面 AI 工作站 | 腾讯出品，面向结果交付，内置 Coding Mode | 以"任务闭环交付"为目标的人 |
| **OpenCode** | 终端 CLI/TUI | 开源免费，模型无关，支持 OpenAI 兼容接口与本地模型 | 极客、多模型横评、想全本地化的人 |
| **DSH (DeepSeek Harness)** | 终端 CLI/TUI + 桌面端 | 插件化（Everything is a Plugin），持久终端环境，多模型调度 | 想要"可编排、可扩展"终端 Agent 的人 |
| **VS Code** | 可扩展编辑器 | 插件生态成熟，可用 Roo Code / Continue 自定义 AI 工作流 | 想自己拼装、掌控每一环的人 |

## 二、选择判据（我实际用的三条）

1. **你的网络能不能稳定拉包**：OpenCode 要 Node + npm 拉全局包；本机对部分域名解析异常时，会卡在下载。
2. **你有没有可用的模型 Key**：终端 Agent 本身不含模型能力，没 Key 一步都走不了（可换 SiliconFlow / DeepSeek / 智谱 或本地 Ollama）。
3. **你要不要"可编排"**：只做日常审查/解释 → 轻量 TUI 就够；要做多步骤流水线（批量审查、自动修+测）→ 选支持子代理/插件/工作流的（DSH）。

## 三、本机落地状态（实测）

| 工具 | 状态 | 依据 |
|---|---|---|
| DSH | ✅ 已装可用 | 桌面版 0.2.0-rc.2；CLI 启动器 `%LOCALAPPDATA%\Programs\DeepSeek Harness\resources\runtime\cli\bin\dsh.cmd` 存在 |
| OpenCode | ❌ 未装 | 无全局 Node/npm（`%APPDATA%\npm` 不存在） |
| VS Code | ✅ 已装配齐 | 1.141.0 + 16 扩展 + 54 项配置 |

## 四、结论

- **本次考核用 DSH 交付**：原文写的是"OpenCode **或** DSH"，DSH 在本机已就绪，零成本。
- **要做多模型横评或全本地化**时再上 OpenCode：先装 Node LTS，再配 provider。
- 无论哪条路，**"先计划后执行 + 要求给出文件:行号证据"** 这两条使用习惯比选哪个工具更影响产出质量。
