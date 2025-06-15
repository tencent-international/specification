# 🧠 GPT Commit 自动化提交工具集成指南

## 一、功能介绍

此项目集成了以下能力：

- 自动格式化代码（gofmt + goimports）
- 自动执行 Lint 检查（golangci-lint）
- 调用 GPT 自动生成 Conventional Commit 风格的提交信息
- 提交信息校验钩子（commit-msg）

## 二、快速开始

### 1. 初始化项目
把 go-lint-init.sh 和 commits/gptcommit-init.sh 复制到项目的根目录下的 /scripts，按顺序执行：
```bash
# 远程执行脚本
bash -c "$(curl -fsSL https://github.com/tencent-international/specification/blob/main/commits/gptcommit-init.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tencent-international/specification/main/golang/go-lint-init.sh)"
# 下载远程文件
curl -O https://raw.githubusercontent.com/tencent-international/specification/main/golang/.editorconfig
curl -O https://raw.githubusercontent.com/tencent-international/specification/main/golang/.golangci.yml
curl -O https://raw.githubusercontent.com/tencent-international/specification/main/golang/pre-commit.sh
chmod +x pre-commit.sh
```
