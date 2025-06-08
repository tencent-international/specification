#!/usr/bin/env bash
set -e

# Step 0: 确认是否执行 Go 代码格式化
read -p "✨ 是否需要格式化 Go 代码？(y/N, 默认 N): " FORMAT_CONFIRM
FORMAT_CONFIRM=${FORMAT_CONFIRM:-n}

if [[ "$FORMAT_CONFIRM" =~ ^[Yy]$ ]]; then
  echo -e "\n✨ Step 1: 检查并格式化 Go 代码 (gofmt + goimports)..."
  # 1.1 检测 gofmt 未格式化文件
  UNFMT=$(gofmt -l .)
  if [ -n "$UNFMT" ]; then
    echo "🛠 发现以下文件未按 gofmt 格式化："
    echo "$UNFMT" | sed 's/^/  - /'
    echo "🚀 自动执行：gofmt -s -w"
    gofmt -s -w .
    echo "✅ gofmt 已完成格式化："
    echo "$UNFMT" | sed 's/^/  - /'
  fi

  # 1.2 执行 goimports
  echo "🚀 执行：goimports -w"
  goimports -w .

  # 1.3 格式化后如果有文件变更，自动 git add
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

# Step 2: Lint 检查 & 可选自动修复
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

# Step 3: 调用 GPTCommit 自动生成提交信息并提交
echo ""
echo "🤖 Step 3: 调用 GPTCommit 生成提交信息并提交..."
git commit --quiet --no-edit

echo ""
echo "🎉 提交完成！"
