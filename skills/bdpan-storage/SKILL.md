---
name: bdpan-storage
version: v1.1.0
description: 百度网盘文件管理 Skill。支持上传、下载、转存、分享、列表查询。当用户提及"百度网盘"/"bdpan"/"网盘"并涉及文件操作（上传/下载/转存/分享/查看/登录/注销）时触发。用户说"上传到网盘"、"从百度网盘下载"、"转存到网盘"、"分享文件到网盘"、"查看网盘文件"、"登录百度网盘"等均应触发此 Skill。
---

# 百度网盘存储 Skill

百度网盘文件管理工具，支持上传、下载、转存、分享、列表查询。所有操作限制在 `/apps/bdpan/` 目录内。

适配产品: OpenClaw, Claude Code, DuClaw, KimiClaw, Manus 等。

## 安全须知（BETA）

> **1.** 本工具处于公测期，仅供技术交流，请**备份**网盘重要数据。
> **2.** AI Agent 行为不可预测，请**人工审核**每条指令。
> **3.** 严禁在公用或不可信环境中扫码授权。使用完毕后执行 `bdpan logout` 清除授权。
> **4.** 严格保护配置文件与 Token，切勿在公开仓库或对话中暴露。

**首次使用时，向用户展示上述安全须知。**

---

## 触发规则

同时满足以下两个条件才执行：

1. **用户明确提及百度网盘**——消息中包含 "百度网盘"、"bdpan"、"网盘" 等关键词
2. **操作意图明确**——能确定是以下操作之一：上传、下载、转存、分享、列表查看、登录、注销

不满足时，不执行任何 bdpan 命令。

---

## 确认规则

以下场景**必须先向用户确认**，不得直接执行：

| 场景 | 说明 |
|------|------|
| 路径不明确 | 用户未指定具体文件路径或目标路径 |
| 远程路径已存在 | 上传目标位置有同名文件，询问：覆盖/重命名/取消 |
| 本地路径已存在 | 下载目标位置有同名文件，询问：覆盖/重命名/取消 |
| 操作意图模糊 | "处理文件"→确认上传还是下载；"同步"→确认方向；"备份"→确认方向 |

确认时使用以下格式：

```
操作类型: [上传/下载/分享/列表]
源路径: [路径]
目标路径: [路径]
请确认是否执行？
```

---

## 前置检查

每次执行 bdpan 命令前：

1. `bdpan whoami` 检查登录状态，未登录则引导执行 `bash scripts/login.sh`
2. 验证路径合法性（禁止 `../`，禁止 `/apps/bdpan` 以外的绝对路径）

---

## 核心功能

### 上传

```bash
bdpan upload <本地路径> <远程路径>
bdpan upload ./project/ project/          # 文件夹需加 /
```

步骤：确认本地路径存在 → 确认远程路径 → 用 `bdpan ls` 检查远程是否已存在 → 执行上传

### 下载

```bash
bdpan download <远程路径> <本地路径>
bdpan download report.pdf ./report.pdf
bdpan download backup/ ./backup/          # 文件夹需加 /
```

步骤：用 `bdpan ls` 确认云端路径存在 → 确认本地路径 → 检查本地是否已存在 → 执行下载

### 转存（仅转存到网盘，不下载到本地）

```bash
# 基本用法 - 转存到应用根目录 /apps/bdpan/
bdpan transfer <分享链接> -p <提取码>

# 提取码在链接中
bdpan transfer "https://pan.baidu.com/s/1xxxxx?pwd=abcd"

# 指定目标目录
bdpan transfer <分享链接> -p <提取码> -d my-folder/

# JSON 输出
bdpan transfer <分享链接> -p <提取码> --json
```

步骤：验证链接格式 → 确认有提取码 → 确认目标目录 → 执行转存

### 分享链接下载

```bash
# 链接中含提取码
bdpan download "https://pan.baidu.com/s/1xxxxx?pwd=abcd" <本地路径>
# 单独传入提取码
bdpan download "https://pan.baidu.com/s/1xxxxx" <本地路径> -p <提取码>
# 指定转存目录
bdpan download "<链接>" <本地路径> -t <转存目录>
```

步骤：验证链接格式 → 确认有提取码 → 确认本地保存路径 → 执行下载

### 分享

```bash
bdpan share <远程路径>
bdpan share <路径1> <路径2>               # 多文件分享
```

### 列表查询

```bash
bdpan ls                                  # 根目录
bdpan ls <目录路径>                        # 指定目录
bdpan ls --json                           # JSON 输出
```

### 登录

**Agent 必须且只能通过 `bash scripts/login.sh` 执行登录。** 脚本内置了免责声明和完整的授权流程。

禁止 Agent 直接调用 `bdpan login --get-auth-url`、`bdpan login --set-code` 等子命令——这些由 login.sh 内部调用。

在 GUI 桌面环境中，`bdpan login` 会自动弹出 WebView 完成授权，但 Agent 场景下仍应通过 login.sh 保证免责声明展示。

二维码登录：`bash scripts/login.sh --qrcode`

### 注销

```bash
bdpan logout
```

### 版本管理

```bash
bdpan update check                        # 检查更新
bdpan update                              # 执行更新（需用户确认）
bdpan update rollback                     # 回滚（需用户确认）
```

---

## 路径规则

所有远程路径相对于 `/apps/bdpan/`。有两条映射规则：

| 场景 | 规则 | 示例 |
|------|------|------|
| **命令中** | 使用 API 路径 | `bdpan upload ./f.txt docs/f.txt` |
| **展示给用户** | 使用中文名 | "已上传到：我的应用数据/bdpan/docs/f.txt" |

映射关系：`我的应用数据` ↔ `/apps`

**禁止：**
- 命令中使用中文路径（`我的应用数据/bdpan/...`）
- 展示时暴露 API 路径（`/apps/bdpan/...`）
- 路径包含 `..` 或 `~`
- 绝对路径不在 `/apps/bdpan` 下

---

## 授权码处理

当用户在对话中发送一个 32 位十六进制字符串（正则：`^[a-fA-F0-9]{32}$`），且上下文与百度网盘登录相关时，将其作为授权码处理，执行 `bash scripts/login.sh --yes`。

如果上下文不明确，先向用户确认："这是百度网盘授权码吗？"

---

## 参考文档

详细信息参见 reference 目录（遇到对应问题时查阅）：

| 文档 | 何时查阅 |
|------|---------|
| [bdpan-commands.md](./reference/bdpan-commands.md) | 需要完整命令参数、选项、JSON 输出格式时 |
| [authentication.md](./reference/authentication.md) | 登录认证流程细节、配置文件位置、Token 管理时 |
| [examples.md](./reference/examples.md) | 需要更多使用示例（批量上传、自动备份脚本等）时 |
| [troubleshooting.md](./reference/troubleshooting.md) | 遇到错误需要排查时 |
