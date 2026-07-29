# OpenClaw 功能说明

> 本文基于官方仓库 [openclaw/openclaw](https://github.com/openclaw/openclaw) 的 README、稳定功能文档与本地源码整理。
>
> 审阅版本：`2026.7.2`；审阅提交：`4624f681add592b8a3bbf937382192f8200aaf3d`。
>
> 官方文档：[docs.openclaw.ai](https://docs.openclaw.ai/)

## 产品定位

OpenClaw 是一个本地优先、长期在线的私人 AI 助手平台。它的核心不是单独的聊天窗口，而是一个常驻 Gateway：消息平台、浏览器控制台、CLI、桌面伴侣、移动设备节点、自动化和 Agent Runtime 都通过 Gateway 共享身份、会话、事件与安全策略。

OpenClaw 的突出特点是渠道覆盖广、设备节点完整、多 Agent 路由精细、插件生态庞大，以及面向长期运行服务的配置、诊断、迁移和安全体系。

## 核心功能

### Gateway 控制平面

- **常驻 Gateway** — 单个长期运行的 Gateway 统一管理聊天渠道、模型连接、Agent 调度、会话、Cron、设备节点和插件。

- **WebSocket 协议** — CLI、Web UI、桌面应用、自动化客户端和节点通过类型化 WebSocket API 连接 Gateway。

- **严格握手** — 客户端必须先完成带身份和认证信息的连接握手，协议消息通过 JSON Schema 校验。

- **实时事件** — Gateway 推送 Agent 流式输出、聊天、在线状态、健康、心跳、Cron 和节点事件。

- **幂等请求** — 发送消息和启动 Agent 等副作用请求使用幂等键，降低网络重试造成的重复执行。

- **服务管理** — Onboarding 可把 Gateway 安装为 launchd、systemd 用户服务或 Windows 计划任务，保持开机运行。

- **健康与诊断** — CLI、Control UI 和 `openclaw doctor` 可检查 Gateway、配置、渠道、模型、插件和迁移状态。

- **远程连接** — 推荐通过 Tailscale、VPN 或 SSH Tunnel 安全访问远程 Gateway。

### 用户界面

- **CLI** — 提供配置、模型、Agent、会话、消息、渠道、节点、Cron、Skills、插件、MCP、审批和诊断等完整命令。

- **终端 TUI** — 可在终端直接与 Agent 交互，查看流式文本和工具执行。

- **WebChat** — 浏览器聊天页面通过 Gateway 使用相同的历史、模型和 Agent。

- **Control UI** — 浏览器管理界面用于聊天、配置、模型、渠道、节点、自动化、插件、MCP、日志和实验功能。

- **macOS 菜单栏应用** — 提供本机状态、语音、Canvas、相机、屏幕和电脑控制，并可作为 Gateway 的设备节点。

- **Windows Hub** — Windows 原生伴侣应用可完成设置、托盘状态、聊天、节点模式和本地 MCP 模式。

- **Linux Hub/Node** — Linux 侧提供桌面或节点相关能力，并可与远程 Gateway 协作。

- **首次启动向导** — 引导设置 Gateway、工作区、模型认证、渠道、Skills 和常驻服务。

## Agent、人格与会话

### Agent 身份

- **单 Agent 默认模式** — 不配置时使用 `main` Agent 和默认工作区，降低首次使用复杂度。

- **多 Agent** — 可创建多个隔离 Agent，每个拥有自己的工作区、人格、模型、认证、会话数据库和工具策略。

- **人格文件** — `SOUL.md`、`IDENTITY.md`、`USER.md` 和 `AGENTS.md` 分别承载人格、身份、用户资料和工作规则。

- **确定性路由** — 根据渠道、账号、私聊对象、群组、Guild、Team 或角色把消息路由到指定 Agent。

- **多账号绑定** — 同一渠道可配置多个机器人或账号，并分别绑定不同 Agent。

- **群聊唤醒规则** — 支持提及触发、关键词和群组允许规则，避免 Agent 在所有群聊消息中自动发言。

- **Agent 间通信** — 可以显式启用并设定允许名单，让 Agent 互相发送消息；默认不会自动开放全部跨 Agent 权限。

### 会话

- **会话隔离** — 私聊可以进入 Agent 的主会话，群聊和不同发送者可使用独立会话键。

- **SQLite 会话状态** — 当前会话、消息、转录和 Agent 状态保存在每个 Agent 的 SQLite 数据库中。

- **会话搜索** — 可以按内容查找历史会话和消息，并通过 CLI 或 UI 打开对应记录。

- **上下文压缩** — 长会话支持 Compaction，以摘要替代过旧上下文并保留可继续工作所需信息。

- **会话裁剪** — 对工具输出、媒体和长历史执行 Pruning，避免上下文被无效数据占满。

- **流式回复** — Agent Token 和工具活动可实时进入客户端，再根据不同渠道能力进行分块或草稿式输出。

- **队列与 Steering** — 用户在 Agent 工作时发送的新消息可按队列策略排队、引导当前任务或中断执行。

- **Presence 与输入状态** — 支持在线状态、正在输入和任务进度信号，让远程聊天更接近真实助手。

### Subagent 与外部 Agent Runtime

- **Subagent** — 主 Agent 可启动后台子会话处理独立任务，并在完成后把结果送回父会话。

- **Subagent 权限继承** — 子 Agent 的沙盒和工具权限不会自动超过父会话允许范围。

- **ACP Agent 集成** — 可通过 Agent Client Protocol 调用外部 Coding Agent 或 Harness。

- **Codex Runtime** — 官方插件可以把 OpenAI Codex App Server 作为 Agent Runtime，同时纳入 OpenClaw 权限控制。

- **多专家并行** — 稳定 Subagent 适合有限并行；更大规模的 Swarm 目前属于显式开启的实验能力。

## 记忆与长期状态

- **Workspace 记忆文件** — Agent 可以把长期事实、用户资料和操作规则保存在工作区 Markdown 文件中。

- **Memory Core 插件** — 记忆通过独占插件槽接入，核心只依赖统一接口。

- **会话记忆搜索** — 能从历史转录、工作区笔记和配置的额外集合中检索相关内容。

- **QMD 后端** — 可对本地 Markdown、笔记和会话集合建立检索索引，并为不同 Agent 配置独立集合。

- **Memory Wiki** — 可把长期知识编译为 Wiki Vault，支持全局或按 Agent 隔离。

- **向量记忆** — 可选 LanceDB 等插件提供语义检索能力。

- **Active Memory** — 可选插件在会话过程中管理当前活跃事实和上下文。

- **跨 Agent 检索控制** — 只有显式配置额外集合时，一个 Agent 才能搜索另一个 Agent 的转录或知识库。

- **记忆可替换** — 记忆、Context Engine 和相关后端通过插件 Slot 选择，避免在核心中固定单一实现。

## 消息渠道

### 核心与官方渠道

- **核心渠道** — iMessage、Telegram 和 WebChat 随核心安装提供。

- **官方插件渠道** — 包括 WhatsApp、Discord、Slack、Signal、Feishu、Google Chat、IRC、LINE、Matrix、Mattermost、Microsoft Teams、Nextcloud Talk、Nostr、QQ Bot、SMS、Synology Chat、Tlon、Twitch、Zalo 和 Zalo Personal 等。

- **外部社区渠道** — 微信、元宝和其他地区平台可通过外部插件接入。

- **多渠道并行** — 一个 Gateway 可以同时连接多个渠道和多个账号。

- **群聊支持** — 支持群聊、线程、提及激活、群组允许名单和不同平台的原生回复格式。

- **DM 配对** — 新私聊用户可以先进入配对流程，经 Owner 批准后获得访问权限。

- **发送者允许名单** — 每个渠道和账号可限制允许访问 Agent 的用户或群组。

- **媒体收发** — 渠道层可接收和发送图片、音频、视频、文档、语音消息和其他平台支持的附件。

- **长回复分块** — 根据渠道字符限制和格式能力自动分块，避免消息被截断。

- **反应与交互动作** — 支持表情反应、按钮、选择项和渠道原生交互，在不支持的平台回退为可理解文本。

## 多模态与媒体

- **图片输入输出** — Agent 可以理解图片附件并发送图片结果。

- **音频与语音消息** — 支持语音转写、语音回复和多 Provider TTS。

- **视频与文档** — 可以接收、理解、转发或处理视频和文档附件。

- **图片生成** — 统一媒体生成接口可调用 OpenAI、FAL、ComfyUI 或其他 Provider 插件。

- **视频生成** — 统一视频生成接口支持 Runway、PixVerse、Volcengine 等 Provider。

- **音乐生成** — 可选工具和 Provider 支持音乐生成。

- **PDF 工具** — Agent 可读取和处理 PDF，具体 OCR 或编辑能力由工具与插件决定。

- **媒体理解插件** — 文档抽取、语音、视觉和媒体理解作为可替换插件能力接入。

- **富输出协议** — 工具可返回文件、媒体、卡片和结构化结果，并由不同客户端按能力展示。

## 工具与电脑操作

- **基础文件工具** — 支持读取、写入、编辑和 `apply_patch`，适合编程与文档任务。

- **命令执行** — `exec` 可在 Gateway 主机、沙盒或设备节点执行命令，支持超时、后台进程和输出限制。

- **浏览器自动化** — 浏览器插件可进行导航、点击、输入、截图、下载和页面检查。

- **Chrome Extension** — 可以连接用户已有 Chrome 标签页，在授权后操作当前登录状态下的网页。

- **多搜索 Provider** — 支持 Brave、DuckDuckGo、Exa、Firecrawl、Gemini、Grok、Kimi、MiniMax、Ollama、Perplexity、SearXNG 和 Tavily 等搜索来源。

- **Web Fetch 与正文提取** — 可获取网页、抽取正文，并通过网络策略限制内网和敏感地址访问。

- **Tool Search** — 大量工具可以不直接进入每轮 Schema，而是由 Agent 先搜索、描述再按需调用。

- **工具策略** — 全局、Agent、渠道和会话都可使用 Allow/Deny 列表缩小工具范围。

- **LLM Task** — 可以把一个受限的子任务交给指定模型执行并返回结构化结果。

- **Diff 展示** — 文件修改可生成差异视图，方便用户审查具体改动。

## 设备节点

- **Node 架构** — macOS、iOS、watchOS、Android、Linux 或 Headless 设备作为外围节点连接 Gateway，而不是各自运行 Gateway。

- **设备配对** — 节点使用签名设备身份发起配对，Owner 可批准、拒绝、重命名或撤销。

- **能力声明** — 节点在连接时声明自己允许的命令和权限，Gateway 不会假定所有设备能力相同。

- **Canvas** — Agent 可以显示和更新由用户控制的交互式 HTML/CSS/JS 画布。

- **相机** — 移动或桌面节点可在授权后拍照，为 Agent 提供现场视觉信息。

- **屏幕录制** — 节点可录制屏幕或提供截图，用于远程协助和视觉任务。

- **位置服务** — iOS/Android 节点可在系统授权后返回设备位置。

- **通知** — Gateway 可通过节点读取、处理或发送系统通知，具体能力受平台权限限制。

- **设备命令** — Android 与桌面节点可提供系统命令、文件、剪贴板和设备状态能力。

- **活跃电脑检测** — 多台 Mac 在线时，可以根据近期物理输入选择当前活跃设备作为操作目标。

- **版本兼容窗口** — Gateway 支持有限的 N-1 节点协议窗口，便于先升级 Gateway、再逐台升级节点。

## 自动化与工作流

- **Cron** — 支持一次性、周期性和 Cron 表达式任务，可启动 Agent、执行命令或投递消息。

- **Heartbeat** — Agent 可以按周期检查 `HEARTBEAT.md` 中的事项并执行轻量巡检。

- **Hooks** — 可以在新会话、重置、消息收发和生命周期事件发生时触发本地自动化。

- **Webhooks** — 外部系统可以通过 HTTP 请求触发消息、任务或插件能力。

- **Lobster 工作流** — 使用声明式流水线编排多个步骤、工具、条件和审批点。

- **Workboard** — 可选工作看板插件用于管理长期任务、分配工作和展示状态。

- **Commitments** — 可记录 Agent 对未来动作的承诺并跟踪是否按计划完成。

- **Standing Intents** — 支持持续有效的用户意图，让常驻 Agent 在满足条件时采取行动。

- **后台守护** — Gateway、节点、Cron 和渠道由系统服务监督，崩溃后可自动重启。

## 模型与 Provider

- **大量 Provider** — 官方文档列出 35 个以上模型 Provider，源码还包含更多官方和可选插件。

- **主流云模型** — 支持 Anthropic、OpenAI、Google、xAI、OpenRouter、GitHub Copilot、MiniMax、Mistral、Groq 等。

- **自托管模型** — 支持 vLLM、SGLang、Ollama、llama.cpp、LM Studio 和自定义 OpenAI/Anthropic 兼容端点。

- **OAuth 订阅登录** — OpenAI、Anthropic 等 Provider 可通过 OAuth 使用订阅账户。

- **模型目录** — Provider 插件声明模型、能力、上下文、推理、媒体和认证方式。

- **模型切换** — 可按 Agent、会话、任务或渠道选择不同模型和思考强度。

- **模型故障转移** — 支持 Provider 或模型失败时按配置切换备用模型。

- **成本与用量** — 记录 Token、费用和模型使用情况，供 CLI、UI 和自动化查看。

- **本地模型精简模式** — 可为工具调用能力较弱的小模型减少每轮可见工具；该模式目前属于实验功能。

## Skills、插件与 MCP

### Skills 与 ClawHub

- **Agent Skills** — Skills 以目录和 `SKILL.md` 形式提供领域流程、脚本和参考资料。

- **Skills 管理** — CLI 与 UI 可安装、更新、启用、禁用、检查和创建 Skills。

- **ClawHub** — 官方 Skill/Plugin Registry 提供搜索、版本、兼容性、扫描和安装入口。

- **工作区 Skills** — Agent 工作区可携带专属 Skills，但默认需要显式信任才能加载其中的代码。

- **丰富内置 Skills** — 覆盖 GitHub、Notion、Obsidian、1Password、语音、PDF、媒体、家庭设备、天气和开发工具。

### 插件系统

- **多来源安装** — 插件可从 ClawHub、npm、Git、本地目录、压缩包或兼容 Marketplace 安装。

- **丰富贡献类型** — 插件可以增加渠道、Provider、Agent Runtime、工具、Skills、语音、媒体、搜索、网页读取、Gateway 方法、CLI 命令和 UI。

- **插件 Hooks** — 类型化 Hooks 可以拦截或修改消息、Prompt、工具和生命周期流程。

- **插件 Slot** — Memory 和 Context Engine 等互斥类别通过 Slot 选择唯一实现。

- **插件策略** — 支持总开关、Allow/Deny、单插件启停、来源记录、兼容性检查和安装前策略命令。

- **兼容插件包** — 除原生 OpenClaw 插件外，也能识别部分 Codex、Claude 或 Cursor 风格的技能、命令和 Hook Bundle。

- **插件运行诊断** — `plugins inspect --runtime` 可证明工具、Hook、服务和命令已实际注册，而不只检查清单文件。

### MCP

- **MCP Client** — 可从 Settings、CLI 或配置连接第三方 MCP Server。

- **三种传输** — 支持本地 `stdio`、远程 SSE 和 Streamable HTTP。

- **MCP OAuth** — 远程 MCP 可配置 OAuth、Bearer、Header、TLS 和超时。

- **工具过滤** — 每个 MCP Server 可以用 Include/Exclude 限制暴露给 Agent 的工具。

- **MCP 诊断** — `openclaw mcp doctor <name> --probe` 会建立真实连接并检查工具、资源和 Prompt。

- **MCP Server** — `openclaw mcp serve` 可以反向把 OpenClaw 的渠道会话暴露给其他 MCP 客户端。

- **统一工具策略** — MCP 工具仍经过 Agent 工具配置、权限和安全策略，不会因为来自 MCP 就绕过限制。

## 安全能力

### 身份与网络

- **Gateway 认证** — 支持 Token、密码、可信代理、Tailscale 身份或严格受限的无共享密钥模式。

- **设备签名** — 客户端对 Gateway 下发的随机 Challenge 签名，防止只复制设备 ID 冒充已配对设备。

- **设备配对** — 新客户端和节点需要审批；本机 Loopback 可以采用更顺滑但范围受限的信任路径。

- **默认本机绑定** — Gateway 默认监听 `127.0.0.1`，不会未经配置直接暴露到公网。

- **DM 配对与允许名单** — 消息入口先验证发送者和群组策略，再把内容交给 Agent。

- **SecretRef** — 敏感值可引用专用凭证存储或 Secret Provider，避免直接写入普通配置。

### 工具与执行权限

- **五种 Host Exec 模式** — `deny`、`allowlist`、`ask`、`auto` 和 `full` 覆盖禁止、白名单、人工询问、自动审核和完全授权。

- **自动审核** — `auto` 会先让本地 Reviewer 判断未命中白名单的命令，无法安全决定时再转人工审批。

- **双层权限** — OpenClaw 配置与执行主机本地审批文件取更严格结果，远程客户端不能单方面放宽主机策略。

- **Docker 沙盒** — 可按 Agent 使用独立或共享容器，配置挂载、网络和初始化命令。

- **每 Agent 工具限制** — 个人 Agent 可直接操作，家庭或公共 Agent 可仅允许读取并禁用执行、写入和浏览器。

- **Elevated 双重门控** — 提权操作需要同时通过全局和 Agent 级允许规则。

- **插件安装策略** — 可在安装或升级代码前运行 Operator 自定义检查，来源不可信时要求显式强制确认。

- **安全审计与策略插件** — 提供策略、审计、诊断、OpenTelemetry 和 Prometheus 等扩展。

- **备份、迁移与 Doctor** — 配置和数据升级由迁移工具处理，`doctor --fix` 修复旧配置并报告降级能力。

## 当前实现边界

- **核心安装不等于全部功能** — Discord、WhatsApp、Slack、多数 Provider、媒体、记忆后端等通过官方插件提供，需要安装或启用后才可用。

- **配置面非常庞大** — OpenClaw 可细调渠道、Agent、节点和安全策略，但部署和维护成本高于单一终端 Agent。

- **节点不是独立 Agent Server** — 手机和桌面 Node 是 Gateway 的外围设备；渠道消息仍由 Gateway 接收和路由。

- **一个主机通常只运行一个 Gateway** — 同一渠道会话尤其是 WhatsApp 登录应由唯一 Gateway 持有，避免连接冲突。

- **远程访问需要安全网络** — 非本机访问必须正确配置认证、配对、TLS、Tailscale、VPN 或 SSH Tunnel，不能直接裸露端口。

- **渠道能力不一致** — 线程、按钮、媒体、流式和消息长度由各平台决定，插件只能在平台约束内适配。

- **本地设备能力需要系统授权** — 相机、位置、屏幕、辅助功能、通知和电脑控制都可能触发操作系统权限。

- **实验功能不能当作稳定基础** — Code Mode、Swarm、Codex 沙盒执行服务器和本地模型 Lean 模式目前需要显式实验开关。

- **完整生态带来供应链风险** — Plugins、Skills、MCP 和浏览器扩展都可能运行第三方代码，必须使用 Allowlist、来源验证和安装策略。

- **Windows、macOS、Linux 的能力不完全对称** — 原生节点和系统集成受平台 API 限制；跨平台功能应以 Gateway 协议能力为准。

## 技术架构概览

```text
Channels / CLI / TUI / Control UI / Desktop Hubs
                         │
                         ▼
                OpenClaw Gateway
          HTTP + typed WebSocket protocol
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
 Agent Runtime      Automation        Device Nodes
 Sessions/Memory   Cron/Hooks/Flow   macOS/iOS/Android
       │                 │                 │
       └────────── Plugins + MCP ──────────┘
                         │
                         ▼
             Providers / Tools / Sandboxes
```

核心以 TypeScript/Node.js 为主，使用 pnpm Monorepo。协议、Agent、AI、终端、媒体、语音、插件 SDK 和工作看板拆分为独立 Packages；渠道、Provider、记忆、浏览器和媒体能力主要通过 `extensions` 中的插件实现。
