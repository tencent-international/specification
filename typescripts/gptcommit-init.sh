#!/usr/bin/env bash
set -e

# 选择语言
read -p "请选择 GPTCommit 输出语言 [cn/en，默认 cn]: " LANG_CHOICE
LANG=${LANG_CHOICE:-cn}

# 安装 gptcommit
echo "🔧 安装 gptcommit（如未安装）..."
if ! command -v gptcommit >/dev/null 2>&1; then
  brew install zurawiki/brews/gptcommit
fi

# 配置 API Key
echo "🔑 设置 OpenAI API Key"
read -p "请输入你的 OpenAI API Key（sk-xxx，回车可跳过后手动设置）: " API_KEY
if [ -n "$API_KEY" ]; then
  gptcommit config set openai.api_key "$API_KEY"
fi

# 配置 GPTCommit 输出
gptcommit config set output.format conventional
if [ "$LANG" = "en" ]; then
  gptcommit config set output.lang en
else
  gptcommit config set output.lang zh-cn
fi
gptcommit config set output.conventional_commit true
gptcommit config set output.include_body true
gptcommit config set openai.model gpt-3.5-turbo
gptcommit install

# 生成 commit-msg 钩子（Conventional Commit 校验）
mkdir -p .git/hooks
cat <<'EOF' > .git/hooks/commit-msg
#!/usr/bin/env sh
set -e
MSGFILE="$1"
MSG=$(cat "$MSGFILE")
REGEX='^(feat|fix|docs|style|refactor|perf|test|chore): .+'
if ! echo "$MSG" | grep -Eq "$REGEX"; then
  echo "⧗ Invalid commit message format." >&2
  echo "   应符合: type: subject" >&2
  echo "   示例: feat: add new endpoint" >&2
  echo "   详情规范请看: https://github.com/tencent-international/specification/blob/main/README.md" >&2
  exit 1
fi
EOF
chmod +x .git/hooks/commit-msg

echo ""
echo "✅ GPTCommit 初始化完成！"
echo "   - GPTCommit 已配置"
echo "   - Conventional Commit 格式校验钩子已安装"
echo ""
