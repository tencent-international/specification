# 🔍 TypeScript 代码规范工具配置

## 快速开始

## 复制以下文件至项目根目录
- `.editorconfig` - 代码格式化配置
- `eslint.config.js` - ESLint 配置
- `ts-lint.sh` - 检测脚本
- `tsconfig.json` - TypeScript 配置

```bash
# 运行初始化脚本
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tencent-international/specification/main/typescripts/ts-lint-init.sh)"
```

## 使用方法

### 运行检测
```bash
bash ts-lint.sh
```

### NPM 命令
```bash
npm run lint          # ESLint 检查
npm run lint:fix      # 自动修复
npm run type-check    # 类型检查
```

## 检测流程

1. **类型检查** - 检查 TypeScript 类型错误
2. **ESLint 检查** - 检查代码质量问题
3. **交互修复** - 失败时询问是否自动修复
4. **重新检测** - 修复后再次验证

## 交互示例

```bash
🔍 TypeScript Lint 检测...
🔍 类型检查...
✅ 类型检查通过
🔍 ESLint 检查...
❌ ESLint 检查失败
🤔 是否自动修复？[y/N]: y
🔧 自动修复中...
🔍 重新检测...
✅ 修复成功！
```

## 安装的依赖

只安装4个必要依赖：
- `typescript` - 编译器
- `eslint` - 代码检查
- `@typescript-eslint/parser` - TS 解析器
- `@typescript-eslint/eslint-plugin` - TS 规则

## 注意事项

- 类型错误需要手动修复
- ESLint 问题可以选择自动修复
- 默认选择是"否"（按回车跳过修复）
