#!/usr/bin/env bash
set -e

read -p "✨ 是否需要格式化 Go 代码？(y/N, 默认 N): " CONFIRM
CONFIRM=${CONFIRM:-n}

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo -e "\n✨ Step 1: gofmt + goimports 格式化..."
  gofmt -s -w .
  goimports -w .
  git add .
  echo "✅ Go 代码已格式化并已暂存"
else
  echo "跳过 Go 代码格式化"
  git add .
fi

echo -e "\n🤖 Step 2: 调用 GPTCommit 生成提交信息并提交..."
git commit --quiet --no-edit
echo -e "\n🎉 提交完成！"
