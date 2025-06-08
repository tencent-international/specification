#!/usr/bin/env bash
set -e

# 检查强制模式
FORCE_MODE=false
if [[ "$1" == "--force" ]]; then
  FORCE_MODE=true
fi

# 检查是否存在 src 目录，如果不存在则创建
if [ ! -d "src" ]; then
  echo "📁 创建 src 目录..."
  mkdir -p src
fi

# 自动添加文件变更
if [ -n "$(git diff --name-only)" ] || [ -n "$(git diff --cached --name-only)" ]; then
  echo "📦 检测到文件变更，自动执行 git add ."
  git add .
fi

echo ""
echo "✨ Step 1: 检查并格式化 TypeScript 代码..."
if find src -name "*.ts" -type f | head -1 | grep -q . 2>/dev/null; then
  echo "🚀 执行：prettier --write \"src/**/*.ts\""
  prettier --write "src/**/*.ts" || echo "⚠️ 格式化过程中出现问题"
  
  if [ -n "$(git diff --name-only)" ]; then
    echo "📦 格式化后检测到文件变更，自动暂存"
    git add .
    echo "✅ TypeScript 代码已格式化"
  else
    echo "✅ TypeScript 代码格式正确，无需修改"
  fi
else
  echo "⚠️ src 目录下没有 TypeScript 文件，跳过格式化"
fi

echo ""
echo "🔍 Step 2: 运行 ESLint 检查..."
if find src -name "*.ts" -type f | head -1 | grep -q . 2>/dev/null; then
  if npm run lint; then
    echo "✅ ESLint 检查通过"
  else
    echo "⛔ ESLint 检查失败，尝试自动修复..."
    if npm run lint:fix; then
      echo "✅ ESLint 自动修复完成"
      git add .
    else
      echo "⚠️ ESLint 自动修复失败，部分问题需要手动处理"
      if [ "$FORCE_MODE" = false ]; then
        read -p "🤔 是否继续提交？(y/N): " CONTINUE_CONFIRM
        CONTINUE_CONFIRM=${CONTINUE_CONFIRM:-n}
        if [[ ! "$CONTINUE_CONFIRM" =~ ^[Yy]$ ]]; then
          echo "❌ 已取消提交"
          exit 1
        fi
      else
        echo "⚠️ 强制模式：忽略 ESLint 错误继续提交"
      fi
    fi
  fi
else
  echo "⚠️ 没有找到 TypeScript 文件，跳过 ESLint 检查"
fi

echo ""
echo "🔍 Step 3: 运行 TypeScript 类型检查..."
if [ -f "tsconfig.json" ]; then
  if npm run type-check; then
    echo "✅ TypeScript 类型检查通过"
  else
    echo "⛔ TypeScript 类型检查失败"
    if [ "$FORCE_MODE" = false ]; then
      read -p "🤔 是否继续提交？(y/N): " CONTINUE_CONFIRM
      CONTINUE_CONFIRM=${CONTINUE_CONFIRM:-n}
      if [[ ! "$CONTINUE_CONFIRM" =~ ^[Yy]$ ]]; then
        echo "❌ 已取消提交"
        exit 1
      fi
    else
      echo "⚠️ 强制模式：忽略类型检查错误继续提交"
    fi
  fi
else
  echo "⚠️ 没有找到 tsconfig.json，跳过类型检查"
fi

echo ""
echo "🤖 Step 4: 调用 GPTCommit 生成提交信息并提交..."
git commit --quiet --no-edit
echo ""
echo "🎉 提交完成！"
