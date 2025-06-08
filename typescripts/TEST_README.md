# TypeScript 脚本测试说明

## 🧪 测试项目概述

这个测试项目用于验证 `ts-lint-init.sh` 脚本的各项功能，包括：

- TypeScript 配置生成
- ESLint 规则检查
- Prettier 代码格式化
- 类型检查
- 智能提交流程

## 📁 测试文件结构

```
typescripts/
├── package.json              # 基础 Node.js 项目配置
├── src/
│   ├── index.ts             # 包含各种代码问题的主文件
│   ├── utils.ts             # 工具函数，测试类和方法
│   ├── types.ts             # 类型定义文件
│   └── main.ts              # 主入口文件，测试导入
├── ts-lint-init.sh          # 要测试的脚本
└── TEST_README.md           # 本说明文件
```

## 🔧 测试步骤

### 1. 运行初始化脚本
```bash
# 在 typescripts 目录下执行
bash ts-lint-init.sh
```

### 2. 验证生成的配置文件
脚本运行后应该生成以下文件：
- `tsconfig.json` - TypeScript 配置
- `.eslintrc.js` - ESLint 规则
- `.prettierrc` - Prettier 格式化规则
- `.editorconfig` - 编辑器配置
- `scripts/smart-commit.sh` - 智能提交脚本
- `Makefile` - Make 命令配置

### 3. 测试各项功能

#### 格式化测试
```bash
# 检查格式化
npx prettier --check src/**/*.ts

# 执行格式化
npx prettier --write src/**/*.ts
```

#### ESLint 检查
```bash
# 运行 lint 检查
npm run lint

# 自动修复
npm run lint:fix
```

#### TypeScript 类型检查
```bash
# 类型检查
npm run type-check

# 编译测试
npm run build
```

#### 智能提交测试
```bash
# 使用智能提交
make commit
```

## ⚠️ 预期的问题

测试文件故意包含以下问题，用于验证工具链：

### 格式问题
- 缺少分号
- 不一致的缩进
- 多余的空格
- 引号使用不统一

### ESLint 问题
- 未使用的变量
- 使用 `var` 而不是 `const/let`
- 缺少显式返回类型
- 使用 `any` 类型

### TypeScript 类型问题
- 缺少参数类型
- 缺少返回类型
- 接口属性缺少类型定义
- 类型不匹配

## ✅ 测试通过标准

1. **脚本运行无错误** - `ts-lint-init.sh` 成功执行
2. **配置文件生成** - 所有必要配置文件都已创建
3. **依赖安装成功** - npm 包正确安装
4. **格式化工作** - Prettier 能够格式化代码
5. **Lint 检查生效** - ESLint 能发现并修复问题
6. **类型检查工作** - TypeScript 编译器能发现类型错误
7. **智能提交流程** - `make commit` 命令正常工作

## 🐛 可能的问题

如果遇到问题，检查：
1. Node.js 和 npm 版本是否支持
2. 网络连接是否正常（下载依赖时）
3. 权限是否足够（创建文件和目录）
4. GPTCommit 是否已正确配置

## 📝 测试记录

执行测试时，可以记录：
- 脚本执行时间
- 生成的文件列表
- 发现的代码问题数量
- 自动修复的问题数量
- 整体体验和建议 