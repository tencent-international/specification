#!/usr/bin/env bash
set -e

# ─── Step 0：选择语言 ────────────────────────────────────
read -p "请选择语言 [cn/en，默认 cn]: " LANG_CHOICE
LANG=${LANG_CHOICE:-cn}

# ─── Step 1：创建基础目录 ────────────────────────────────────
mkdir -p scripts

# ─── Step 2：安装必要工具 ────────────────────────────────────
echo "🔧 安装 goimports（如果未安装）..."
if ! command -v goimports >/dev/null 2>&1; then
  brew install goimports || true
fi

echo "🔧 安装 golangci-lint（通过 brew，如果未安装）..."
if ! command -v golangci-lint >/dev/null 2>&1; then
  brew install golangci-lint || true
fi

echo "🔧 安装 gptcommit（如果未安装）... 你需要先把 macOS 的命令行工具（Command Line Tools for Xcode）更新到至少 16.0"
if ! command -v gptcommit >/dev/null 2>&1; then
  brew install zurawiki/brews/gptcommit
fi

# ─── Step 3：配置 GPTCommit ────────────────────────────────────
echo "🔑 设置 OpenAI API Key"
read -p "请输入你的 OpenAI API Key（sk-xxx，回车可跳过后手动设置）: " API_KEY
if [ -n "$API_KEY" ]; then
  gptcommit config set openai.api_key "$API_KEY"
fi
gptcommit config set output.format conventional
# 设置语言字段
if [ "$LANG" = "en" ]; then
  gptcommit config set output.lang en
else
  gptcommit config set output.lang zh-cn
fi
gptcommit install

# ─── Step 4：生成 .editorconfig ────────────────────────────────────
cat <<EOF > .editorconfig
# EditorConfig 帮助不同编辑器统一基本风格

root = true

[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
trim_trailing_whitespace = true

[*.go]
indent_style = tab
indent_size = 4
EOF

# ─── Step 5：生成 .golangci.yml ────────────────────────────────────
cat <<EOF > .golangci.yml
version: "2"

run:
  timeout: 2m

linters:
  default: none
  enable:
    # 检查未处理的 error
    - errcheck
    # Go 官方静态检查，发现代码潜在错误
    - govet
    # 检查无效赋值（赋值后未使用）
    - ineffassign
    # 检查拼写错误，代码/注释都查
    - misspell
    # 功能强大的代码质量与错误检测，规则多，能查性能和安全问题
    - staticcheck

#    # 接下来是一些进阶版的规则,可有可无
#    # 检查函数/方法的圈复杂度，帮助代码简单化
#    - gocyclo
#    # - gofmt 检查代码是否未格式化,这个linter有bug,找了其他代替品,如果不需要我们就去除
#    # 检查 import 语句分组和排序
#    - goimports
#    # 官方代码风格建议，注重注释和命名规范
#    - golint
#    # 检查重复出现的字符串常量是否可提取为常量
#    - goconst
#    # 检查函数签名是否可用 interface 优化
#    - interfacer
#    # 检查 HTTP 响应体是否被关闭
#    - bodyclose

issues:
  exclude-use-default: false

EOF

# ─── Step 6：设置 gptcommit config）────────────────────────────
#gptcommit config set openai.model gpt-3.5-turbo
#gptcommit config set openai.model gpt-4o
#gptcommit config set openai.model gpt-4-turbo
#gptcommit config set openai.model gpt-4
#gptcommit config set openai.model gpt-3.5-turbo-instruct
gptcommit uninstall
gptcommit install
gptcommit config set openai.model gpt-3.5-turbo
gptcommit config set output.format conventional
gptcommit config set output.conventional_commit true
gptcommit config set output.include_body true

# ─── Step 7：生成 Makefile ────────────────────────────────────
cat <<EOF > Makefile
.PHONY: commit

commit:
	bash scripts/smart-commit.sh auto=yes
EOF

# ─── Step 8：生成智能提交脚本 scripts/smart-commit.sh ───────────────
cat <<'EOF' > scripts/smart-commit.sh
#!/usr/bin/env bash
set -e

# Step 0: 确认是否执行 Go 代码格式化
read -p "✨ 是否需要格式化 Go 代码？(y/N, 默认 N): " FORMAT_CONFIRM
FORMAT_CONFIRM=${FORMAT_CONFIRM:-n}

if [[ "$FORMAT_CONFIRM" =~ ^[Yy]$ ]]; then
  echo -e "\n✨ Step 1: 检查并格式化 Go 代码 (gofmt + goimports)..."
  # 1.1 检测 gofmt 未格式化文件
  UNFMT=$(gofmt -l .)
  if [ -n "$UNFMT" ]; then
    echo "🛠 发现以下文件未按 gofmt 格式化："
    echo "$UNFMT" | sed 's/^/  - /'
    echo "🚀 自动执行：gofmt -s -w"
    gofmt -s -w .
    echo "✅ gofmt 已完成格式化："
    echo "$UNFMT" | sed 's/^/  - /'
  fi

  # 1.2 执行 goimports
  echo "🚀 执行：goimports -w"
  goimports -w .

  # 1.3 格式化后如果有文件变更，自动 git add
  if [ -n "$(git diff --name-only)" ]; then
    echo "📦 格式化后检测到文件变更，自动执行 git add ."
    git add .
  else
    echo "✅ Go 代码已格式化且无新变更"
  fi
else
  echo "跳过 Go 代码格式化。"
  if [ -n "$(git diff --name-only)" ]; then
    echo "📦 检测到文件变更，自动执行 git add ."
    git add .
  fi
fi

# Step 2: Lint 检查 & 可选自动修复
echo ""
echo "🔍 Step 2: 运行 golangci-lint 检查..."
if ! golangci-lint run --config .golangci.yml; then
  echo "⛔ Lint 检查失败"
  read -p "🛠 是否尝试自动修复？(Y/n,回车默认Y): " FIX_CONFIRM
  FIX_CONFIRM=${FIX_CONFIRM:-y}
  if [[ "$FIX_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "🔧 执行：golangci-lint run --fix"
    golangci-lint run --fix --config .golangci.yml || true
    echo "⚠️ 自动修复有局限性请注意!"
    echo "✅ 自动修复完成，建议检查差异："
    git diff
    echo "📦 自动暂存修复后的文件..."
    git add .
  else
    echo "⚠️ 跳过自动修复"
  fi
else
  echo "✅ Step 2: Lint 检查通过"
fi

# Step 3: 调用 GPTCommit 自动生成提交信息并提交
echo ""
echo "🤖 Step 3: 调用 GPTCommit 生成提交信息并提交..."
git commit --quiet --no-edit

echo ""
echo "🎉 提交完成！"
EOF

chmod +x scripts/smart-commit.sh

# ─── Step 9：生成 commit-msg 钩子（Conventional Commit 校验）────────────────
mkdir -p .git/hooks
cat <<'EOF' > .git/hooks/commit-msg
#!/usr/bin/env sh
set -e

MSGFILE="$1"
MSG=$(cat "$MSGFILE")

# 格式要求：type: subject
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

# ─── 完成提示 ────────────────────────────────────
echo ""
echo "✅ 初始化完成！"
echo "   - 编辑器已启用 .editorconfig 统一缩进/换行规则"
echo "   - Lint 配置文件: .golangci.yml"
echo "   - GPTCommit 配置: .gpt-commit.yaml"
echo "   - 提交脚本: scripts/smart-commit.sh"
echo "   - commit-msg 钩子校验 Conventional Commit"
echo ""
echo "使用方式："
echo "  1. 修改/添加代码"
echo "  2. 运行 \`make commit\`"
echo "     → Step 1-2 自动格式化 + Lint + GPT 生成提交信息"
echo ""
echo "Happy Coding! 🚀"
