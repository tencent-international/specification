#!/usr/bin/env bash
set -e

echo "🔍 简化版 TypeScript Lint 检测脚本"
echo "=================================================="

if [ ! -f "package.json" ]; then
  echo " 请初始化 package.json..."
  exit 1
fi

check_package() {
  npm list "$1" >/dev/null 2>&1
}

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

if [ -d "node_modules/eslint" ]; then
  echo "   ✅ eslint 已安装"
else
  echo "   ❌ eslint 未安装"
  REQUIRED_PACKAGES+=("eslint")
fi

# 检查 react/react-hooks 插件（如果你的 eslint config 里用到了）
NEED_REACT_HOOKS=0
if grep -q "react-hooks" eslint.config.* 2>/dev/null || grep -q "react-hooks" .eslintrc* 2>/dev/null; then
  NEED_REACT_HOOKS=1
fi

if grep -q "eslint-plugin-react-hooks" package.json 2>/dev/null || [ $NEED_REACT_HOOKS -eq 1 ]; then
  if ! check_package "eslint-plugin-react-hooks"; then
    echo "   ❌ eslint-plugin-react-hooks 未安装"
    REQUIRED_PACKAGES+=("eslint-plugin-react-hooks")
  else
    echo "   ✅ eslint-plugin-react-hooks 已安装"
  fi
fi

# 检查 react plugin（如果你的 eslint config 里用到了）
NEED_REACT=0
if grep -q "react" eslint.config.* 2>/dev/null || grep -q "react" .eslintrc* 2>/dev/null; then
  NEED_REACT=1
fi

if grep -q "eslint-plugin-react" package.json 2>/dev/null || [ $NEED_REACT -eq 1 ]; then
  if ! check_package "eslint-plugin-react"; then
    echo "   ❌ eslint-plugin-react 未安装"
    REQUIRED_PACKAGES+=("eslint-plugin-react")
  else
    echo "   ✅ eslint-plugin-react 已安装"
  fi
fi

if [ ${#REQUIRED_PACKAGES[@]} -eq 0 ]; then
  echo "🎉 所有必需依赖都已安装！"
else
  echo "📦 安装缺少的依赖: ${REQUIRED_PACKAGES[*]}"
  npm install --save-dev "${REQUIRED_PACKAGES[@]}"
fi

if [ ! -f "tsconfig.json" ]; then
  echo "请创建 tsconfig.json..."
  exit 1
fi

if [ ! -f "eslint.config.mjs" ]; then
  echo "请创建 eslint.config.mjs..."
  exit 1
fi

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
echo "   npm run lint                # 只运行 ESLint"
echo "   npm run lint:fix            # 自动修复 ESLint 问题"
echo "   npm run type-check          # 只运行类型检查"
echo ""
echo "💡 只安装了必要的依赖，无多余内容！"
