# 🧠 GPT Commit 自动化提交工具集成指南

## 一、功能介绍

此项目集成了以下能力：

- 自动格式化代码（Prettier）
- 自动执行 Lint 检查（ESLint + TypeScript ESLint）
- TypeScript 类型检查（tsc --noEmit）
- 调用 GPT 自动生成 Conventional Commit 风格的提交信息
- 提交信息校验钩子（commit-msg）

## 二、快速开始

### 1. 初始化项目
把 ts-lint-init.sh 和 commits/gptcommit-init.sh 复制到项目的根目录下，按顺序执行：
```bash
bash gptcommit-init.sh
bash ts-lint-init.sh
```

### 2. 生成的文件说明
- `package.json` - 已更新 scripts 配置和 ES 模块设置
- `tsconfig.json` - TypeScript 编译器配置
- `eslint.config.js` - ESLint 9.x 新格式配置
- `.prettierrc` & `.prettierignore` - Prettier 格式化配置
- `.editorconfig` - 编辑器代码风格配置
- `scripts/smart-commit.sh` - 智能提交脚本
- `Makefile` - 快捷命令定义
- `src/index.ts` - 示例 TypeScript 文件

## 三、使用命令

### 🚀 智能提交（推荐）
```shell
make commit
```
**功能说明：**
- 自动格式化 TypeScript 代码（Prettier）
- 运行 ESLint 检查并尝试自动修复
- 执行 TypeScript 类型检查
- 检查失败时询问是否继续提交
- 调用 GPTCommit 生成提交信息并提交

### 🔍 代码检查
```shell
make lint
# 或者
npm run lint
```
运行 ESLint 进行代码质量检查

### ✨ 代码格式化
```shell
make format
# 或者
npm run format
```
使用 Prettier 格式化 TypeScript 代码

### 🛠 强制提交
```shell
make commit-force
```
忽略 lint 和类型检查错误强制提交

### 📦 NPM Scripts
```shell
# 构建项目
npm run build

# 开发模式（监听文件变化）
npm run dev

# ESLint 检查
npm run lint

# ESLint 自动修复
npm run lint:fix

# Prettier 格式化
npm run format

# Prettier 检查格式
npm run format:check

# TypeScript 类型检查
npm run type-check
```

## 四、GPTCommit 配置

### 中英文切换
```shell
# 英文提交信息
gptcommit config set output.lang en

# 中文提交信息
gptcommit config set output.lang zh-cn
```

### 其他配置
```shell
# 查看当前配置
gptcommit config list

# 设置 OpenAI API Key（如果需要）
gptcommit config set openai.api_key YOUR_API_KEY
```

## 五、智能提交流程

1. **Step 1: 代码格式化**
   - 使用 Prettier 自动格式化 TypeScript 代码
   - 自动暂存格式化后的变更

2. **Step 2: ESLint 检查**
   - 运行 ESLint 进行代码质量检查
   - 自动尝试修复可修复的问题
   - 失败时询问是否继续提交

3. **Step 3: TypeScript 类型检查**
   - 运行 `tsc --noEmit` 进行类型检查
   - 失败时询问是否继续提交

4. **Step 4: 智能提交**
   - 调用 GPTCommit 生成符合规范的提交信息
   - 自动提交到 Git 仓库

## 六、技术栈特性

### ESLint 9.x 新格式
- 使用最新的 ESLint 9.x 配置格式
- 集成 TypeScript ESLint 规则
- 支持 ES 模块配置

### TypeScript 严格模式
- 启用所有严格类型检查
- 配置详细的编译选项
- 支持最新的 ES2020 特性

### Prettier 集成
- 与 ESLint 完美配合
- 统一的代码风格
- 自动格式化支持

## 七、最佳实践

- 建议在每次提交前使用 `make commit` 确保代码质量
- 定期运行 `make lint` 检查代码问题
- 使用 `npm run dev` 进行开发时的实时类型检查
- 配置编辑器支持 `.editorconfig` 和 Prettier 插件
- 利用 `npm run lint:fix` 自动修复可修复的 ESLint 问题
