# 🤖 Android Lint 快速使用指南

### 初始化项目
### 目录中的文件复制到你的项目根目录
### - .editorconfig
### - android-lint.sh

## 一、功能介绍

本工具用于在 Android 项目中快速执行 Google 官方的静态代码分析（Android Lint），帮助你发现潜在问题，提升代码质量。

---

## 二、如何使用

1. **将 `android-lint-init.sh` 脚本放到你的 Android 项目根目录**  
   （即和 `build.gradle` 或 `build.gradle.kts` 同级）

2. **在项目根目录下执行：**
   ```bash
   bash android-lint.sh
   ```

3. **脚本会自动检测并运行：**
   ```bash
   ./gradlew lint
   ```

4. **检查结果会在终端输出，详细报告在：**
   ```
   build/reports/lint/lint-results.html
   ```

---

## 三、常见问题

- **不是 Android 项目？**  
  请确保当前目录下有 `build.gradle` 或 `build.gradle.kts` 文件。

- **未找到 gradlew？**  
  请在项目根目录下运行脚本。

- **如何自定义 lint 规则？**  
  编辑或添加 `lint.xml` 文件，或在 `build.gradle(.kts)` 的 `lint {}` 块中配置。

---

## 四、进阶用法

- **CI 检查：**
  ```bash
  ./gradlew lint
  ```

- **查看详细报告：**
  ```
  open build/reports/lint/lint-results.html
  ```

---

如需更复杂的代码风格检查、自动格式化或智能提交，请参考完整文档或相关工具说明。 
