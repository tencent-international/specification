#!/usr/bin/env bash
set -e

echo "TypeScript Lint 检测..."

# 检查 TypeScript 文件是否存在
if ! find . -name "*.ts" -type f | grep -v node_modules | head -1 | grep -q . 2>/dev/null; then
  echo "⚠️  没有找到 TypeScript 文件"
  exit 0
fi

# 1. TypeScript 类型检查
echo "🔍 类型检查..."
if npm run type-check; then
  echo "✅ 类型检查通过"
else
  echo "❌ 类型检查失败，需要手动修复"
  exit 1
fi

# 2. ESLint 检查
echo "🔍 ESLint 检查..."
if npm run lint; then
  echo "✅ ESLint 检查通过"
  echo "🎉 检测完成！"
else
  echo "❌ ESLint 检查失败"

  # 交互式修复选择
  read -p "🤔 是否自动修复？[y/N]: " FIX_CHOICE
  FIX_CHOICE=${FIX_CHOICE:-N}

  if [[ "$FIX_CHOICE" =~ ^[Yy]$ ]]; then
    echo "🔧 自动修复中..."

    if npm run lint:fix; then
      echo "🔍 重新检测..."

      if npm run lint; then
        echo "✅ 修复成功！"
      else
        echo "❌ 仍有问题，需要手动修复"
        exit 1
      fi
    else
      echo "❌ 自动修复失败，需要手动修复"
      exit 1
    fi
  else
    echo "⚠️  需要手动修复 ESLint 问题"
    exit 1
  fi
fi
