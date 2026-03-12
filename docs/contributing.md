# 贡献指南

感谢你对 bdpan-storage 项目的关注！本文档将帮助你了解如何参与贡献。

## 开发流程

1. Fork 本仓库
2. 基于 `main` 创建功能分支（命名规范见下方）
3. 本地开发、自测通过后提交
4. 发起 Pull Request

## 分支命名规范

| 类型 | 格式 | 示例 |
|------|------|------|
| 新功能 | `feat/<简短描述>` | `feat/add-batch-upload` |
| Bug 修复 | `fix/<简短描述>` | `fix/login-timeout` |
| 文档更新 | `docs/<简短描述>` | `docs/update-readme` |
| 重构 | `refactor/<简短描述>` | `refactor/skill-structure` |
| 测试 | `test/<简短描述>` | `test/add-upload-tests` |

## Commit 消息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>(<scope>): <subject>
```

**type**：`feat`、`fix`、`docs`、`style`、`refactor`、`test`、`chore`、`perf`

**示例**：
```
feat(bdpan-storage): add batch upload support
fix(login): handle token expiry gracefully
docs(readme): update installation instructions
```

## PR 规范

- PR 标题使用 Conventional Commits 格式
- 填写 PR 模板，说明改动内容、测试方式、关联 Issue
- 每个 PR 聚焦单一功能/修复
- 新增 Skill 必须附带文档、示例

## Code Review

- 至少 1 位核心维护者 Approve 后方可合并
- Review 聚焦：逻辑正确性、性能、安全、规范符合度
- 所有 Review 问题 Resolved 后合并

## 新增 Skill 要求

新增 Skill 需要：

1. 按照目录结构规范放置在 `skills/<category>/<skill-name>/`
2. 包含 `SKILL.md`（Skill 定义）和 `README.md`（说明文档）
3. README.md 需包含：简介、功能特性、输入/输出、快速开始、配置项、注意事项
4. 附带使用示例和参考文档

## 安全要求

- 严禁在代码中硬编码凭证、Token 或密钥
- 严禁提交 `.env`、`config.json` 等含敏感信息的文件
- OAuth Token 必须使用安全的存储方式
- 所有用户输入必须进行校验
