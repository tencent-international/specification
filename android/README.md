# 🤖 Android Lint 自动化工具集成指南

## 一、功能介绍

此项目集成了以下Android开发代码质量工具：

- **Android Lint** - Google官方静态代码分析工具
- **Ktlint** - Kotlin官方代码风格检查和格式化工具
- **GPTCommit** - AI自动生成Conventional Commit风格的提交信息
- **智能提交流程** - 自动运行检查、格式化和提交

## 二、快速开始

### 1. 初始化项目
#### 在Android项目根目录下执行
```bash
# 复制 android-lint-init.sh 和 common/gptcommit-init.sh 到项目根目录
bash gptcommit-init.sh
bash android-lint-init.sh
```

### 2. 配置Gradle文件
```bash
# 查看配置说明
make setup

# 将 gradle-config.kts 或 gradle-config.gradle 中的内容
# 添加到对应的 Gradle 文件中
```

#### 项目根目录 build.gradle.kts 添加：
```kotlin
plugins {
    id("org.jlleitschuh.gradle.ktlint") version "11.6.1" apply false
}
```

#### app/build.gradle.kts 添加：
```kotlin
plugins {
    id("org.jlleitschuh.gradle.ktlint")
}

android {
    lint {
        abortOnError = true
        lintConfig = file("../lint.xml")
        htmlReport = true
        htmlOutput = file("$buildDir/reports/lint/lint-results.html")
    }
}

ktlint {
    version.set("0.50.0")
    android.set(true)
    outputToConsole.set(true)
}
```

### 3. 常用命令

```bash
# 运行Android Lint检查
make lint

# 运行Ktlint检查
make ktlint

# 自动格式化Kotlin代码
make format

# 智能提交
make commit

# 强制提交（忽略lint错误）
make commit-force
```

## 三、配置说明

### Android Lint 规则
- **错误级别**: 硬编码文本、缺失翻译、未使用资源等
- **警告级别**: 性能优化、安全检查、布局优化等
- **自定义配置**: 通过 `lint.xml` 文件调整规则

### Ktlint 代码风格
- **官方Kotlin代码风格**
- **自动格式化**: 统一缩进、空格、换行等
- **Android适配**: 针对Android项目优化的规则

### 智能提交流程
1. **Ktlint格式化** - 自动修复代码格式问题
2. **Ktlint检查** - 验证代码风格一致性
3. **Android Lint检查** - 检查Android特有问题
4. **GPTCommit提交** - AI生成规范的提交信息

## 四、文件说明

| 文件 | 说明 |
|------|------|
| `lint.xml` | Android Lint规则配置 |
| `.editorconfig` | Ktlint代码风格配置 |
| `scripts/android-smart-commit.sh` | 智能提交脚本 |
| `Makefile` | 快捷命令定义 |
| `gradle-config.kts/.gradle` | Gradle配置示例 |

## 五、最佳实践

### 1. 团队协作
- 所有团队成员使用相同的lint配置
- 提交前必须通过lint检查
- 使用智能提交确保代码质量

### 2. CI/CD集成
```bash
# 在CI脚本中添加
./gradlew ktlintCheck
./gradlew lint
```

### 3. IDE配置
```bash
# 配置Android Studio使用项目的Ktlint规则
./gradlew ktlintApplyToIdea
```

## 六、故障排除

### 常见问题

**Q: Ktlint检查失败怎么办？**
```bash
# 自动修复大部分格式问题
make format
```

**Q: Android Lint报告太多警告？**
```bash
# 查看详细报告
open build/reports/lint/lint-results.html
# 在lint.xml中调整规则严重级别
```

**Q: 想要忽略某些lint规则？**
```xml
<!-- 在lint.xml中添加 -->
<issue id="RuleName" severity="ignore" />
```

## 七、进阶配置

### 自定义Lint规则
- 在`lint.xml`中调整规则严重级别
- 添加项目特定的检查规则
- 配置基线文件忽略现有问题

### Ktlint高级配置
- 自定义代码风格规则
- 配置特定文件的忽略规则
- 集成pre-commit hooks

## 八、中英切换
```bash
# 英文
gptcommit config set output.lang en
# 中文  
gptcommit config set output.lang zh-cn
``` 