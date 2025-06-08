# Android Lint 测试项目

## 🧪 测试项目概述

这是一个简化的Android测试项目，用于验证 `android-lint-init.sh` 脚本的功能，包括：

- Android Lint 规则检查
- Ktlint 代码风格检查
- 智能提交流程测试
- Gradle 配置验证

## 📁 项目结构

```
android-test-demo/
├── build.gradle.kts              # 项目根配置 (Kotlin DSL)
├── settings.gradle.kts           # 项目设置
├── gradlew                       # 模拟的Gradle包装器
├── app/
│   ├── build.gradle.kts          # 应用模块配置
│   └── src/main/
│       ├── AndroidManifest.xml   # 应用清单
│       ├── java/com/example/androidtestdemo/
│       │   ├── MainActivity.kt    # 主Activity (包含代码问题)
│       │   └── DataManager.kt     # 数据管理类 (包含代码问题)
│       └── res/
│           ├── layout/
│           │   └── activity_main.xml  # 布局文件 (包含布局问题)
│           └── values/
│               └── strings.xml         # 字符串资源 (包含未使用资源)
└── TEST_README.md                # 本说明文件
```

## 🎯 故意包含的问题

### Android Lint 问题

#### **错误级别 (Error)**
- ✗ **HardcodedText**: 布局文件中使用硬编码文本
- ✗ **UnusedResources**: strings.xml 中有未使用的字符串资源

#### **警告级别 (Warning)**
- ⚠️ **UselessParent**: 布局中有无用的父级容器
- ⚠️ **ObsoleteLayoutParam**: 使用过时的 `fill_parent`
- ⚠️ **NestedWeights**: 嵌套使用layout_weight影响性能
- ⚠️ **DrawAllocation**: onCreate中进行对象分配

### Ktlint 代码风格问题

#### **格式问题**
- ❌ 等号周围缺少空格: `val message="text"`
- ❌ 不一致的空格使用: `val title   =   value`
- ❌ 循环格式: `for(i in 0..100){}`

#### **命名规范问题**
- ❌ 常量命名: `max_count` 应该是 `MAX_COUNT`
- ❌ 变量命名: `user_count` 应该是 `userCount`

#### **代码质量问题**
- ❌ 未使用的变量: `unusedVariable`
- ❌ 未使用的函数: `unusedFunction()`
- ❌ 不安全的空值处理: `input!!.length`
- ❌ 资源泄漏: FileInputStream 未关闭

## 🔧 测试步骤

### 1. 运行初始化脚本
```bash
# 在 android-test-demo 目录下
bash ../android-lint-init.sh
```

### 2. 检查生成的文件
脚本应该生成以下文件：
- `lint.xml` - Android Lint 配置
- `.editorconfig` - Ktlint 配置  
- `gradle-config.kts` - Gradle 配置示例
- `scripts/android-smart-commit.sh` - 智能提交脚本
- `Makefile` - 快捷命令

### 3. 测试各项功能

#### 测试 Android Lint
```bash
make lint
# 应该显示: HardcodedText, UnusedResources, UselessParent 等问题
```

#### 测试 Ktlint 检查
```bash
make ktlint  
# 应该显示: 格式问题和代码风格问题
```

#### 测试 Ktlint 格式化
```bash
make format
# 应该自动修复格式问题
```

#### 测试智能提交
```bash
make commit
# 应该按顺序执行: 格式化 -> Ktlint检查 -> Android Lint -> GPTCommit
```

## ⚠️ 预期的测试结果

### Android Lint 检查结果
```
警告: 发现以下问题:
- HardcodedText: 在 activity_main.xml 中发现硬编码文本
- UnusedResources: strings.xml 中有未使用的字符串资源  
- UselessParent: activity_main.xml 中有无用的父级容器
- ObsoleteLayoutParam: 使用了过时的 fill_parent
```

### Ktlint 检查结果  
```
发现代码风格问题:
MainActivity.kt:18: 等号周围缺少空格
MainActivity.kt:19: 等号周围缺少空格
DataManager.kt:23: 等号周围缺少空格
DataManager.kt:12: 变量命名应使用驼峰格式
```

## ✅ 测试通过标准

1. **脚本运行成功** - `android-lint-init.sh` 无错误执行
2. **文件生成正确** - 所有配置文件都已创建
3. **项目类型检测** - 正确识别为 `kotlin-dsl` 项目
4. **Android Lint 工作** - 能检测出布局和资源问题
5. **Ktlint 工作** - 能检测出代码风格问题
6. **格式化功能** - `make format` 能修复格式问题
7. **智能提交** - `make commit` 流程正常

## 🐛 模拟说明

由于这是测试项目，`gradlew` 是模拟脚本，会：
- 模拟 Android Lint 检查并显示预期问题
- 模拟 Ktlint 检查并报告代码风格问题  
- 模拟格式化操作
- 不会实际编译Android应用

## 📝 实际使用时

在真实的Android项目中：
1. 需要配置真实的 Gradle 插件
2. 需要添加 Ktlint 依赖到 `build.gradle.kts`
3. Android Lint 会执行真实的静态分析
4. 可以生成详细的HTML报告 