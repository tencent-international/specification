# 🤖 GPTCommit 通用初始化脚本

## 📖 概述

这是一个通用的 GPTCommit 初始化脚本，用于快速配置 AI 驱动的 Git 提交信息生成工具。该脚本会自动安装 GPTCommit、配置 Conventional Commit 格式，并设置提交信息校验钩子。

## ✨ 功能特性

- 🤖 **AI 生成提交信息** - 基于代码变更自动生成符合规范的提交信息
- 📝 **Conventional Commit 格式** - 自动生成符合约定式提交规范的信息
- 🌐 **多语言支持** - 支持中文和英文提交信息
- 🔒 **提交校验钩子** - 自动校验提交信息格式
- ⚙️ **一键配置** - 简化的安装和配置流程

## 🚀 快速开始

### 1. 运行初始化脚本

```bash
bash gptcommit-init.sh
```

### 2. 按提示进行配置

脚本会交互式地引导你完成配置：

1. **选择语言** - 选择提交信息的输出语言（中文/英文）
2. **API Key 配置** - 输入你的 OpenAI API Key（可跳过后续手动设置）

### 3. 开始使用

配置完成后，你可以使用以下命令进行智能提交：

```bash
# 使用 gptcommit 直接提交
git add .
gptcommit

# 或使用各语言的智能提交脚本
make commit  # 在 Go/TypeScript/Android 项目中
```

## ⚙️ 配置详情

脚本会自动进行以下配置：

### GPTCommit 基础配置
```bash
gptcommit config set output.format conventional          # 使用约定式提交格式
gptcommit config set output.lang zh-cn                   # 中文输出（或en英文）
gptcommit config set output.conventional_commit true     # 启用约定式提交
gptcommit config set output.include_body true            # 包含提交正文
gptcommit config set openai.model gpt-3.5-turbo         # 使用 GPT-3.5 模型
```

### Git 钩子配置
自动创建 `commit-msg` 钩子，校验提交信息格式：
- ✅ `feat: add new feature`
- ✅ `fix: resolve login issue`
- ❌ `random commit message`

## 🎯 约定式提交格式

支持的提交类型：

| 类型 | 描述 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: add user authentication` |
| `fix` | 错误修复 | `fix: resolve memory leak in parser` |
| `docs` | 文档更新 | `docs: update API documentation` |
| `style` | 代码格式 | `style: fix indentation in components` |
| `refactor` | 代码重构 | `refactor: optimize database queries` |
| `perf` | 性能优化 | `perf: improve loading speed by 50%` |
| `test` | 测试相关 | `test: add unit tests for auth module` |
| `chore` | 构建/工具 | `chore: update dependencies` |

## 🔧 高级配置

### 手动设置 API Key
如果初始化时跳过了 API Key 设置：

```bash
gptcommit config set openai.api_key "sk-your-api-key-here"
```

### 切换语言
```bash
# 切换为英文
gptcommit config set output.lang en

# 切换为中文
gptcommit config set output.lang zh-cn
```

### 查看当前配置
```bash
gptcommit config list
```

### 更换 AI 模型
```bash
# 使用 GPT-4（需要相应的 API 权限）
gptcommit config set openai.model gpt-4

# 使用 GPT-3.5 Turbo（默认，性价比高）
gptcommit config set openai.model gpt-3.5-turbo
```

## 🌟 最佳实践

### 1. 提交前准备
- 确保代码已通过测试
- 运行代码格式化和 lint 检查
- 暂存你想要提交的文件

### 2. 使用智能提交
```bash
# 推荐：使用各语言的智能提交脚本
make commit

# 或者手动使用 gptcommit
git add .
gptcommit
```

### 3. 提交信息质量
GPTCommit 会基于以下内容生成提交信息：
- 文件变更内容
- 新增/删除的代码
- 修改的函数和变量名
- 导入的依赖变化

## 🔗 集成项目

这个通用脚本已集成到以下开发工具链中：

- **🐹 Go 项目** - 配合 `go-lint-init.sh` 使用
- **🟦 TypeScript 项目** - 配合 `ts-lint-init.sh` 使用  
- **🤖 Android 项目** - 配合 `android-lint-init.sh` 使用

## 📚 相关资源

- [GPTCommit GitHub](https://github.com/zurawiki/gptcommit)
- [约定式提交规范](https://www.conventionalcommits.org/zh-hans/)
- [OpenAI API 文档](https://platform.openai.com/docs/)
- [本项目规范文档](https://github.com/tencent-international/specification)

## 🆘 常见问题

### Q: API Key 在哪里获取？
A: 访问 [OpenAI Platform](https://platform.openai.com/account/api-keys) 创建 API Key

### Q: 提交信息不符合预期怎么办？
A: 可以通过 `git commit --amend` 修改最后一次提交，或尝试切换不同的 AI 模型

### Q: 如何卸载？
A: 运行 `gptcommit uninstall` 并删除 `.git/hooks/commit-msg` 文件

### Q: 支持私有部署的模型吗？
A: 目前主要支持 OpenAI 的模型，私有部署需要查看 GPTCommit 的最新文档

---

**💡 提示**: 这个脚本是整个开发规范工具链的基础组件，建议在使用任何语言特定的 lint 工具前先运行此脚本。 