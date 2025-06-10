# Commit 工具初始化脚本

本目录包含三个 commit 工具初始化脚本，用于规范化 Git 提交信息格式。

## 脚本说明

### 1. gptcommit-init.sh
- **功能**: 安装并配置 GPTCommit 工具
- **特点**: 使用 OpenAI API 自动生成符合 Conventional Commit 规范的提交信息
- **依赖**: Homebrew 和 OpenAI API Key
- **自动生成**: 支持 `git commit --quiet --no-edit` 自动生成提交信息

### 2. gh-copilot-init.sh  
- **功能**: 安装并配置 GitHub Copilot CLI
- **特点**: 集成 GitHub Copilot，支持多语言 lint 工具检测
- **依赖**: GitHub CLI 和 Copilot 订阅
- **自动生成**: 支持 `git commit --quiet --no-edit` 自动生成提交信息

### 3. open-commit-init.sh
- **功能**: 安装并配置 OpenCommit 工具
- **特点**: 使用 OpenAI API，专门为 git 提交信息优化的 AI 工具
- **依赖**: Node.js/npm 和 OpenAI API Key
- **自动生成**: 支持 `git commit --quiet --no-edit` 自动生成提交信息
- **注意**: OpenCommit 官方只通过 npm 分发，没有 Homebrew 包

## 为什么 OpenCommit 不使用 Homebrew？

OpenCommit 是基于 Node.js 开发的工具，官方选择通过 npm 分发而不是 Homebrew，原因包括：

1. **跨平台统一**: npm 在 Windows、Linux、macOS 上都可用
2. **生态系统**: 作为 Node.js 工具，npm 是其天然的包管理器
3. **版本管理**: npm 提供更好的依赖管理和版本控制
4. **开发便利**: 工具本身使用 JavaScript/TypeScript 开发

如果你更喜欢 Homebrew 风格的安装，可以通过以下方式安装 Node.js：
```bash
brew install node  # 这会同时安装 npm
npm install -g opencommit  # 然后通过 npm 安装 OpenCommit
```

## 工具切换

三个脚本通过覆盖 Git hooks 实现切换：

```bash
# 使用 GPTCommit
./commits/gptcommit-init.sh       # 覆盖 hooks，切换到 GPTCommit 模式

# 使用 GitHub Copilot  
./commits/gh-copilot-init.sh      # 覆盖 hooks，切换到 Copilot 模式

# 使用 OpenCommit
./commits/open-commit-init.sh     # 覆盖 hooks，切换到 OpenCommit 模式
```

## 主要功能

### 🤖 自动生成提交信息
三个脚本都支持智能生成提交信息：

```bash
# 方式一：自动生成（推荐）
git add .
git commit --quiet --no-edit  # 自动分析变更并生成提交信息

# 方式二：手动输入
git add .
git commit -m "feat: add new feature"

# 方式三：交互式编辑
git add .
git commit  # 打开编辑器，可以修改自动生成的信息
```

### 🔍 自动 Lint 检测
`gh-copilot-init.sh` 自动检测项目中的 lint 工具并集成：

| 语言 | 支持的工具 |
|------|------------|
| JavaScript/TypeScript | ESLint, Prettier, Stylelint |
| Python | Black, Flake8, isort |
| Rust | Clippy, rustfmt |
| Go | golangci-lint, gofmt |

### 📝 Conventional Commit 验证
三种模式都支持 Conventional Commit 格式验证：
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式化
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

## 使用步骤

### 方式一：使用 GPTCommit

1. 运行初始化脚本：
```bash
./commits/gptcommit-init.sh
```

2. 输入 OpenAI API Key 和语言偏好

3. 使用智能提交：
```bash
git add .
git commit --quiet --no-edit  # 自动分析并生成提交信息
```

### 方式二：使用 GitHub Copilot

1. 运行初始化脚本：
```bash
./commits/gh-copilot-init.sh
```

2. 登录 GitHub 账号

3. 使用智能提交：
```bash
git add .
git commit --quiet --no-edit  # 自动分析并生成提交信息
```

4. 启用 pre-commit lint 检查（可选）：
```bash
ln -sf $(pwd)/.git/hooks/pre-commit-lint .git/hooks/pre-commit
```

### 方式三：使用 OpenCommit

1. 确保已安装 Node.js 和 npm/yarn/pnpm

2. 运行初始化脚本：
```bash
./commits/open-commit-init.sh
```

3. 输入 OpenAI API Key 和语言偏好

4. 使用智能提交：
```bash
git add .
git commit --quiet --no-edit  # 自动分析并生成提交信息
```

## 提交信息生成策略

### GPTCommit 模式
- 使用 OpenAI GPT 模型分析代码变更
- 基于上下文和语义理解生成精准的提交信息
- 支持中英文输出
- 生成质量较高，但需要 API 费用

### GitHub Copilot 模式  
- 优先使用 GitHub Copilot 建议
- 如果 Copilot 不可用，使用基于文件变更的智能推断
- 支持中英文输出
- 免费使用（需要 Copilot 订阅）
- 额外提供 lint 工具集成

### OpenCommit 模式
- 专门为 git 提交信息设计的 AI 工具
- 使用 OpenAI API，针对代码变更优化
- 支持多种配置选项和提示模板
- 生成质量高且稳定
- 需要 Node.js 环境和 OpenAI API Key

## Git Hooks

脚本会创建以下 Git hooks：

### GPTCommit 模式
- **commit-msg**: GPTCommit 的 markdown 清理和 Conventional Commit 验证

### GitHub Copilot 模式
- **prepare-commit-msg**: 自动生成提交信息（支持 `git commit --quiet --no-edit`）
- **commit-msg**: Conventional Commit 格式验证
- **pre-commit-lint**: 运行 lint 检查（可选启用）

### OpenCommit 模式
- **prepare-commit-msg**: 使用 OpenCommit 自动生成提交信息
- **commit-msg**: Markdown 清理和 Conventional Commit 验证

## 工具对比

| 特性 | GPTCommit | GitHub Copilot | OpenCommit |
|------|-----------|----------------|------------|
| 安装方式 | Homebrew | GitHub CLI 扩展 | npm/yarn/pnpm |
| API 依赖 | OpenAI | GitHub Copilot | OpenAI |
| 专业性 | Git 提交专用 | 通用命令行助手 | Git 提交专用 |
| 配置复杂度 | 中等 | 简单 | 简单 |
| Lint 集成 | ❌ | ✅ | ❌ |
| 生成质量 | 高 | 中等 | 高 |
| 成本 | OpenAI API 费用 | Copilot 订阅费用 | OpenAI API 费用 |

## 故障排除

### 常见问题

1. **OpenAI API Key 错误**
   ```bash
   # GPTCommit
   gptcommit config set openai.api_key "your-new-key"
   
   # OpenCommit
   oc config set OCO_OPENAI_API_KEY="your-new-key"
   ```

2. **GitHub 登录问题**
   ```bash
   gh auth logout
   gh auth login
   ```

3. **Node.js 环境问题（OpenCommit）**
   ```bash
   # 检查 Node.js 版本
   node --version
   npm --version
   
   # 重新安装 OpenCommit
   npm uninstall -g opencommit
   npm install -g opencommit
   ```

4. **自动生成不工作**
   ```bash
   # 检查钩子是否存在且可执行
   ls -la .git/hooks/prepare-commit-msg
   chmod +x .git/hooks/prepare-commit-msg
   ```

5. **权限问题**
   ```bash
   chmod +x .git/hooks/*
   ```

6. **重新初始化**
   ```bash
   # 重新运行对应的初始化脚本
   ./commits/gptcommit-init.sh      # 或
   ./commits/gh-copilot-init.sh     # 或
   ./commits/open-commit-init.sh
   ```

### 调试提示

```bash
# 查看 Git hooks 执行情况
GIT_TRACE=1 git commit --quiet --no-edit

# 手动测试 hooks
.git/hooks/prepare-commit-msg /tmp/test-msg
cat /tmp/test-msg

# OpenCommit 调试
oc commit --dry-run
oc config
```

## 兼容性

- **操作系统**: macOS, Linux
- **Shell**: bash, zsh
- **Git**: 2.0+
- **Node.js**: 16+ (OpenCommit 需要)
- **Python**: 3.7+ (如使用 Python lint 工具)

## 许可证

遵循项目根目录的许可证条款。 