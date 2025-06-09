# 🧠 GPT Commit 自动化提交工具集成指南

## 一、功能介绍

此项目集成了以下能力：

- 自动格式化代码（gofmt + goimports）
- 自动执行 Lint 检查（golangci-lint）
- 调用 GPT 自动生成 Conventional Commit 风格的提交信息
- 提交信息校验钩子（commit-msg）

## 二、快速开始

### 1. 初始化项目
把 go-lint-init.sh 和 common/gptcommit-init.sh 复制到项目的根目录下，按顺序执行：
```bash
bash gptcommit-init.sh
bash go-lint-init.sh
```

### 2. 生成的文件说明
- `.editorconfig` - 编辑器代码风格配置
- `.golangci.yml` - golangci-lint 检查配置
- `scripts/smart-commit.sh` - 智能提交脚本
- `Makefile` - 快捷命令定义

## 三、使用命令

### 🚀 智能提交（推荐）
```shell
make commit
```
**功能说明：**
- 询问是否格式化代码（可选）
- 自动运行 golangci-lint 检查
- Lint 失败时询问是否自动修复
- 调用 GPTCommit 生成提交信息并提交

### 🔍 代码检查
```shell
make lint
```
运行 golangci-lint 进行代码质量检查

### ✨ 代码格式化
```shell
make format
```
执行 Go 代码格式化（gofmt + goimports）

### 🛠 手动操作
```shell
# 仅运行 golangci-lint
golangci-lint run --config .golangci.yml

# 仅格式化代码
gofmt -s -w .
goimports -w .

# 自动修复部分 lint 问题
golangci-lint run --fix --config .golangci.yml
```

## 四、GPTCommit 配置

### 中英文切换
```shell
# 英文提交信息
gptcommit config set output.lang en

# 中文提交信息
gptcommit config set output.lang zh-cn
```

### 其他配置
```shell
# 查看当前配置
gptcommit config list

# 设置 OpenAI API Key（如果需要）
gptcommit config set openai.api_key YOUR_API_KEY
```

## 五、智能提交流程

1. **Step 1: 代码格式化（可选）**
   - 询问是否需要格式化
   - 使用 gofmt + goimports 格式化
   - 自动暂存格式化后的变更

2. **Step 2: Lint 检查**
   - 运行 golangci-lint 检查
   - 失败时询问是否自动修复
   - 自动暂存修复后的变更

3. **Step 3: 智能提交**
   - 调用 GPTCommit 生成符合规范的提交信息
   - 自动提交到 Git 仓库

## 六、最佳实践

- 建议在每次提交前使用 `make commit` 确保代码质量
- 定期运行 `make lint` 检查代码问题
- 使用 `make format` 保持代码风格一致
- 配置编辑器支持 `.editorconfig` 获得更好的开发体验
