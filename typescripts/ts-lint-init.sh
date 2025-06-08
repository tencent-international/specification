#!/usr/bin/env bash
set -e

# 创建脚本目录
mkdir -p scripts

# 检查是否已存在package.json
if [ ! -f "package.json" ]; then
  echo "⚠️  检测到没有 package.json，正在初始化..."
  npm init -y
fi

# 安装 TypeScript 开发依赖
echo "🔧 安装 TypeScript 开发工具..."
npm install --save-dev \
  typescript \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  eslint \
  prettier \
  eslint-config-prettier \
  eslint-plugin-prettier \
  @types/node

# 全局安装工具（如果未安装）
echo "🔧 检查并安装全局工具..."
if ! command -v tsc >/dev/null 2>&1; then
  npm install -g typescript
fi

if ! command -v eslint >/dev/null 2>&1; then
  npm install -g eslint
fi

if ! command -v prettier >/dev/null 2>&1; then
  npm install -g prettier
fi

# 生成 .editorconfig
cat <<EOF > .editorconfig
root = true

[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
trim_trailing_whitespace = true

[*.{js,ts,tsx,jsx}]
indent_style = space
indent_size = 2

[*.{json,yml,yaml}]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false
EOF

# 生成 tsconfig.json
cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "**/*.test.ts"
  ]
}
EOF

# 生成 eslint.config.js (ESLint 9.x 新格式)
cat <<'EOF' > eslint.config.js
import js from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';
import prettier from 'eslint-plugin-prettier';

export default [
  js.configs.recommended,
  {
    files: ['src/**/*.ts'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 2020,
        sourceType: 'module',
        project: './tsconfig.json',
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
      prettier: prettier,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      ...tseslint.configs['recommended-requiring-type-checking'].rules,
      'prettier/prettier': 'error',
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/explicit-function-return-type': 'warn',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-inferrable-types': 'off',
      '@typescript-eslint/no-non-null-assertion': 'warn',
      'prefer-const': 'error',
      'no-var': 'error',
    },
  },
];
EOF

# 生成 .prettierrc
cat <<EOF > .prettierrc
{
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": true,
  "quoteProps": "as-needed",
  "trailingComma": "es5",
  "bracketSpacing": true,
  "bracketSameLine": false,
  "arrowParens": "avoid",
  "endOfLine": "lf"
}
EOF

# 生成 .prettierignore
cat <<EOF > .prettierignore
node_modules
dist
coverage
*.log
package-lock.json
yarn.lock
EOF

# 生成 .gitignore（如果不存在）
if [ ! -f ".gitignore" ]; then
cat <<EOF > .gitignore
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
*.tsbuildinfo

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Logs
logs
*.log

# Editor directories and files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Temporary folders
tmp/
temp/
EOF
fi

# 更新 package.json 的 scripts
echo "📦 更新 package.json scripts..."
npm pkg set scripts.build="tsc"
npm pkg set scripts.dev="tsc --watch"
npm pkg set scripts.lint="eslint \"src/**/*.ts\""
npm pkg set scripts.lint:fix="eslint \"src/**/*.ts\" --fix"
npm pkg set scripts.format="prettier --write \"src/**/*.ts\""
npm pkg set scripts.format:check="prettier --check \"src/**/*.ts\""
npm pkg set scripts.type-check="tsc --noEmit"

# 生成 Makefile
cat <<EOF > Makefile
.PHONY: commit commit-force
commit:
	bash scripts/smart-commit.sh
commit-force:
	bash scripts/smart-commit.sh --force
EOF

# 生成 TypeScript 智能提交脚本
cat <<'EOF' > scripts/smart-commit.sh
#!/usr/bin/env bash
set -e

# 检查强制模式
FORCE_MODE=false
if [[ "$1" == "--force" ]]; then
  FORCE_MODE=true
fi

# 检查是否存在 src 目录，如果不存在则创建
if [ ! -d "src" ]; then
  echo "📁 创建 src 目录..."
  mkdir -p src
fi

# 自动添加文件变更
if [ -n "$(git diff --name-only)" ] || [ -n "$(git diff --cached --name-only)" ]; then
  echo "📦 检测到文件变更，自动执行 git add ."
  git add .
fi

echo ""
echo "✨ Step 1: 检查并格式化 TypeScript 代码..."
if find src -name "*.ts" -type f | head -1 | grep -q . 2>/dev/null; then
  echo "🚀 执行：prettier --write \"src/**/*.ts\""
  prettier --write "src/**/*.ts" || echo "⚠️ 格式化过程中出现问题"
  
  if [ -n "$(git diff --name-only)" ]; then
    echo "📦 格式化后检测到文件变更，自动暂存"
    git add .
    echo "✅ TypeScript 代码已格式化"
  else
    echo "✅ TypeScript 代码格式正确，无需修改"
  fi
else
  echo "⚠️ src 目录下没有 TypeScript 文件，跳过格式化"
fi

echo ""
echo "🔍 Step 2: 运行 ESLint 检查..."
if find src -name "*.ts" -type f | head -1 | grep -q . 2>/dev/null; then
  if npm run lint; then
    echo "✅ ESLint 检查通过"
  else
    echo "⛔ ESLint 检查失败，尝试自动修复..."
    if npm run lint:fix; then
      echo "✅ ESLint 自动修复完成"
      git add .
    else
      echo "⚠️ ESLint 自动修复失败，部分问题需要手动处理"
      if [ "$FORCE_MODE" = false ]; then
        read -p "🤔 是否继续提交？(y/N): " CONTINUE_CONFIRM
        CONTINUE_CONFIRM=${CONTINUE_CONFIRM:-n}
        if [[ ! "$CONTINUE_CONFIRM" =~ ^[Yy]$ ]]; then
          echo "❌ 已取消提交"
          exit 1
        fi
      else
        echo "⚠️ 强制模式：忽略 ESLint 错误继续提交"
      fi
    fi
  fi
else
  echo "⚠️ 没有找到 TypeScript 文件，跳过 ESLint 检查"
fi

echo ""
echo "🔍 Step 3: 运行 TypeScript 类型检查..."
if [ -f "tsconfig.json" ]; then
  if npm run type-check; then
    echo "✅ TypeScript 类型检查通过"
  else
    echo "⛔ TypeScript 类型检查失败"
    if [ "$FORCE_MODE" = false ]; then
      read -p "🤔 是否继续提交？(y/N): " CONTINUE_CONFIRM
      CONTINUE_CONFIRM=${CONTINUE_CONFIRM:-n}
      if [[ ! "$CONTINUE_CONFIRM" =~ ^[Yy]$ ]]; then
        echo "❌ 已取消提交"
        exit 1
      fi
    else
      echo "⚠️ 强制模式：忽略类型检查错误继续提交"
    fi
  fi
else
  echo "⚠️ 没有找到 tsconfig.json，跳过类型检查"
fi

echo ""
echo "🤖 Step 4: 调用 GPTCommit 生成提交信息并提交..."
git commit --quiet --no-edit
echo ""
echo "🎉 提交完成！"
EOF

chmod +x scripts/smart-commit.sh

# 创建示例 src 目录和文件
if [ ! -d "src" ]; then
  mkdir -p src
  cat <<'EOF' > src/index.ts
/**
 * 示例 TypeScript 文件
 */
export function hello(name: string): string {
  return `Hello, ${name}!`;
}

export function add(a: number, b: number): number {
  return a + b;
}
EOF
fi

echo ""
echo "✅ TypeScript Lint/格式化脚本与配置初始化完成！"
echo "   - package.json (已更新 scripts)"
echo "   - tsconfig.json"
echo "   - eslint.config.js (ESLint 9.x 新格式)"
echo "   - .prettierrc & .prettierignore"
echo "   - .editorconfig"
echo "   - .gitignore (如果不存在)"
echo "   - scripts/smart-commit.sh"
echo "   - Makefile"
echo "   - src/index.ts (示例文件)"
echo ""
echo "🎯 使用方法："
echo "   • make commit       - 智能提交（有错误时会询问）"
echo "   • make commit-force - 强制提交（忽略 lint 和类型错误）"
echo "   • npm run lint      - 单独运行 ESLint 检查"
echo "   • npm run format    - 单独格式化代码"
echo ""
