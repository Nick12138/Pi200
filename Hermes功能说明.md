# Hermes Agent 功能说明

> 本文基于官方仓库 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) 的 README、用户文档与本地源码整理。
>
> 审阅版本：`0.19.0`；审阅提交：`41a07f5b8451f88a8b8b5adfc0cfdc2ada0a1f90`。
>
> 官方文档：[hermes-agent.nousresearch.com/docs](https://hermes-agent.nousresearch.com/docs/)

## 产品定位

Hermes Agent 是 Nous Research 开发的自进化私人 AI Agent。它使用同一套 Agent 核心服务 CLI、TUI、消息网关、Web 控制台和 Electron 桌面端，重点解决跨会话学习、技能沉淀、远程执行、多平台通信、定时自动化和研究轨迹生成。

Hermes 的两个核心设计原则是：保持会话系统提示词稳定以利用 Prompt Cache；保持核心工具集精简，把扩展能力放到 Skills、插件、MCP 和按条件启用的工具中。

## 核心功能

### CLI、TUI 与桌面端

- **交互式 CLI** — 通过 `hermes` 直接进入对话，可使用模型、人格、技能、会话和工具相关斜杠命令。

- **完整 TUI** — 支持多行编辑、命令补全、会话历史、流式文本、流式工具输出和中断当前工作。

- **Electron 桌面端** — 提供原生聊天窗口，支持实时工具活动、结构化工具摘要、设置和首次启动向导。

- **桌面文件浏览器** — 可以在应用内浏览和预览当前工作目录中的文件。

- **并排预览** — 网页、文件和工具输出可显示在聊天旁边的预览区域。

- **桌面语音** — 支持对 Agent 说话并播放 Agent 的语音回复。

- **Web 控制台** — 提供浏览器管理界面，用于查看会话、配置能力、管理后台服务和插件页面。

- **统一会话** — CLI、桌面端和消息网关共享 Agent 核心、Skills、记忆和会话存储。

### 会话与上下文

- **SQLite 会话存储** — CLI、网关、定时任务和委派任务的会话统一保存在 SQLite 中。

- **FTS5 全文检索** — 可以搜索全部历史会话中的真实消息，并在找到的会话中继续向前或向后浏览。

- **会话恢复** — 可以列出、选择和继续历史会话，消息平台也会根据用户与对话标识恢复对应上下文。

- **上下文压缩** — 长会话可以生成压缩分支，在保留关键上下文的同时释放模型窗口。

- **重试与撤销** — 支持重试上一轮或撤销最近的交互。

- **用量与洞察** — 可以查看 Token、费用和一段时间内的会话使用情况。

- **项目上下文文件** — 支持使用 `AGENTS.md`、`SOUL.md` 等文件向会话注入项目规则、人格和工作背景。

- **稳定 Prompt Cache** — 人格、记忆和工具前缀在会话开始时冻结，正常对话中不随意重建，从而减少重复推理成本。

### 人格与 Profile

- **人格切换** — 可以通过 `/personality` 选择或切换人格，不需要修改 Agent 核心代码。

- **SOUL 人格文件** — 人格可以通过文本文件定义语气、价值观、行为边界和交流方式。

- **多 Profile** — 每个 Profile 可以拥有独立配置、模型、凭证、记忆、Skills、会话、日志和网关。

- **Profile 克隆** — 可以从现有 Profile 复制一份初始配置，同时保持后续运行相互隔离。

- **Profile 路由** — 桌面端、网关、Cron 和多 Agent 看板会显式记录任务所属 Profile，避免跨身份串话。

- **OpenClaw 迁移** — 可导入 OpenClaw 的 `SOUL.md`、记忆、Skills、命令白名单、消息配置、部分凭证和工作区指令。

## 学习与记忆

### 内置持久记忆

- **双层记忆文件** — `MEMORY.md` 保存环境、项目和经验事实；`USER.md` 保存用户身份、偏好和沟通习惯。

- **有界记忆** — 默认约束为 `MEMORY.md` 2200 字符、`USER.md` 1375 字符，防止长期记忆无限占用每轮上下文。

- **Agent 主动维护** — Agent 可主动添加、替换和移除记忆，并在容量接近上限时自行合并旧条目。

- **冻结快照** — 每次会话开始时把记忆快照注入系统提示词；本轮新增记忆立即落盘，但下次会话才进入提示词。

- **记忆写入审批** — 可要求记忆写入先暂存，用户通过 `/memory pending`、`approve` 或 `reject` 审核后再生效。

- **记忆安全扫描** — 写入前检测提示词注入、凭证外传、后门命令和不可见 Unicode 等风险内容。

- **会话检索补充记忆** — 有界记忆只保留关键事实，完整历史通过 SQLite FTS5 按需搜索，两者不会互相替代。

### 外部记忆 Provider

- **可插拔记忆后端** — 外部记忆 Provider 与内置记忆并行工作，而不是覆盖内置记忆。

- **多种记忆实现** — 仓库提供 Honcho、OpenViking、Mem0、Hindsight、Holographic、RetainDB、ByteRover 和 Supermemory 等插件。

- **用户模型与语义检索** — 外部 Provider 可增加知识图谱、语义搜索、自动事实提取或长期用户建模。

### 闭环学习

- **后台复盘** — 一轮复杂任务结束后可以在后台复盘对话，识别需要保存的长期事实或可复用流程。

- **自动创建技能** — 当任务形成稳定方法时，Agent 可以把流程写成新的 Skill。

- **技能持续改进** — 已有 Skill 在实际使用中可以根据成功、失败和用户纠正生成补丁。

- **学习通知** — 默认会提示本轮更新了记忆或 Skill，也可以关闭通知或显示具体变更摘要。

- **学习模型分流** — 后台复盘可以使用更便宜的辅助模型，并通过会话摘要降低重复上下文成本。

- **技能写入审批** — 可以暂存 Agent 对 Skill 的创建、修改或删除，查看完整 Diff 后再批准。

## Skills、插件与 MCP

### Skills

- **Agent Skills 标准** — 兼容 agentskills.io，以 `SKILL.md` 为核心组织说明、脚本和资源。

- **渐进加载** — Skill 只在任务需要时加载，避免所有知识长期占据系统提示词。

- **斜杠调用** — 每个已安装 Skill 自动成为斜杠命令，也可以在一条消息开头组合最多多个 Skill。

- **Skill Bundle** — 可以把常用 Skills 组合成一个短命令，形成稳定工作流入口。

- **内置与可选目录** — 基础 Skills 默认随安装提供，体量大或依赖特殊环境的能力放在可选 Skills 中。

- **外部 Skill 目录** — 可挂载额外目录，与本地 `~/.hermes/skills` 一起扫描。

- **Skills Hub** — 支持发现和安装社区 Skills，并记录来源和版本信息。

- **Skill 审计** — 对 Skill 的脚本、权限、危险模式和来源进行审核，降低安装恶意指令的风险。

### 插件

- **Python 插件系统** — 能扩展工具、网关平台、模型 Provider、记忆 Provider、上下文引擎、Cron Provider、浏览器和媒体能力。

- **用户插件目录** — 第三方插件可安装到 `~/.hermes/plugins`，无需把代码合并进 Agent 核心。

- **生命周期与 Hooks** — 插件可以订阅 Agent、工具、网关和后台任务事件。

- **插件页面** — 桌面或 Web Dashboard 可承载插件自己的管理页面。

- **Provider 插件** — 模型供应商以 Profile 插件注册，便于增加认证、路由和协议兼容逻辑。

### MCP

- **内置 MCP Client** — 可连接外部 MCP Server，并把其工具按配置暴露给 Agent。

- **本地与远程传输** — 支持本地 `stdio` 进程以及远程 HTTP 类连接。

- **OAuth 支持** — 远程 MCP 可以完成浏览器 OAuth 登录和 Token 管理。

- **MCP 管理界面** — Dashboard 可展示连接状态、工具清单和认证状态。

- **可选 MCP 目录** — 仓库提供 Blender、Figma、Linear、n8n 和 Unreal Engine 等可选接入模板。

- **MCP Server 模式** — Hermes 自身也能通过服务入口暴露能力，供外部 MCP 客户端调用。

## 工具能力

### 文件、代码与终端

- **文件读写** — 支持读取、创建、修改、补丁和目录操作，并对路径进行安全检查。

- **终端工具** — 支持同步命令、后台命令、持续进程、日志读取、输入发送和进程终止。

- **PTY 交互** — 可以运行 Codex、Claude Code 等需要伪终端的交互式程序。

- **代码执行 RPC** — Agent 可以生成 Python 脚本，通过 RPC 批量调用现有工具，把多步流水线压缩成较少的模型轮次。

- **项目与 Git 辅助** — 提供项目检测、工作 Diff、Checkpoint 和恢复相关能力。

- **Todo** — 可以在长任务中维护待办清单和当前进度。

### 可移植执行环境

- **本机执行** — 在当前计算机直接运行命令和操作文件。

- **Docker** — 把终端任务放入容器，并通过挂载控制可见文件。

- **SSH** — 在远程服务器上执行命令，适合长期 VPS 或工作站。

- **Daytona** — 使用可暂停和恢复的远程开发环境。

- **Singularity** — 面向 HPC 和 GPU 集群提供容器化执行环境。

- **Modal** — 使用按需唤醒的 Serverless 计算环境执行任务。

### Web、浏览器与电脑操作

- **网页搜索与读取** — 支持搜索、抓取网页、提取正文和检查链接安全性。

- **浏览器自动化** — 支持浏览器导航、点击、输入、截图、对话框处理和保持浏览器会话。

- **云浏览器** — 可以通过托管 Tool Gateway 或 Browser Provider 使用远程浏览器环境。

- **Computer Use** — 提供桌面视觉与操作工具，可在支持的平台上控制真实应用。

- **图片理解** — 支持把图像作为模型输入，并通过视觉工具处理截图和附件。

- **图片与视频生成** — 可通过 FAL、xAI 或插件 Provider 提交媒体生成任务。

- **语音转写与 TTS** — 支持语音消息转写、文本转语音、流式语音和 Voice Mode。

- **唤醒词** — 可配置语音唤醒能力，让桌面或设备进入持续语音交互。

- **外部服务工具** — 包含 Home Assistant、飞书文档、飞书云盘、Microsoft Graph、Spotify 等服务接入。

## 多 Agent 与任务编排

- **异步 Subagent** — 主 Agent 可以把独立任务派给隔离的子 Agent，并限制并发数量和递归深度。

- **结果自动回流** — 子 Agent 完成后，结果和输出文件会重新进入父会话。

- **任务中断传播** — 用户中止父任务时，正在运行的子 Agent 和后台进程也会收到终止信号。

- **批量并行** — 研究和数据生成模式可以并行运行多个任务，并汇总轨迹与结果。

- **持久 Kanban** — 使用 SQLite 任务看板协调多个具名 Profile；任务、依赖、评论、重试和交接在重启后仍然存在。

- **多看板隔离** — 不同项目可以使用独立数据库、工作区、附件和日志。

- **任务状态机** — 支持 triage、todo、ready、running、blocked、done 和 archived 等状态。

- **依赖调度** — 父任务完成后自动提升满足条件的子任务，失败任务可以阻塞、解除和重新分配。

- **工作空间策略** — 任务可使用临时目录、现有目录或 Git Worktree；完成时按策略保留或清理文件。

- **人工介入** — 用户可以在看板中评论、补充附件、解除阻塞、改派 Profile 或审核结果。

- **Gateway Dispatcher** — 长期运行的 Gateway 会定期扫描看板并启动相应 Profile Worker。

## 自动化

- **Cron 调度器** — 可以用自然语言或 CLI 创建重复和一次性任务。

- **跨平台投递** — 定时任务完成后可把结果发送到指定消息平台、频道或用户。

- **后台 Agent Run** — Cron 可以启动完整 Agent 会话，也可以运行脚本型轻量任务。

- **运行记录** — 每次定时任务都有独立会话、状态、日志和费用记录。

- **外部调度 Provider** — 调度器可以通过插件替换，例如使用 Chronos 管理型调度服务。

- **常驻网关** — 消息、Cron、Kanban、Webhook 和后台任务可以由同一个长期 Gateway 进程承载。

## 消息平台与远程使用

- **统一消息网关** — 单个 Gateway 可以同时运行多个平台 Adapter，并让用户从常用聊天软件访问同一 Agent。

- **主流平台** — 包括 Telegram、Discord、Slack、WhatsApp、Signal、Email 和 Web/API。

- **中国平台** — 包括飞书、钉钉、企业微信、微信、QQ Bot 和元宝等 Adapter 或插件。

- **其他平台** — 包括 Google Chat、Microsoft Teams、Matrix、Mattermost、LINE、IRC、SMS、BlueBubbles/iMessage、Home Assistant、SimpleX、Raft、ntfy 等。

- **消息权限** — 支持 DM 配对、允许名单、群聊限制和平台 Owner 身份控制。

- **跨平台连续性** — 会话标识与 Profile 路由由网关保存，可从不同入口继续同一 Agent 的工作。

- **语音消息** — 外部平台的语音备忘录可以转写，回复可转换为语音。

- **主动发送** — Agent、Cron 和插件可向已配置的平台发送消息、文件和通知。

- **Webhook 与 API Server** — 外部程序可以通过 HTTP/Webhook 提交消息或触发 Agent。

## 模型与 Provider

- **多模型支持** — 支持 Nous Portal、OpenRouter、OpenAI、Anthropic、Google、NVIDIA、xAI、Kimi、MiniMax、DeepSeek、Qwen、GLM、Hugging Face 等大量 Provider。

- **自定义端点** — 可以配置自建或第三方 OpenAI 兼容端点，避免绑定单一厂商。

- **运行时切换模型** — 使用 `hermes model` 或 `/model` 切换 Provider 和模型。

- **OAuth 与订阅登录** — 部分 Provider 可通过 OAuth 使用已有订阅，而不只依赖 API Key。

- **辅助模型分工** — 后台复盘、摘要、用户画像等任务可以使用独立的便宜模型。

- **Tool Gateway** — Nous Portal 可统一提供模型、搜索、图片生成、TTS 和云浏览器；各工具仍可单独切回用户自己的 Key。

- **Profile 级凭证** — 不同 Profile 可以拥有独立认证和模型选择，适合个人、工作或多角色隔离。

## 安全能力

- **命令审批** — 终端命令可按照允许规则自动执行，也可以要求用户批准危险操作。

- **写入审批** — 文件、记忆和 Skills 的修改可以分别进入待审核队列。

- **路径安全** — 文件与命令工具会检查目标路径、工作目录边界和危险路径模式。

- **隔离执行环境** — Docker、Daytona、Modal、Singularity 或远程 SSH 可把执行环境与用户主机分开。

- **网络出口控制** — 提供网络出口隔离设计，远程和容器环境可限制 Agent 能访问的网络。

- **URL 安全** — Web 工具会检查本地地址、内网访问、重定向和潜在 SSRF 风险。

- **Skill 来源与内容审核** — 安装和执行前记录 Provenance，并检查潜在危险脚本和提示词。

- **凭证文件保护** — API Key、平台 Token 和 OAuth 资产保存在用户数据目录，不应进入项目仓库。

- **诊断工具** — `hermes doctor` 可以检查安装、依赖、配置、Provider、网关和运行环境问题。

## 研究与可观测性

- **轨迹保存** — 可以把完整 Agent 交互转换为训练用 JSONL 轨迹。

- **批量轨迹生成** — 支持批量运行数据集任务，为工具调用模型生成研究数据。

- **轨迹压缩** — 可压缩长工具调用轨迹，降低训练和分析成本。

- **日志分层** — Agent、错误、Gateway、Cron 和后台 Worker 有独立日志。

- **可观测性插件** — 可接入 Langfuse、Nemo Relay 等指标、Trace 和日志系统。

- **使用成本统计** — 统一记录不同入口、Profile、模型和后台任务的 Token 与费用。

## 平台支持

- **桌面系统** — 支持 macOS、Windows 和 Linux。

- **服务器环境** — 可在普通 Linux VPS、Docker 主机、远程服务器和 GPU/HPC 集群运行。

- **Android Termux** — 提供精简依赖安装路径，可直接在 Android Termux 中运行 CLI。

- **Serverless 环境** — Daytona 和 Modal 可以在空闲时暂停、需要时恢复。

## 当前实现边界

- **自动学习会修改长期状态** — 默认后台复盘可以写入记忆和 Skills；重视可控性时应开启 `memory.write_approval` 与 `skills.write_approval`。

- **内置记忆容量很小** — 其设计目标是保留高价值事实，不是无限知识库；大量语义记忆需要外部 Provider。

- **后台学习会产生模型调用** — 使用主模型可复用 Prompt Cache，但仍有 Token 成本；使用辅助模型会产生新的模型请求。

- **许多能力依赖外部服务** — 云浏览器、媒体生成、TTS、远程环境、消息平台和外部记忆通常需要账号、API Key 或付费资源。

- **消息平台能力不完全一致** — 各平台在流式回复、按钮、文件、线程和语音方面存在差异，不能假定所有入口表现完全相同。

- **远程执行需要额外防护** — SSH、容器和 Serverless 提升可移植性，但挂载、凭证、网络出口和清理策略必须单独配置。

- **Kanban 比 Subagent 更复杂** — 持久任务板适合跨角色、跨重启任务；简单并行查询使用 Subagent 成本更低。

- **没有独立原生移动客户端** — 移动使用主要依靠聊天平台或 Android Termux；桌面应用覆盖 macOS、Windows 和 Linux。

## 技术架构概览

```text
CLI / TUI / Desktop / Web / Messaging Platforms
                       │
                       ▼
              Hermes Gateway / API
                       │
                       ▼
                 Agent Runtime
       ┌───────────────┼────────────────┐
       │               │                │
  Memory + Skills   Tools + MCP    Subagents + Cron
       │               │                │
       └────────── SQLite State ─────────┘
                       │
                       ▼
 Local / Docker / SSH / Daytona / Singularity / Modal
```

核心以 Python 为主，桌面和 Web 界面使用 TypeScript/JavaScript。会话和多 Agent 看板使用 SQLite，消息平台、模型、记忆、调度和媒体能力通过插件继续扩展。
