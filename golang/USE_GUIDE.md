# 🧠 GPT Commit 自动化提交工具集成指南

## 一、功能介绍

此项目集成了以下能力：

- 自动格式化代码（gofmt + goimports）
- 自动执行 Lint 检查（golangci-lint）
- 调用 GPT 自动生成 Conventional Commit 风格的提交信息
- 提交信息校验钩子（commit-msg）

## 二、快速开始

### 1. 初始化项目

### 把当前目录的文件复制到你根目录

### 安装 goimports
```shell
go install golang.org/x/tools/cmd/goimports@v0.28.0
```

### 安装 golangci-lint
```shell
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.64.8
```

### 初始化 golangci-lint 到 git hooks
```shell
cat <<'EOF' >> .git/hooks/pre-commit
echo "运行 golangci-lint 检查..."
if ! golangci-lint run --config .golangci.yml; then
  echo "Lint 检查失败"
  exit 1
else
  echo "Lint 检查通过"
fi
EOF
chmod +x .git/hooks/pre-commit
```

### 初始化 gptcommit
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tencent-international/specification/main/commits/gptcommit-init.sh)"
```

