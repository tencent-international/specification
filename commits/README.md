# Git 工作流自动化脚本简明指南

## 脚本一览

| 脚本                | 功能                                   |
|---------------------|----------------------------------------|
| normal-commit-init.sh  | 规范化 Git 提交信息（Conventional Commits） |
| gptcommit-init.sh   | AI 智能生成/校验提交信息               |
| bitbucket-pr.sh     | Bitbucket PR 自动化（创建、批准、合并） |

---

## gptcommit-init.sh / normal-commit-init.sh

- 作用：强制/智能生成符合 Conventional Commits 规范的提交信息
- 支持类型：feat, fix, docs, style, refactor, perf, test, chore, ci, build, revert
- 安装：
  ```bash
  # 任选其一
  # normal-commit-init.sh
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/tencent-international/specification/main/commits/normal-commit-init.sh)"
  # gptcommit-init.sh
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/tencent-international/specification/main/commits/gptcommit-init.sh)"
  ```
- 生成格式示例：
  ```
  feat: 新增用户登录
  fix(auth): 修复登录验证
  ```
- 使用方式
    ```bash
    # 可以查看生成内容
    git commit -a
    # 不查看生成内容直接提交
    git commit -a --quiet --no-edit
    ```

---

## bitbucket-pr.sh

- 作用：一键自动化 Bitbucket PR 流程（需管理员权限）
- 安装：将脚本放入 scripts 目录，首次运行自动引导配置
  ```bash
  bash scripts/bitbucket-pr.sh
  ```
- 常用参数：
  - --title PR标题
  - --desc  PR描述
  - --target 目标分支
  - --config 重新配置
- 示例：
  ```bash
  bash scripts/bitbucket-pr.sh --title "feat: 新功能" --desc "详细描述" --target develop
  ```
- 支持自动检测仓库、推送分支、创建/批准/合并 PR

---

## 常见问题

- 提交被拒绝：检查提交信息格式
- PR 失败：检查 Bitbucket 权限、网络、分支冲突
- 重新配置：bash scripts/bitbucket-pr.sh --config

---

## 其他

- 推荐所有成员安装 gptcommit-init.sh
- 可集成到 Makefile 或 package.json
- 详细用法见 --help

---

如需详细说明，请查阅原文档或使用 --help 获取帮助。
