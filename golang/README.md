# 🧠 GPT Commit 自动化提交工具集成指南

## 一、功能介绍

此项目集成了以下能力：

- 自动格式化代码（goimports）
- 自动执行 Lint 检查（golangci-lint）
- 调用 GPT 自动生成 Conventional Commit 风格的提交信息
- 提交信息校验钩子（commit-msg）

## 二、快速开始

### 1. 初始化项目
#### 把 go-init-commit-assist.sh 复制到项目的根目录下
```bash
bash go-init-commit-assist.sh
```

### 提交命令
```shell
make commit
```

### 中英切换
```shell
# 英文
gptcommit config set output.lang en
# 中文
gptcommit config set output.lang zh-cn
```
