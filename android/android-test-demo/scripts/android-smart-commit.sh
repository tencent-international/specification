#!/usr/bin/env bash
set -e

# 检查强制模式
FORCE_MODE=false
if [[ "$1" == "--force" ]]; then
  FORCE_MODE=true
fi

# 检查是否在Android项目根目录
if [ ! -f "build.gradle" ] && [ ! -f "build.gradle.kts" ]; then
  echo "❌ 错误：请在Android项目根目录下运行此脚本"
  exit 1
fi

# 自动添加文件变更
if [ -n "$(git diff --name-only)" ] || [ -n "$(git diff --cached --name-only)" ]; then
  echo "📦 检测到文件变更，自动执行 git add ."
  git add .
fi

echo ""
echo "✨ Step 1: Ktlint 格式化"
if [ -f "gradlew" ]; then
  # 询问是否需要格式化
  read -p "🤔 是否运行 Ktlint 自动格式化？(Y/n): " FORMAT_CONFIRM
  FORMAT_CONFIRM=${FORMAT_CONFIRM:-y}
  
  if [[ "$FORMAT_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "🔧 正在运行 Ktlint 格式化..."
    if ./gradlew ktlintFormat > /dev/null 2>&1; then
      echo "✅ Ktlint 格式化完成"
      if [ -n "$(git diff --name-only)" ]; then
        echo "📦 格式化后检测到文件变更，自动暂存"
        git add .
      fi
    else
      echo "⚠️ Ktlint 格式化失败，可能项目未配置 Ktlint"
    fi
  else
    echo "⏩ 跳过 Ktlint 格式化"
  fi
else
  echo "⚠️ 未找到 gradlew，跳过 Ktlint 格式化"
fi

echo ""
echo "🔍 Step 2: 运行 Ktlint 检查..."
if [ -f "gradlew" ]; then
  if ./gradlew ktlintCheck; then
    echo "✅ Ktlint 检查通过"
  else
    echo "⛔ Ktlint 检查失败"
    if [ "$FORCE_MODE" = false ]; then
      read -p "🤔 是否继续提交？(y/N): " CONTINUE_CONFIRM
      CONTINUE_CONFIRM=${CONTINUE_CONFIRM:-n}
      if [[ ! "$CONTINUE_CONFIRM" =~ ^[Yy]$ ]]; then
        echo "❌ 已取消提交"
        exit 1
      fi
    else
      echo "⚠️ 强制模式：忽略 Ktlint 错误继续提交"
    fi
  fi
else
  echo "⚠️ 未找到 gradlew，跳过 Ktlint 检查"
fi

echo ""
echo "🔍 Step 3: 运行 Android Lint 检查..."
if [ -f "gradlew" ]; then
  if ./gradlew lint; then
    echo "✅ Android Lint 检查通过"
  else
    echo "⛔ Android Lint 检查失败"
    echo "📋 查看详细报告: build/reports/lint/lint-results.html"
    if [ "$FORCE_MODE" = false ]; then
      read -p "🤔 是否继续提交？(y/N): " CONTINUE_CONFIRM
      CONTINUE_CONFIRM=${CONTINUE_CONFIRM:-n}
      if [[ ! "$CONTINUE_CONFIRM" =~ ^[Yy]$ ]]; then
        echo "❌ 已取消提交"
        exit 1
      fi
    else
      echo "⚠️ 强制模式：忽略 Android Lint 错误继续提交"
    fi
  fi
else
  echo "⚠️ 未找到 gradlew，跳过 Android Lint 检查"
fi

echo ""
echo "🤖 Step 4: 生成提交信息并提交..."
echo "📝 正在调用 GPTCommit 生成提交信息..."
git commit --quiet --no-edit
echo ""
echo "🎉 提交完成！"
