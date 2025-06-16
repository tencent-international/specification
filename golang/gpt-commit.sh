#!/usr/bin/env bash
set -e

echo -e "\n🤖 调用 GPTCommit 生成提交信息并提交..."
git commit --quiet --no-edit
echo -e "\n🎉 提交完成！"
