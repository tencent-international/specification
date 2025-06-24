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
gptcommit config set openai.temperature 0.2
gptcommit config set openai.retries 2
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

# 检查是否是重试标记文件
RETRY_FLAG_FILE=".git/gptcommit_retry_flag"

# 简单有效的清理函数
clean_markdown() {
  # 创建临时文件进行处理
  TEMP_FILE=$(mktemp)
  cp "$MSGFILE" "$TEMP_FILE"

  # 1. 移除独立的 ### 行
  sed -i.bak '/^[[:space:]]*###[[:space:]]*$/d' "$TEMP_FILE"

  # 2. 移除行首行尾的 ### 标记
  sed -i.bak 's/^[[:space:]]*###[[:space:]]*//' "$TEMP_FILE"
  sed -i.bak 's/[[:space:]]*###[[:space:]]*$//' "$TEMP_FILE"

  # 3. 移除 Markdown 标记
  sed -i.bak 's/\*\*//g' "$TEMP_FILE"  # 移除粗体
  sed -i.bak 's/\*//g' "$TEMP_FILE"   # 移除斜体

  # 4. 处理列表项
  # sed -i.bak 's/^[[:space:]]*[-*+][[:space:]]*/  /' "$TEMP_FILE"
  # 保留 - 列表标记，只清理多余的空格
  sed -i.bak 's/^[[:space:]]*[-*+][[:space:]]*/- /' "$TEMP_FILE"

  # 5. 移除文件开头的空行
  sed -i.bak '/./,$!d' "$TEMP_FILE"

  # 清理备份文件
  rm -f "${TEMP_FILE}.bak"

  # 6. 特殊处理：如果第一行是 "type:" 格式，尝试与第二行合并
  FIRST_LINE=$(head -n 1 "$TEMP_FILE")
  if echo "$FIRST_LINE" | grep -q '^[a-z]*([^)]*)?:[[:space:]]*$\|^[a-z]*:[[:space:]]*$'; then
    SECOND_LINE=$(sed -n '2p' "$TEMP_FILE" | sed 's/^[[:space:]]*//')
    if [ -n "$SECOND_LINE" ]; then
      # 合并第一行和第二行
      NEW_FIRST_LINE=$(echo "$FIRST_LINE" | sed 's/[[:space:]]*//')
      if [ -n "$NEW_FIRST_LINE" ]; then
        NEW_FIRST_LINE="$NEW_FIRST_LINE $SECOND_LINE"
        # 创建新文件
        echo "$NEW_FIRST_LINE" > "$MSGFILE"
        # 添加剩余行（从第3行开始）
        tail -n +3 "$TEMP_FILE" >> "$MSGFILE"
      fi
    fi
  else
    # 直接使用清理后的文件
    cp "$TEMP_FILE" "$MSGFILE"
  fi

  rm -f "$TEMP_FILE"
}

# 应用清理
clean_markdown

# 获取第一行进行验证
FIRST_LINE=$(head -n 1 "$MSGFILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# 如果第一行为空，尝试获取第一个非空行
if [ -z "$FIRST_LINE" ]; then
  FIRST_LINE=$(grep -m 1 -v '^[[:space:]]*$' "$MSGFILE" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
fi

# 验证格式
REGEX='^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\([^)]+\))?: .+'

if [ -z "$FIRST_LINE" ]; then
  echo "❌ Error: 提交信息为空" >&2
  exit 1
elif ! echo "$FIRST_LINE" | grep -Eq "$REGEX"; then
  # 检查是否已经重试过
  if [ -f "$RETRY_FLAG_FILE" ]; then
    # 已经重试过了，删除标记文件并显示错误
    rm -f "$RETRY_FLAG_FILE"
    echo "⧗ Invalid commit message format (已重试一次)." >&2
    echo "   应符合: type: subject 或 type(scope): subject" >&2
    echo "   当前第一行: $FIRST_LINE" >&2
    echo "" >&2
    echo "📝 完整的提交信息内容:" >&2
    echo "----------------------------------------" >&2
    cat "$MSGFILE" >&2
    echo "----------------------------------------" >&2
    echo "" >&2
    echo "   示例: feat: add new endpoint" >&2
    echo "   详情规范请看: https://github.com/tencent-international/specification/blob/main/README.md" >&2
    exit 1
  else
    # 第一次失败，创建重试标记并自动重试
    touch "$RETRY_FLAG_FILE"
    echo "⚠️  第一次 commit 格式不正确，正在自动重试..." >&2
    echo "   当前第一行: $FIRST_LINE" >&2
    echo "🔄 执行 gptcommit uninstall && gptcommit install..." >&2

    # 重新安装 gptcommit 钩子
    gptcommit uninstall > /dev/null 2>&1 || true
    gptcommit install > /dev/null 2>&1 || true

    echo "🔄 重新生成 commit 消息并重试..." >&2
    exit 1
  fi
fi

# 验证通过，清理重试标记文件
rm -f "$RETRY_FLAG_FILE"

echo "✅ Commit message cleaned and validated"
echo "   第一行: $FIRST_LINE"
EOF
chmod +x .git/hooks/commit-msg

echo ""
echo "✅ GPTCommit 初始化完成！"
echo "   - GPTCommit 已配置"
echo "   - Conventional Commit 格式校验钩子已安装"
echo "   - 增加自动重试机制：格式错误时自动重试一次"
echo ""
echo "🚀 使用方法："
echo "   - 运行 'make commit' 或 'bash scripts/smart-commit.sh'"
echo "   - 如果 commit 格式不正确，系统会自动重试一次"
echo "   - 重试仍失败时会显示详细错误信息"
echo ""
