# Git 工作流自动化脚本

这个目录包含两个用于优化 Git 工作流的脚本，帮助团队规范代码提交和自动化 Pull Request 流程。

## 📋 脚本概览

| 脚本 | 功能 | 用途 |
|------|------|------|
| `gptcommit-init.sh` | Git Commit 验证 | 规范化提交信息格式 |
| `bitbucket-pr.sh` | PR 自动化 | 自动创建、批准和合并 PR |

---

## 🔧 gptcommit-init.sh - Git Commit 验证脚本

### 功能介绍

自动设置 Git commit-msg 钩子，强制执行 [Conventional Commits](https://www.conventionalcommits.org/) 规范，确保团队提交信息的一致性。

### 支持的提交类型

- `feat`: 新功能
- `fix`: 问题修复
- `docs`: 文档更新
- `style`: 代码格式化（不影响功能）
- `refactor`: 代码重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动
- `ci`: CI/CD 相关
- `build`: 构建系统变动
- `revert`: 回滚提交

### 使用方法

这里注意建议把脚本放置根目录的 scripts 文件夹
```bash
# 在 Git 仓库根目录下运行
bash scripts/gptcommit-init.sh
```

## 该脚本有两个功能
### 1.验证提交信息格式

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

#### 示例

```bash
# ✅ 正确格式
git commit -m "feat: 添加用户登录功能"
git commit -m "fix(auth): 修复登录验证逻辑"
git commit -m "docs: 更新 API 文档"
git commit -m "ci: 更新依赖项和CI/CD管道中的配置"

# ❌ 错误格式 - 会被拒绝
git commit -m "添加新功能"
git commit -m "修复bug"
git commit -m "update docs"
```

### 2.使用OpenAI智能分析生成提交内容
```bash
# 进入编辑器生成提交信息
git commit
# 不进入编辑器，直接生成提交信息
git commit --quiet --no-edit
````

### 安装效果

脚本会在 `.git/hooks/` 目录下创建 `commit-msg` 钩子，每次提交时自动验证提交信息格式。

---

## 🚀 bitbucket-pr.sh - Bitbucket PR 自动化脚本

### 功能介绍

一键自动化 Bitbucket Pull Request 流程，支持创建、批准和合并 PR，特别适合有管理员权限的开发者使用。

### 核心功能

- ✅ **自动仓库检测**：从 git remote 自动解析 workspace 和 repository
- ✅ **智能配置管理**：首次运行自动引导配置，持久化保存用户凭据
- ✅ **一键 PR 流程**：创建 → 批准 → 合并，全自动完成
- ✅ **灵活参数支持**：支持自定义 PR 标题、描述和目标分支
- ✅ **安全权限控制**：配置文件采用 600 权限，保护敏感信息

### 前置要求

1. **Bitbucket 账户**：需要有仓库的管理员权限
2. **App Password**：在 Bitbucket Settings → App passwords 中创建
   - 需要权限：`Repositories: Read, Write` 和 `Pull requests: Read, Write`

### 首次配置

第一次运行时会自动引导您完成配置：

这里注意需要把脚本放置根目录的 scripts 文件夹
```bash
bash scripts/bitbucket-pr.sh
```

脚本会提示输入：
- Bitbucket 用户名
- Bitbucket App Password

配置会保存到 `~/.bitbucket-pr/config`，下次使用时自动加载。

### 使用方法

#### 基本用法

```bash
# 最简单的用法 - 使用默认设置
bash scripts/bitbucket-pr.sh

# 查看帮助信息
bash scripts/bitbucket-pr.sh --help
```

#### 高级用法

```bash
# 自定义 PR 标题和描述
bash scripts/bitbucket-pr.sh \
  --title "feat: 添加新的用户管理功能" \
  --desc "实现了用户创建、删除和权限管理功能"

# 指定目标分支
bash scripts/bitbucket-pr.sh --target main

# 组合使用
bash scripts/bitbucket-pr.sh \
  --title "fix: 修复登录问题" \
  --desc "修复了用户在某些情况下无法登录的bug" \
  --target develop
```

#### 配置管理

```bash
# 重新配置或管理现有配置
bash scripts/bitbucket-pr.sh --config
```

### 完整参数列表

| 参数 | 说明 | 示例 |
|------|------|------|
| `-h, --help` | 显示帮助信息 | `--help` |
| `-c, --config` | 管理配置 | `--config` |
| `-t, --title` | 指定 PR 标题 | `--title "feat: 新功能"` |
| `-d, --desc` | 指定 PR 描述 | `--desc "详细描述"` |
| `--target` | 指定目标分支 | `--target develop` |

### 工作流程

1. **🔍 自动检测**：解析 git remote 获取仓库信息
2. **📂 加载配置**：读取本地配置或引导首次配置
3. **🎯 选择目标分支**：交互式选择或使用参数指定
4. **📤 推送分支**：将当前分支推送到远程
5. **🔄 创建 PR**：调用 Bitbucket API 创建 Pull Request
6. **👍 自动批准**：以管理员身份批准 PR
7. **🔀 自动合并**：使用 squash 策略合并 PR
8. **🎉 完成**：显示 PR 链接和成功信息

### 支持的 Git Remote 格式

脚本支持自动解析以下格式的 Bitbucket URL：

```bash
# HTTPS 格式
https://bitbucket.org/workspace/repo.git
https://username@bitbucket.org/workspace/repo.git

# SSH 格式  
git@bitbucket.org:workspace/repo.git
```

### 错误处理

- **权限不足**：确保有仓库管理员权限
- **分支冲突**：如果目标分支有冲突，合并会失败
- **网络问题**：检查网络连接和 Bitbucket 服务状态
- **配置错误**：使用 `--config` 重新配置

---

## 🛠️ 环境要求

### 系统要求

- **操作系统**：macOS, Linux, Windows (WSL)
- **Shell**：Bash 4.0+
- **Git**：2.0+
- **curl**：用于 API 调用

### 权限要求

- **Git 仓库**：需要在 Git 仓库根目录下运行
- **Bitbucket 权限**：
  - `gptcommit-init.sh`：无特殊要求
  - `bitbucket-pr.sh`：需要仓库管理员权限

---

## 📝 最佳实践

### 团队协作建议

1. **统一提交规范**：所有成员都应该安装 `gptcommit-init.sh`
2. **PR 模板化**：使用 `bitbucket-pr.sh` 的参数功能创建一致的 PR
3. **分支策略**：建议配合 Git Flow 或 GitHub Flow 使用

### 安全建议

1. **App Password 管理**：
   - 定期更换 App Password
   - 不要在代码中硬编码密码
   - 使用脚本的配置管理功能

2. **权限控制**：
   - 只给必要的人员管理员权限
   - 定期审查仓库权限

### 自动化集成

可以将这些脚本集成到 Makefile 或 package.json 中：

```makefile
# Makefile 示例
.PHONY: init-hooks pr

init-hooks:
	bash scripts/gptcommit-init.sh

pr:
	bash scripts/bitbucket-pr.sh
```

```json
{
  "scripts": {
    "init-hooks": "bash scripts/gptcommit-init.sh",
    "pr": "bash scripts/bitbucket-pr.sh"
  }
}
```

---

## 🆘 故障排除

### 常见问题

#### gptcommit-init.sh

**Q: 提交被拒绝，提示格式错误？**  
A: 请确保提交信息符合 `type: description` 格式，type 必须是支持的类型之一。

**Q: 想要禁用提交验证？**  
A: 删除 `.git/hooks/commit-msg` 文件即可。

#### bitbucket-pr.sh

**Q: 提示 "无法获取 git remote URL"？**  
A: 确保在 Git 仓库中运行，且配置了 origin 远程仓库。

**Q: API 调用失败，HTTP 401？**  
A: 检查 Bitbucket 用户名和 App Password 是否正确，使用 `--config` 重新配置。

**Q: 合并失败，HTTP 409？**  
A: 可能存在分支冲突，需要手动解决冲突后重试。

### 获取帮助

如果遇到问题，可以：

1. 查看脚本的帮助信息：`bash script.sh --help`
2. 检查 Git 和网络连接状态
3. 验证 Bitbucket 权限和配置
4. 查看错误日志和 HTTP 响应码

---

## 📄 许可证

这些脚本基于 MIT 许可证发布，可以自由使用、修改和分发。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这些脚本！
