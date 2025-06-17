#!/usr/bin/env bash
set -e

echo "🚀 TypeScript Lint 快速初始化"
echo "================================"

if [ ! -f "package.json" ]; then
  echo "❌ 请先初始化 package.json"
  exit 1
fi

# 定义必要依赖
PACKAGES=(
  "typescript"
  "@typescript-eslint/eslint-plugin"
  "@typescript-eslint/parser"
  "eslint"
  "eslint-plugin-react"
  "eslint-plugin-react-hooks"
)

echo "📦 安装依赖中..."

SUCCEEDED=()
FAILED=()

# 尝试安装每个依赖
for package in "${PACKAGES[@]}"; do
  if npm install --save-dev "$package" >/dev/null 2>&1; then
    SUCCEEDED+=("$package")
  else
    FAILED+=("$package")
  fi
done

# 检查必要文件
if [ ! -f "tsconfig.json" ]; then
  echo "⚠️  请创建 tsconfig.json"
fi

if [ ! -f "eslint.config.mjs" ]; then
  echo "⚠️  请创建 eslint.config.mjs"
fi

# 更新 package.json scripts
npm pkg set scripts.lint='eslint "**/*.ts" --ignore-pattern node_modules'
npm pkg set scripts.lint:fix='eslint "**/*.ts" --ignore-pattern node_modules --fix'
npm pkg set scripts.type-check="tsc --noEmit"

echo ""
echo "📊 安装结果:"
echo "============"

if [ ${#SUCCEEDED[@]} -gt 0 ]; then
  echo "✅ 安装成功:"
  for pkg in "${SUCCEEDED[@]}"; do
    echo "   - $pkg"
  done
fi

if [ ${#FAILED[@]} -gt 0 ]; then
  echo "❌ 安装失败:"
  for pkg in "${FAILED[@]}"; do
    echo "   - $pkg"
  done
else
  echo "🎉 所有依赖安装成功！"
fi

echo ""
echo "🚀 可用命令:"
echo "   npm run lint      # 运行 ESLint"
echo "   npm run lint:fix  # 自动修复"
echo "   npm run type-check # 类型检查"
