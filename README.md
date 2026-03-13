# bdpan-storage

> 百度网盘 skill — 上传、下载、转存、分享，一句话搞定。

[![skill](https://img.shields.io/badge/skill-bdpan--storage-blue)](https://pan.baidu.com/apaastobui/developer#/developer/skill)
[![Version](https://img.shields.io/badge/version-v1.0.0-green)]()
[![License](https://img.shields.io/badge/license-MIT-yellow)](./LICENSE)

[**官网**](https://pan.baidu.com/apaastobui/developer#/developer/skill)

## 一键安装

```bash
npx skills add https://github.com/baidu-netdisk/bdpan-storage/skills --skill bdpan-storage
```

首次使用时，Skill 会自动引导你完成 CLI 工具安装和百度网盘登录授权。

## 功能一览

| 功能 | 说明 |
|------|------|
| 文件上传 | 上传本地文件或文件夹到百度网盘 |
| 文件下载 | 从网盘下载文件或文件夹到本地 |
| 分享链接下载 | 通过分享链接 + 提取码直接下载 |
| 转存 | 将分享链接内容转存到自己的网盘 |
| 分享 | 生成 7 天有效期的分享链接 |
| 文件列表 | 查看网盘中已上传的文件 |

## 快速开始

安装完成后，在 OpenClaw / Claude Code / DuClaw 等 Ai Agent 中直接用自然语言操作即可：

```
帮我上传 ./report.pdf 到网盘并分享
```

```
从百度网盘下载 backup/ 到本地
```

```
转存这个链接到网盘：https://pan.baidu.com/s/1xxxxx?pwd=abcd
```

```
查看我网盘里有哪些文件
```

Skill 会自动识别你的意图，执行对应操作并返回格式化结果。

## 使用示例

### 上传并分享

```
帮我上传并分享 ./report.pdf
```

预期输出：

```
上传并分享成功！
链接: https://pan.baidu.com/s/xxxxxxx
提取码: abcd
有效期: 7 天
```

### 查看文件列表

```
查看我网盘里的文件
```

预期输出：

```
类型    大小          修改时间              文件名
------  ------------  --------------------  --------
目录     -            2026-02-20 10:30:00  backup
文件    1.5 MB        2026-02-25 15:20:00  report.pdf
文件    256 KB        2026-02-24 09:15:00  config.yaml

共 3 项
```

## 安全说明

- **作用域隔离** — 仅限网盘应用目录，无法访问用户其他文件
- **无删除操作** — 不提供删除命令，防止误操作
- **OAuth 2.0** — 不存储密码，使用授权码模式认证

> 本工具处于公测期（BETA），建议备份重要数据，并人工审核每条 AI 执行的命令。

## 故障排除

遇到问题时，可以对 Skill 说：

- "百度网盘 token 过期了" — 自动引导重新登录
- "检查网盘登录状态" — 查看当前认证信息

## 系统支持

macOS / Linux / Windows (WSL)

## 加入我们

bdpan-storage 正在快速迭代中，我们期待每一位开发者、创作者和效率爱好者的加入。

无论你是想第一时间体验新功能、反馈使用问题，还是希望参与共建、贡献代码，都欢迎扫码加入我们的社区：

<p align="center">
  <img src="./docs/join-us.png" alt="加入社区" width="260" />
</p>

<p align="center"><b>扫码添加，备注「github」即可入群</b></p>

在社区里你可以：

- 与核心开发团队直接交流，获取一手更新动态
- 提交 Bug 反馈和功能建议，影响产品走向
- 参与 Skill 共建计划，成为开源贡献者
- 结识一群同样热爱 AI + 效率工具的伙伴

> 每一个好产品的背后，都有一群愿意较真的用户。期待与你一起，把「一句话操作网盘」做到极致。

## 📦 打包与分享

### 本地打包

```bash
# 查看可用命令
make help

# 列出所有 skills
make list

# 打包指定 skill
make pack SKILL=bdpan-storage

# 打包所有 skills
make pack-all

# 清理打包输出
make clean
```

### 自动发布

推送 tag 后会**自动触发 GitHub Release**：

```bash
# 创建并推送 tag
git tag v1.0.0
git push origin v1.0.0
```

工作流会自动：
1. 打包所有 skills 为 zip 文件
2. 生成发布说明
3. 创建 GitHub Release 并上传资源

支持 tag 格式：
- `v*` — 如 `v1.0.0`
- `skill-*` — 如 `skill-v1.0.0`

## 许可证

[MIT License](./LICENSE)
