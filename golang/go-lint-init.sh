#!/usr/bin/env bash
set -e

# 安装 goimports
echo "🔧 安装 goimports（如未安装）..."
if ! command -v goimports >/dev/null 2>&1; then
  echo "📦 正在安装 goimports v0.28.0..."
  go install golang.org/x/tools/cmd/goimports@v0.28.0
  echo "✅ goimports 安装完成"
else
  echo "✅ goimports 已安装"
fi

# 安装 golangci-lint
echo "🔧 安装 golangci-lint（如未安装）..."
if ! command -v golangci-lint >/dev/null 2>&1; then
  echo "📦 正在安装 golangci-lint v1.64.8..."
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.64.8
  echo "✅ golangci-lint 安装完成"
else
  echo "✅ golangci-lint 已安装 ($(golangci-lint --version | head -n1))"
fi
