#!/usr/bin/env bash
set -e

# 创建脚本目录
mkdir -p scripts

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
  echo "📝 确保 \$GOPATH/bin 在你的 PATH 中..."
  if [[ "$SHELL" == *"zsh"* ]]; then
    if ! grep -q 'export PATH=$PATH:$(go env GOPATH)/bin' ~/.zshrc; then
      echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.zshrc
      echo "✅ 已添加 Go bin 目录到 ~/.zshrc，请运行 'source ~/.zshrc' 或重启终端"
    fi
  elif [[ "$SHELL" == *"bash"* ]]; then
    if ! grep -q 'export PATH=$PATH:$(go env GOPATH)/bin' ~/.bashrc; then
      echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
      echo "✅ 已添加 Go bin 目录到 ~/.bashrc，请运行 'source ~/.bashrc' 或重启终端"
    fi
  fi
else
  echo "✅ golangci-lint 已安装 ($(golangci-lint --version | head -n1))"
fi

# 生成 .editorconfig
cat <<EOF > .editorconfig
root = true
[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
trim_trailing_whitespace = true

[*.go]
indent_style = tab
indent_size = 4
EOF

# 生成 .golangci.yml (v1 格式兼容)
cat <<EOF > .golangci.yml
run:
  timeout: 2m
  modules-download-mode: readonly

linters:
  disable-all: true
  enable:
    - errcheck
    - govet
    - ineffassign
    - misspell
    - staticcheck

issues:
  exclude-use-default: false
EOF

# 生成 Makefile
cat <<EOF > Makefile
.PHONY: commit lint format
commit:
	bash scripts/smart-commit.sh auto=yes
lint:
	golangci-lint run --config .golangci.yml
format:
	gofmt -s -w .
	goimports -w .
pr:
	@if [ ! -f scripts/bitbucket-pr.sh ]; then \
		echo "❌ 错误: 找不到 scripts/bitbucket-pr.sh 脚本文件"; \
		echo ""; \
		echo "📁 请将 bitbucket-pr.sh 脚本放置到项目根目录的 scripts/ 文件夹下:"; \
		echo "   mkdir -p scripts"; \
		echo "   cp /path/to/bitbucket-pr.sh scripts/"; \
		echo "   chmod +x scripts/bitbucket-pr.sh"; \
		echo ""; \
		echo "💡 或者从以下位置获取脚本:"; \
		echo "   https://github.com/tencent-international/specification/blob/main/commits/bitbucket-pr.sh"; \
		echo ""; \
		exit 1; \
	else \
		bash scripts/bitbucket-pr.sh; \
	fi
EOF

# 生成 Go 智能提交脚本
cat <<'EOF' > scripts/smart-commit.sh
#!/usr/bin/env bash
set -e

read -p "✨ 是否需要格式化 Go 代码？(y/N, 默认 N): " FORMAT_CONFIRM
FORMAT_CONFIRM=${FORMAT_CONFIRM:-n}
if [[ "$FORMAT_CONFIRM" =~ ^[Yy]$ ]]; then
  echo -e "\n✨ Step 1: 检查并格式化 Go 代码 (gofmt + goimports)..."
  UNFMT=$(gofmt -l .)
  if [ -n "$UNFMT" ]; then
    echo "🛠 发现以下文件未按 gofmt 格式化："
    echo "$UNFMT" | sed 's/^/  - /'
    echo "🚀 自动执行：gofmt -s -w"
    gofmt -s -w .
    echo "✅ gofmt 已完成格式化："
    echo "$UNFMT" | sed 's/^/  - /'
  fi
  echo "🚀 执行：goimports -w"
  goimports -w .
  if [ -n "$(git diff --name-only)" ]; then
    echo "📦 格式化后检测到文件变更，自动执行 git add ."
    git add .
  else
    echo "✅ Go 代码已格式化且无新变更"
  fi
else
  echo "跳过 Go 代码格式化。"
  if [ -n "$(git diff --name-only)" ]; then
    echo "📦 检测到文件变更，自动执行 git add ."
    git add .
  fi
fi

echo ""
echo "🔍 Step 2: 运行 golangci-lint 检查..."
if ! golangci-lint run --config .golangci.yml; then
  echo "⛔ Lint 检查失败"
  read -p "🛠 是否尝试自动修复？(Y/n,回车默认Y): " FIX_CONFIRM
  FIX_CONFIRM=${FIX_CONFIRM:-y}
  if [[ "$FIX_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "🔧 执行：golangci-lint run --fix"
    golangci-lint run --fix --config .golangci.yml || true
    echo "⚠️ 自动修复有局限性请注意!"
    echo "✅ 自动修复完成，建议检查差异："
    git diff
    echo "📦 自动暂存修复后的文件..."
    git add .
  else
    echo "⚠️ 跳过自动修复"
  fi
else
  echo "✅ Step 2: Lint 检查通过"
fi

echo ""
echo "🤖 Step 3: 调用 GPTCommit 生成提交信息并提交..."
git commit --quiet --no-edit
echo ""
echo "🎉 提交完成！"
EOF

chmod +x scripts/smart-commit.sh

echo ""
echo "✅ Go Lint/格式化脚本与配置初始化完成！"
echo "   - .editorconfig"
echo "   - .golangci.yml (v1 格式兼容)"
echo "   - scripts/smart-commit.sh"
echo "   - Makefile"
echo ""
echo "📝 注意："
echo "   - 使用 go install 安装 golangci-lint 而非 brew"
echo "   - 已自动配置 PATH 环境变量"
echo "   - 生成的 .golangci.yml 采用 v1 格式兼容"
echo "   - 建议重启终端或运行 'source ~/.zshrc' 来应用 PATH 更改"
echo ""
