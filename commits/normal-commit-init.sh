#!/usr/bin/env bash
set -e

# 以下为格式校验的 commit-msg hook，不论是否用 gptcommit 都要安装
mkdir -p .git/hooks
cat <<'EOF' > .git/hooks/commit-msg
#!/usr/bin/env sh
set -e
MSGFILE="$1"

# Conventional Commit 检查
REGEX='^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\([^)]+\))?: .+'

FIRST_LINE=$(head -n 1 "$MSGFILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [ -z "$FIRST_LINE" ]; then
  echo "❌ Error: 提交信息为空" >&2
  exit 1
elif ! echo "$FIRST_LINE" | grep -Eq "$REGEX"; then
  echo "⧗ Invalid commit message format." >&2
  echo "   应符合: type: subject 或 type(scope): subject" >&2
  echo "   当前第一行: $FIRST_LINE" >&2
  echo "   示例: feat: add new endpoint" >&2
  echo "   详情规范请看: https://github.com/tencent-international/specification/blob/main/README.md" >&2
  exit 1
fi
EOF
chmod +x .git/hooks/commit-msg

echo "✅ Conventional Commit 格式校验钩子已安装"
echo "（本次未启用 gptcommit，仅安装了 commit-msg 校验钩子）"
