#!/usr/bin/env bash
set -e

# 创建脚本目录
mkdir -p scripts

# 安装 goimports
echo "🔧 安装 goimports（如未安装）..."
if ! command -v goimports >/dev/null 2>&1; then
  echo "📦 正在安装 goimports v0.28.0..."
  go install golang.org/x/tools/cmd/goimports@v0.28.0
  echo "✅ goimports 安装完成"
else
  echo "✅ goimports 已安装"
fi

# 安装 golangci-lint
echo "🔧 安装 golangci-lint（如未安装）..."
if ! command -v golangci-lint >/dev/null 2>&1; then
  echo "📦 正在安装 golangci-lint v1.64.8..."
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.64.8
  echo "✅ golangci-lint 安装完成"
  echo "📝 确保 \$GOPATH/bin 在你的 PATH 中..."
  if [[ "$SHELL" == *"zsh"* ]]; then
    if ! grep -q 'export PATH=$PATH:$(go env GOPATH)/bin' ~/.zshrc; then
      echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.zshrc
      echo "✅ 已添加 Go bin 目录到 ~/.zshrc，请运行 'source ~/.zshrc' 或重启终端"
    fi
  elif [[ "$SHELL" == *"bash"* ]]; then
    if ! grep -q 'export PATH=$PATH:$(go env GOPATH)/bin' ~/.bashrc; then
      echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
      echo "✅ 已添加 Go bin 目录到 ~/.bashrc，请运行 'source ~/.bashrc' 或重启终端"
    fi
  fi
else
  echo "✅ golangci-lint 已安装 ($(golangci-lint --version | head -n1))"
fi

# 生成 .editorconfig
cat <<EOF > .editorconfig
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

# 生成 .golangci.yml (v1 格式兼容)
cat <<EOF > .golangci.yml
run:
  timeout: 2m
  modules-download-mode: readonly

linters:
  disable-all: true
  enable:
    - errcheck
    - govet
    - ineffassign
    - misspell
    - staticcheck

issues:
  exclude-use-default: false
EOF

# 生成 Makefile
cat <<EOF > Makefile
.PHONY: commit lint format
commit:
	bash scripts/smart-commit.sh auto=yes
lint:
	golangci-lint run --config .golangci.yml
format:
	gofmt -s -w .
	goimports -w .
pr:
	@if [ ! -f scripts/bitbucket-pr.sh ]; then \
		echo "❌ 错误: 找不到 scripts/bitbucket-pr.sh 脚本文件"; \
		echo ""; \
		echo "📁 请将 bitbucket-pr.sh 脚本放置到项目根目录的 scripts/ 文件夹下:"; \
		echo "   mkdir -p scripts"; \
		echo "   cp /path/to/bitbucket-pr.sh scripts/"; \
		echo "   chmod +x scripts/bitbucket-pr.sh"; \
		echo ""; \
		echo "💡 或者从以下位置获取脚本:"; \
		echo "   https://github.com/tencent-international/specification/blob/main/commits/bitbucket-pr.sh"; \
		echo ""; \
		exit 1; \
	else \
		bash scripts/bitbucket-pr.sh; \
	fi
EOF

# 生成 Go 智能提交脚本
cat <<'EOF' > scripts/smart-commit.sh
#!/usr/bin/env bash
set -e

# 检查并处理 Submodule 改动的函数
handle_submodules() {
  echo "🔍 检查 Submodule 状态..."

  # 获取所有 submodule 的状态
  local submodule_status=$(git submodule status 2>/dev/null || echo "")

  if [ -z "$submodule_status" ]; then
    echo "📝 未检测到 submodule"
    return 0
  fi

  echo "📦 发现以下 submodule:"
  git submodule status | while read line; do
    echo "  $line"
  done

  # 检查每个 submodule 是否有未提交的改动
  local has_submodule_changes=false

  git submodule foreach --quiet 'if [ -n "$(git status --porcelain)" ]; then echo "📝 Submodule $name 有未提交的改动:"; git status --short | sed "s/^/    /"; echo ""; fi' | tee /tmp/submodule_changes.txt

  if [ -s /tmp/submodule_changes.txt ]; then
    has_submodule_changes=true
    echo "⚠️  发现 submodule 中有未提交的改动"
    cat /tmp/submodule_changes.txt

    read -p "🔄 是否处理 submodule 中的改动？(Y/n, 默认 Y): " HANDLE_SUBMODULES
    HANDLE_SUBMODULES=${HANDLE_SUBMODULES:-y}

    if [[ "$HANDLE_SUBMODULES" =~ ^[Yy]$ ]]; then
      echo "🚀 开始处理 submodule 改动..."

      # 获取所有 submodule 路径
      git submodule status | while read -r line; do
        # 从输出中提取路径 (格式: " <hash> <path> (<branch>)")
        path=$(echo "$line" | awk '{print $2}')

        if [ -d "$path" ] && [ -n "$(cd "$path" && git status --porcelain 2>/dev/null)" ]; then
          echo ""
          echo "🔧 处理 submodule: $(basename "$path")"
          echo "  路径: $path"

          # 进入 submodule 目录
          cd "$path"

          # 显示改动文件
          echo "  📝 改动文件:"
          git status --short | sed 's/^/       /'
          echo ""

          # 格式化 Go 代码（如果需要）
          if [[ "$FORMAT_CONFIRM" =~ ^[Yy]$ ]]; then
            if command -v gofmt >/dev/null 2>&1; then
              echo "  🎨 格式化 Go 代码..."
              gofmt -s -w . 2>/dev/null || true
              if command -v goimports >/dev/null 2>&1; then
                goimports -w . 2>/dev/null || true
              fi
            fi
          fi

          # 添加所有改动
          git add .

          # 尝试使用 gptcommit 提交
          local commit_success=false
          if command -v gptcommit >/dev/null 2>&1; then
            echo "  🤖 尝试使用 GPTCommit 生成提交信息..."

            # 检查是否已安装 GPTCommit 钩子
            local git_hooks_dir="../.git/modules/$(basename "$path")/hooks"
            if [ ! -f "$git_hooks_dir/prepare-commit-msg" ]; then
              echo "  🔧 临时配置 GPTCommit..."
              
              # 临时为 submodule 配置 gptcommit（如果主项目有配置）
              local main_api_key=$(cd .. && gptcommit config get openai.api_key 2>/dev/null || echo "")
              if [ -n "$main_api_key" ]; then
                gptcommit config set openai.api_key "$main_api_key" >/dev/null 2>&1 || true
                gptcommit config set output.format conventional >/dev/null 2>&1 || true
                gptcommit config set output.lang zh-cn >/dev/null 2>&1 || true
                gptcommit config set openai.model gpt-3.5-turbo >/dev/null 2>&1 || true
                gptcommit config set openai.temperature 0.2 >/dev/null 2>&1 || true
                
                # 临时安装 GPTCommit 钩子
                gptcommit install >/dev/null 2>&1 || true
                echo "    - 临时安装 GPTCommit 钩子"
              else
                echo "    - ⚠️  主项目中未找到 GPTCommit 配置"
              fi
            fi

            # 使用 git commit 触发 GPTCommit 钩子
            if git commit --quiet --no-edit 2>/dev/null; then
              local commit_msg=$(git log -1 --pretty=format:"%s")
              echo "  ✅ GPTCommit 提交成功: $commit_msg"
              commit_success=true
            else
              echo "  ❌ GPTCommit 失败，使用默认提交信息"
              git commit -m "chore: update submodule $(basename "$path")" --quiet
              echo "  ✅ 使用默认提交信息提交完成"
              commit_success=true
            fi
          else
            echo "  📝 GPTCommit 未安装，使用默认提交信息"
            git commit -m "chore: update submodule $(basename "$path")" --quiet
            echo "  ✅ 使用默认提交信息提交完成"
            commit_success=true
          fi

          # 返回主项目目录
          cd - >/dev/null

          echo "  ✅ Submodule $(basename "$path") 处理完成"
        fi
      done
    else
      echo "⚠️  跳过处理 submodule 改动"
    fi
  else
    echo "✅ 所有 submodule 都是干净的"
  fi

  # 清理临时文件
  rm -f /tmp/submodule_changes.txt

  # 检查主项目是否需要更新 submodule 引用
  if git diff --quiet --cached --submodule=short; then
    echo "📝 主项目中的 submodule 引用无需更新"
  else
    echo "🔄 检测到 submodule 引用需要更新，将包含在主项目提交中"
  fi
}

# 主程序开始
echo "🚀 智能提交脚本启动..."

# Step 0: 处理 Submodule 改动
handle_submodules

echo ""
read -p "✨ 是否需要格式化 Go 代码？(y/N, 默认 N): " FORMAT_CONFIRM
FORMAT_CONFIRM=${FORMAT_CONFIRM:-n}
if [[ "$FORMAT_CONFIRM" =~ ^[Yy]$ ]]; then
  echo -e "\n✨ Step 1: 检查并格式化 Go 代码 (gofmt + goimports)..."
  UNFMT=$(gofmt -l .)
  if [ -n "$UNFMT" ]; then
    echo "🛠 发现以下文件未按 gofmt 格式化："
    echo "$UNFMT" | sed 's/^/  - /'
    echo "🚀 自动执行：gofmt -s -w"
    gofmt -s -w .
    echo "✅ gofmt 已完成格式化："
    echo "$UNFMT" | sed 's/^/  - /'
  fi
  echo "🚀 执行：goimports -w"
  goimports -w .
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

echo ""
echo "🤖 Step 3: 调用 GPTCommit 生成提交信息并提交主项目..."

# 检查是否有需要提交的改动
if git diff --cached --quiet; then
  echo "📝 主项目没有需要提交的改动"
else
  git commit --quiet --no-edit
  echo "✅ 主项目提交完成"
fi

echo ""
echo "🎉 所有提交完成！"
echo "📊 提交摘要："
echo "  - Submodule 改动已处理"
echo "  - 主项目改动已提交"
EOF

chmod +x scripts/smart-commit.sh

# 生成 submodule GPTCommit 配置脚本
cat <<'EOF' > scripts/setup-submodule-gptcommit.sh
#!/usr/bin/env bash
set -e

echo "🔧 配置 Submodule GPTCommit..."

# 检查是否有 submodule
if [ -z "$(git submodule status 2>/dev/null)" ]; then
  echo "📝 未检测到 submodule"
  exit 0
fi

# 检查主项目 GPTCommit 配置
echo "🔍 检查主项目 GPTCommit 配置..."
if ! command -v gptcommit >/dev/null 2>&1; then
  echo "❌ GPTCommit 未安装，请先运行 gptcommit-init.sh"
  exit 1
fi

main_api_key=$(gptcommit config get openai.api_key 2>/dev/null || echo "")
if [ -z "$main_api_key" ]; then
  echo "❌ 主项目中未找到 GPTCommit API Key，请先配置主项目"
  exit 1
fi

echo "✅ 主项目 GPTCommit 配置正常"

# 为每个 submodule 配置 GPTCommit
git submodule status | while read -r line; do
  path=$(echo "$line" | awk '{print $2}')
  
  if [ -d "$path" ]; then
    echo ""
    echo "🔧 配置 submodule: $(basename "$path")"
    echo "  路径: $path"
    
    # 进入 submodule 目录
    cd "$path"
    
    # 配置 GPTCommit
    echo "  🔑 配置 GPTCommit..."
    gptcommit config set openai.api_key "$main_api_key"
    gptcommit config set output.format conventional
    gptcommit config set output.lang zh-cn
    gptcommit config set openai.model gpt-3.5-turbo
    gptcommit config set openai.temperature 0.2
    
    # 安装 GPTCommit 钩子
    echo "  🔗 安装 GPTCommit 钩子..."
    gptcommit install
    
    echo "  ✅ Submodule $(basename "$path") GPTCommit 配置完成"
    
    # 返回主项目目录
    cd - >/dev/null
  fi
done

echo ""
echo "🎉 所有 Submodule GPTCommit 配置完成！"
echo ""
echo "💡 使用方法："
echo "   - 运行 'make commit' 现在可自动处理 submodule 改动"
echo "   - 新增 submodule 时，运行 'bash scripts/setup-submodule-gptcommit.sh' 重新配置"
EOF

chmod +x scripts/setup-submodule-gptcommit.sh

# 询问是否立即配置现有的 submodule
if [ -n "$(git submodule status 2>/dev/null)" ]; then
  echo ""
  echo "🔍 检测到现有的 submodule"
  read -p "🔧 是否立即为现有 submodule 配置 GPTCommit？(Y/n, 默认 Y): " SETUP_SUBMODULES
  SETUP_SUBMODULES=${SETUP_SUBMODULES:-y}
  
  if [[ "$SETUP_SUBMODULES" =~ ^[Yy]$ ]]; then
    echo "🚀 开始配置 submodule GPTCommit..."
    bash scripts/setup-submodule-gptcommit.sh
  else
    echo "⚠️  跳过 submodule GPTCommit 配置"
    echo "💡 稍后可运行 'bash scripts/setup-submodule-gptcommit.sh' 手动配置"
  fi
fi

echo ""
echo "✅ Go Lint/格式化脚本与配置初始化完成！"
echo "   - .editorconfig"
echo "   - .golangci.yml (v1 格式兼容)"
echo "   - scripts/smart-commit.sh"
echo "   - scripts/setup-submodule-gptcommit.sh (新增)"
echo "   - Makefile"
echo ""
echo "📝 注意："
echo "   - 使用 go install 安装 golangci-lint 而非 brew"
echo "   - 已自动配置 PATH 环境变量"
echo "   - 生成的 .golangci.yml 采用 v1 格式兼容"
echo "   - Submodule GPTCommit 已配置（如果存在）"
echo "   - 建议重启终端或运行 'source ~/.zshrc' 来应用 PATH 更改"
echo ""
