#!/usr/bin/env bash
set -e

# 不好用,不推荐
# 选择语言
read -p "请选择 GitHub Copilot 输出语言 [cn/en，默认 cn]: " LANG_CHOICE
LANG=${LANG_CHOICE:-cn}

# 安装 GitHub CLI（如未安装）
echo "🔧 检查并安装 GitHub CLI..."
if ! command -v gh >/dev/null 2>&1; then
  echo "安装 GitHub CLI..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install gh
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Ubuntu/Debian
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh
  else
    echo "❌ 不支持的操作系统，请手动安装 GitHub CLI"
    exit 1
  fi
fi

# 安装 GitHub Copilot CLI 扩展
echo "🤖 安装 GitHub Copilot CLI 扩展..."
gh extension install github/gh-copilot || echo "扩展可能已安装"

# 登录 GitHub（如未登录）
echo "🔑 检查 GitHub 登录状态..."
if ! gh auth status >/dev/null 2>&1; then
  echo "请登录 GitHub..."
  gh auth login
fi

# 检测项目中的 lint 工具
echo "🔍 检测项目中的 lint 工具..."
LINT_TOOLS=()

# 检测不同语言的 lint 工具
if [ -f "package.json" ]; then
  if grep -q "eslint" package.json; then
    LINT_TOOLS+=("eslint")
  fi
  if grep -q "prettier" package.json; then
    LINT_TOOLS+=("prettier")
  fi
  if grep -q "stylelint" package.json; then
    LINT_TOOLS+=("stylelint")
  fi
fi

if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
  if command -v flake8 >/dev/null 2>&1; then
    LINT_TOOLS+=("flake8")
  fi
  if command -v black >/dev/null 2>&1; then
    LINT_TOOLS+=("black")
  fi
  if command -v isort >/dev/null 2>&1; then
    LINT_TOOLS+=("isort")
  fi
fi

if [ -f "Cargo.toml" ]; then
  if command -v clippy >/dev/null 2>&1; then
    LINT_TOOLS+=("clippy")
  fi
  if command -v rustfmt >/dev/null 2>&1; then
    LINT_TOOLS+=("rustfmt")
  fi
fi

if [ -f "go.mod" ]; then
  if command -v golangci-lint >/dev/null 2>&1; then
    LINT_TOOLS+=("golangci-lint")
  fi
  if command -v gofmt >/dev/null 2>&1; then
    LINT_TOOLS+=("gofmt")
  fi
fi

echo "检测到的 lint 工具: ${LINT_TOOLS[*]}"

# 生成 prepare-commit-msg 钩子（自动生成提交信息）
mkdir -p .git/hooks
cat <<EOF > .git/hooks/prepare-commit-msg
#!/usr/bin/env bash
set -e

COMMIT_MSG_FILE="\$1"
COMMIT_SOURCE="\$2"
SHA1="\$3"

# 只在没有提交源的情况下生成（即用户没有使用 -m 参数）
if [ -z "\$COMMIT_SOURCE" ] || [ "\$COMMIT_SOURCE" = "template" ]; then
  # 检查是否有暂存的更改
  if ! git diff --cached --quiet; then
    echo "🤖 使用 GitHub Copilot 生成提交信息..."
    
    # 获取暂存的更改统计
    STAGED_DIFF=\$(git diff --cached --stat)

    # 尝试使用 GitHub Copilot 生成提交信息
    if command -v gh >/dev/null 2>&1 && gh extension list | grep -q copilot; then
      # 构建提示
      if [ "$LANG" = "en" ]; then
        PROMPT="Generate a conventional commit message for these changes. Only output the commit message, no explanations:\n\n\$STAGED_DIFF"
      else
        PROMPT="为以下更改生成一个符合 Conventional Commit 规范的提交信息，只输出提交信息，不要解释:\n\n\$STAGED_DIFF"
      fi

      # 尝试生成提交信息
      GENERATED_MSG=\$(echo "\$PROMPT" | gh copilot suggest -t shell 2>/dev/null | head -1 | sed 's/^[[:space:]]*//' || echo "")

      # 如果生成失败或格式不对，使用简单推断
      if [ -z "\$GENERATED_MSG" ] || ! echo "\$GENERATED_MSG" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|chore)(\([^)]+\))?: .+'; then
        # 基于文件变更类型生成
        ADDED_FILES=\$(git diff --cached --name-only --diff-filter=A | wc -l | tr -d ' ')
        MODIFIED_FILES=\$(git diff --cached --name-only --diff-filter=M | wc -l | tr -d ' ')
        DELETED_FILES=\$(git diff --cached --name-only --diff-filter=D | wc -l | tr -d ' ')

        if [ "$LANG" = "en" ]; then
          if [ "\$ADDED_FILES" -gt 0 ] && [ "\$MODIFIED_FILES" -eq 0 ] && [ "\$DELETED_FILES" -eq 0 ]; then
            GENERATED_MSG="feat: add new files"
          elif [ "\$DELETED_FILES" -gt 0 ] && [ "\$ADDED_FILES" -eq 0 ] && [ "\$MODIFIED_FILES" -eq 0 ]; then
            GENERATED_MSG="chore: remove files"
          elif [ "\$MODIFIED_FILES" -gt 0 ]; then
            GENERATED_MSG="fix: update existing files"
          else
            GENERATED_MSG="chore: update project files"
          fi
        else
          if [ "\$ADDED_FILES" -gt 0 ] && [ "\$MODIFIED_FILES" -eq 0 ] && [ "\$DELETED_FILES" -eq 0 ]; then
            GENERATED_MSG="feat: 添加新文件"
          elif [ "\$DELETED_FILES" -gt 0 ] && [ "\$ADDED_FILES" -eq 0 ] && [ "\$MODIFIED_FILES" -eq 0 ]; then
            GENERATED_MSG="chore: 删除文件"
          elif [ "\$MODIFIED_FILES" -gt 0 ]; then
            GENERATED_MSG="fix: 更新现有文件"
          else
            GENERATED_MSG="chore: 更新项目文件"
          fi
        fi
      fi

      # 将生成的信息写入提交文件
      if [ -n "\$GENERATED_MSG" ]; then
        echo "\$GENERATED_MSG" > "\$COMMIT_MSG_FILE"
        echo "✅ 已生成提交信息: \$GENERATED_MSG"
      fi
    else
      echo "⚠️  GitHub Copilot 不可用，跳过自动生成"
    fi
  fi
fi
EOF
chmod +x .git/hooks/prepare-commit-msg

# 生成 commit-msg 钩子（Conventional Commit 校验）
cat <<'EOF' > .git/hooks/commit-msg
#!/usr/bin/env bash
set -e

MSGFILE="$1"

# 获取第一行进行验证
FIRST_LINE=$(head -n 1 "$MSGFILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$FIRST_LINE" ]; then
  FIRST_LINE=$(grep -m 1 -v '^[[:space:]]*$' "$MSGFILE" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")
fi

# 验证 Conventional Commit 格式
REGEX='^(feat|fix|docs|style|refactor|perf|test|chore)(\([^)]+\))?: .+'

if [ -z "$FIRST_LINE" ]; then
  echo "❌ Error: 提交信息为空" >&2
  exit 1
elif ! echo "$FIRST_LINE" | grep -Eq "$REGEX"; then
  echo "⧗ Invalid commit message format." >&2
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
fi

echo "✅ Commit message validated (GitHub Copilot)"
echo "   第一行: $FIRST_LINE"
EOF
chmod +x .git/hooks/commit-msg

# 创建 lint 集成脚本（如果检测到 lint 工具）
if [ ${#LINT_TOOLS[@]} -gt 0 ]; then
  cat <<EOF > .git/hooks/pre-commit-lint
#!/usr/bin/env bash
set -e

# 获取暂存的文件
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "\$STAGED_FILES" ]; then
  echo "⚠️  没有暂存的文件"
  exit 0
fi

echo "🔍 运行 lint 检查..."

# 运行检测到的 lint 工具
EOF

  for tool in "${LINT_TOOLS[@]}"; do
    case "$tool" in
      "eslint")
        cat <<'EOF' >> .git/hooks/pre-commit-lint
if command -v eslint >/dev/null 2>&1; then
  echo "📝 运行 ESLint..."
  echo "$STAGED_FILES" | grep -E '\.(js|jsx|ts|tsx)$' | xargs eslint --fix || exit 1
fi
EOF
        ;;
      "prettier")
        cat <<'EOF' >> .git/hooks/pre-commit-lint
if command -v prettier >/dev/null 2>&1; then
  echo "💅 运行 Prettier..."
  echo "$STAGED_FILES" | xargs prettier --write || exit 1
fi
EOF
        ;;
      "black")
        cat <<'EOF' >> .git/hooks/pre-commit-lint
if command -v black >/dev/null 2>&1; then
  echo "🐍 运行 Black..."
  echo "$STAGED_FILES" | grep -E '\.py$' | xargs black || exit 1
fi
EOF
        ;;
      "flake8")
        cat <<'EOF' >> .git/hooks/pre-commit-lint
if command -v flake8 >/dev/null 2>&1; then
  echo "🔍 运行 Flake8..."
  echo "$STAGED_FILES" | grep -E '\.py$' | xargs flake8 || exit 1
fi
EOF
        ;;
      "clippy")
        cat <<'EOF' >> .git/hooks/pre-commit-lint
if command -v cargo >/dev/null 2>&1; then
  echo "🦀 运行 Clippy..."
  cargo clippy -- -D warnings || exit 1
fi
EOF
        ;;
      "rustfmt")
        cat <<'EOF' >> .git/hooks/pre-commit-lint
if command -v rustfmt >/dev/null 2>&1; then
  echo "🦀 运行 rustfmt..."
  echo "$STAGED_FILES" | grep -E '\.rs$' | xargs rustfmt || exit 1
fi
EOF
        ;;
      "gofmt")
        cat <<'EOF' >> .git/hooks/pre-commit-lint
if command -v gofmt >/dev/null 2>&1; then
  echo "🐹 运行 gofmt..."
  echo "$STAGED_FILES" | grep -E '\.go$' | xargs gofmt -w || exit 1
fi
EOF
        ;;
      "golangci-lint")
        cat <<'EOF' >> .git/hooks/pre-commit-lint
if command -v golangci-lint >/dev/null 2>&1; then
  echo "🐹 运行 golangci-lint..."
  golangci-lint run || exit 1
fi
EOF
        ;;
    esac
  done

  cat <<'EOF' >> .git/hooks/pre-commit-lint

# 重新添加修改过的文件到暂存区
git add $STAGED_FILES

echo "✅ Lint 检查完成"
EOF
  chmod +x .git/hooks/pre-commit-lint
fi

echo ""
echo "✅ GitHub Copilot 初始化完成！"
echo "   - GitHub CLI 和 Copilot 扩展已安装"
echo "   - Conventional Commit 格式校验钩子已安装"
echo "   - 自动提交信息生成功能已启用"
if [ ${#LINT_TOOLS[@]} -gt 0 ]; then
  echo "   - 检测到的 lint 工具: ${LINT_TOOLS[*]}"
  echo ""
  echo "🔗 要启用 pre-commit lint 检查，请运行："
  echo "   ln -sf \$(pwd)/.git/hooks/pre-commit-lint .git/hooks/pre-commit"
fi
echo ""
echo "🤖 现在可以使用以下方式提交："
echo "   git add ."
echo "   git commit --quiet --no-edit  # 自动生成提交信息"
echo "   # 或者"
echo "   git commit -m 'feat: your message'  # 手动输入提交信息"
echo ""
