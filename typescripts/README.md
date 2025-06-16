# 🔍 TypeScript 代码规范工具配置

## 快速开始

## 复制以下文件至项目根目录
- `.editorconfig` - 代码格式化配置
- `eslint.config.js` - ESLint 配置(如果你有了就不需要)
- `tsconfig.json` - TypeScript 配置(如果你有了就不需要)

```bash
# 运行初始化脚本
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tencent-international/specification/main/typescripts/ts-lint-init.sh)"
```

## 使用方法

### NPM 命令
```bash
npm run lint          # ESLint 检查
npm run lint:fix      # 自动修复
npm run type-check    # 类型检查
```
## 安装的依赖

只安装4个必要依赖：
- `typescript` - 编译器
- `eslint` - 代码检查
- `@typescript-eslint/parser` - TS 解析器
- `@typescript-eslint/eslint-plugin` - TS 规则
