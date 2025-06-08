#!/usr/bin/env bash
set -e

# 创建脚本目录
mkdir -p scripts

# 安装 goimports
echo "🔧 安装 goimports（如未安装）..."
if ! command -v goimports >/dev/null 2>&1; then
  brew install goimports || true
fi

# 安装 golangci-lint
echo "🔧 安装 golangci-lint（如未安装）..."
if ! command -v golangci-lint >/dev/null 2>&1; then
  brew install golangci-lint || true
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

# 生成 .golangci.yml
cat <<EOF > .golangci.yml
version: "2"
run:
  timeout: 2m
linters:
  default: none
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
.PHONY: commit
commit:
	bash scripts/smart-commit.sh auto=yes
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
echo "   - .golangci.yml"
echo "   - scripts/smart-commit.sh"
echo "   - Makefile"
echo ""
