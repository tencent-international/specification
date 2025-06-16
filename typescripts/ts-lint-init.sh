#!/usr/bin/env bash
set -e

echo "🔍 简化版 TypeScript Lint 检测脚本"
echo "=================================================="

# 检查是否已存在package.json
if [ ! -f "package.json" ]; then
  echo " 请初始化 package.json..."
  exit 1
fi

# 检查依赖是否已安装
check_package() {
  npm list "$1" >/dev/null 2>&1
}

# 只安装必要的依赖
REQUIRED_PACKAGES=()

echo "🔍 检查必要依赖..."

if ! check_package "typescript"; then
  echo "   ❌ typescript 未安装"
  REQUIRED_PACKAGES+=("typescript")
else
  echo "   ✅ typescript 已安装"
fi

if ! check_package "@typescript-eslint/eslint-plugin"; then
  echo "   ❌ @typescript-eslint/eslint-plugin 未安装"
  REQUIRED_PACKAGES+=("@typescript-eslint/eslint-plugin")
else
  echo "   ✅ @typescript-eslint/eslint-plugin 已安装"
fi

if ! check_package "@typescript-eslint/parser"; then
  echo "   ❌ @typescript-eslint/parser 未安装"
  REQUIRED_PACKAGES+=("@typescript-eslint/parser")
else
  echo "   ✅ @typescript-eslint/parser 已安装"
fi

if ! check_package "eslint"; then
  echo "   ❌ eslint 未安装"
  REQUIRED_PACKAGES+=("eslint")
else
  echo "   ✅ eslint 已安装"
fi

# 安装缺少的依赖
if [ ${#REQUIRED_PACKAGES[@]} -eq 0 ]; then
  echo "🎉 所有必需依赖都已安装！"
else
  echo "📦 安装缺少的依赖: ${REQUIRED_PACKAGES[*]}"
  npm install --save-dev "${REQUIRED_PACKAGES[@]}"
fi

# 生成基本的 tsconfig.json (如果不存在)
if [ ! -f "tsconfig.json" ]; then
  echo "请创建 tsconfig.json..."
  exit 1
fi

# 生成基本的 eslint.config.js (如果不存在)
if [ ! -f "eslint.config.js" ]; then
  echo "📝 创建 eslint.config.js..."
  exit 1
fi

# 更新 package.json scripts
echo "📦 更新 package.json scripts..."
npm pkg set scripts.lint='eslint "**/*.ts" --ignore-pattern node_modules'
npm pkg set scripts.lint:fix='eslint "**/*.ts" --ignore-pattern node_modules --fix'
npm pkg set scripts.type-check="tsc --noEmit"

echo ""
echo "✅ 简化版 TypeScript Lint 脚本初始化完成！"
echo ""
echo "📋 需要的脚本的内容:"
echo "   - tsconfig.json (基本配置)"
echo "   - eslint.config.js (基本配置)"
echo "   - ts-lint.sh (检测脚本)"
echo "   - package.json scripts (lint 相关命令)"
echo ""
echo "🚀 使用方法:"
echo "   bash scripts/ts-lint.sh     # 运行完整检测"
echo "   npm run lint                # 只运行 ESLint"
echo "   npm run lint:fix            # 自动修复 ESLint 问题"
echo "   npm run type-check          # 只运行类型检查"
echo ""
echo "💡 只安装了必要的依赖，无多余内容！"
