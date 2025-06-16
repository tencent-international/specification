#!/usr/bin/env bash
set -e

# 检查是否为Android项目目录
if [ ! -f "build.gradle" ] && [ ! -f "build.gradle.kts" ]; then
  echo "❌ 错误：请在Android项目根目录下运行此脚本（需有 build.gradle 或 build.gradle.kts）"
  exit 1
fi

# 运行 Android Lint
if [ -f "gradlew" ]; then
  echo "🔍 正在运行 Android Lint..."
  ./gradlew lint
else
  echo "❌ 未找到 gradlew，请在项目根目录运行"
  exit 1
fi 