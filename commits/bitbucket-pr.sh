#!/usr/bin/env bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置变量（请根据您的实际情况修改）
BITBUCKET_WORKSPACE=""
BITBUCKET_REPO=""
BITBUCKET_USERNAME=""
BITBUCKET_APP_PASSWORD=""
TARGET_BRANCH="develop"  # 默认目标分支

# 配置文件路径
CONFIG_DIR="$HOME/.bitbucket-pr"
CONFIG_FILE="$CONFIG_DIR/config"

# 自动从 git remote 解析 workspace 和 repo
auto_detect_repo_info() {
    echo -e "${BLUE}🔍 自动检测仓库信息...${NC}"
    
    # 获取 origin 远程 URL
    local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    
    if [ -z "$remote_url" ]; then
        echo -e "${YELLOW}   ⚠️  无法获取 git remote URL${NC}"
        return 1
    fi
    
    echo -e "${CYAN}   Remote URL: $remote_url${NC}"
    
    # 检查是否是 Bitbucket 仓库
    if [[ ! "$remote_url" =~ bitbucket\.org ]]; then
        echo -e "${YELLOW}   ⚠️  这不是一个 Bitbucket 仓库${NC}"
        echo -e "${YELLOW}      当前检测到的是: $(echo "$remote_url" | sed -E 's|.*@([^:]+)[:/].*|\1|' | sed -E 's|https?://([^/]+)/.*|\1|')${NC}"
        echo -e "${CYAN}   💡 请手动设置环境变量或修改脚本配置${NC}"
        return 1
    fi
    
    # 解析 Bitbucket URL
    # 支持格式:
    # - https://bitbucket.org/workspace/repo.git
    # - git@bitbucket.org:workspace/repo.git
    # - https://username@bitbucket.org/workspace/repo.git
    
    local workspace=""
    local repo=""
    
    if [[ "$remote_url" =~ ^https?://.*bitbucket\.org/([^/]+)/([^/]+)(\.git)?/?$ ]]; then
        # HTTPS 格式
        workspace="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    elif [[ "$remote_url" =~ ^git@bitbucket\.org:([^/]+)/([^/]+)(\.git)?/?$ ]]; then
        # SSH 格式
        workspace="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    fi
    
    # 清理 repo 名称（移除 .git 后缀）
    repo="${repo%.git}"
    
    if [ -n "$workspace" ] && [ -n "$repo" ]; then
        echo -e "${GREEN}   ✅ 自动检测成功:${NC}"
        echo -e "${CYAN}      Workspace: $workspace${NC}"
        echo -e "${CYAN}      Repository: $repo${NC}"
        
        # 如果配置为空，则使用自动检测的值
        if [ -z "$BITBUCKET_WORKSPACE" ]; then
            BITBUCKET_WORKSPACE="$workspace"
        fi
        
        if [ -z "$BITBUCKET_REPO" ]; then
            BITBUCKET_REPO="$repo"
        fi
        
        return 0
    else
        echo -e "${YELLOW}   ⚠️  无法解析 Bitbucket 仓库信息${NC}"
        echo -e "${YELLOW}      URL 格式可能不标准${NC}"
        return 1
    fi
}

# 检查配置
check_config() {
    local missing=()
    
    if [ -z "$BITBUCKET_WORKSPACE" ]; then
        missing+=("BITBUCKET_WORKSPACE")
    fi
    
    if [ -z "$BITBUCKET_REPO" ]; then
        missing+=("BITBUCKET_REPO")
    fi
    
    if [ -z "$BITBUCKET_USERNAME" ]; then
        missing+=("BITBUCKET_USERNAME")
    fi
    
    if [ -z "$BITBUCKET_APP_PASSWORD" ]; then
        missing+=("BITBUCKET_APP_PASSWORD")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}❌ 缺少必要配置:${NC}"
        for item in "${missing[@]}"; do
            echo -e "   ${YELLOW}$item${NC}"
        done
        echo ""
        if [[ " ${missing[@]} " =~ " BITBUCKET_USERNAME " ]] || [[ " ${missing[@]} " =~ " BITBUCKET_APP_PASSWORD " ]]; then
            echo -e "${CYAN}请运行 '$0 --config' 进行配置${NC}"
        fi
        if [[ " ${missing[@]} " =~ " BITBUCKET_WORKSPACE " ]] || [[ " ${missing[@]} " =~ " BITBUCKET_REPO " ]]; then
            echo -e "${CYAN}请确保在 Bitbucket 仓库中运行，或手动设置环境变量${NC}"
        fi
        echo ""
        echo -e "${YELLOW}💡 提示: App Password 可在 Bitbucket Settings > App passwords 中创建${NC}"
        exit 1
    fi
}

# 从环境变量读取配置（如果存在）
if [ -n "$BITBUCKET_WORKSPACE_ENV" ]; then
    BITBUCKET_WORKSPACE="$BITBUCKET_WORKSPACE_ENV"
fi

if [ -n "$BITBUCKET_REPO_ENV" ]; then
    BITBUCKET_REPO="$BITBUCKET_REPO_ENV"
fi

if [ -n "$BITBUCKET_USERNAME_ENV" ]; then
    BITBUCKET_USERNAME="$BITBUCKET_USERNAME_ENV"
fi

if [ -n "$BITBUCKET_APP_PASSWORD_ENV" ]; then
    BITBUCKET_APP_PASSWORD="$BITBUCKET_APP_PASSWORD_ENV"
fi

# 获取当前分支
get_current_branch() {
    git branch --show-current
}

# 检查是否有未提交的更改
check_working_directory() {
    if ! git diff-index --quiet HEAD --; then
        echo -e "${RED}❌ 工作目录有未提交的更改${NC}"
        echo -e "${YELLOW}请先提交或暂存您的更改${NC}"
        exit 1
    fi
}

# 推送当前分支到远程
push_branch() {
    local branch="$1"
    echo -e "${BLUE}📤 推送分支 '$branch' 到远程...${NC}"
    
    # 设置上游分支并推送
    git push -u origin "$branch"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 分支推送成功${NC}"
    else
        echo -e "${RED}❌ 分支推送失败${NC}"
        exit 1
    fi
}

# 创建 Pull Request
create_pull_request() {
    local source_branch="$1"
    local title="$2"
    local description="$3"
    
    echo -e "${BLUE}🔄 创建 Pull Request...${NC}" >&2
    
    # 获取最近的 commit 信息作为默认标题和描述
    if [ -z "$title" ]; then
        title=$(git log -1 --pretty=format:"%s")
    fi
    
    if [ -z "$description" ]; then
        description=$(git log -1 --pretty=format:"%b")
        if [ -z "$description" ]; then
            description="Auto-generated PR from branch: $source_branch"
        fi
    fi
    
    # 清理 JSON 字符串中的特殊字符和换行符
    title=$(echo "$title" | sed 's/"/\\"/g' | tr -d '\n\r')
    description=$(echo "$description" | sed 's/"/\\"/g' | tr '\n' ' ' | tr -d '\r')
    
    # 如果 description 为空，使用默认值
    if [ -z "$description" ]; then
        description="Auto-generated PR from branch: $source_branch"
    fi
    
    # 创建 PR 的 JSON 数据
    local json_data=$(cat <<EOF
{
    "title": "$title",
    "description": "$description",
    "source": {
        "branch": {
            "name": "$source_branch"
        }
    },
    "destination": {
        "branch": {
            "name": "$TARGET_BRANCH"
        }
    },
    "close_source_branch": true
}
EOF
)
    
    # 调用 Bitbucket API 创建 PR
    local temp_file=$(mktemp)
    local http_code=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
        -d "$json_data" \
        -o "$temp_file" \
        "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO/pullrequests")
    
    local body=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [ "$http_code" = "201" ]; then
        local pr_id=$(echo "$body" | grep -o '"id":[[:space:]]*[0-9]*' | head -1 | grep -o '[0-9]*')
        echo -e "${GREEN}✅ Pull Request 创建成功 (ID: $pr_id)${NC}" >&2
        echo "$pr_id"  # 只输出 PR ID
        return 0
    elif [ "$http_code" = "400" ]; then
        # 检查是否是因为已存在 PR
        if echo "$body" | grep -q "already exists"; then
            echo -e "${YELLOW}⚠️  该分支已存在 Pull Request${NC}" >&2
            # 获取已存在的 PR ID
            local query_url="https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO/pullrequests?q=source.branch.name=\"$source_branch\""
            
            local existing_pr=$(curl -s \
                -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
                "$query_url")
            
            local pr_id=$(echo "$existing_pr" | grep -o '"id":[[:space:]]*[0-9]*' | head -1 | grep -o '[0-9]*')
            echo -e "${BLUE}📋 使用已存在的 PR (ID: $pr_id)${NC}" >&2
            echo "$pr_id"  # 只输出 PR ID
            return 0
        else
            echo -e "${RED}❌ 创建 Pull Request 失败:${NC}" >&2
            echo "$body" | head -5 >&2
            return 1
        fi
    else
        echo -e "${RED}❌ 创建 Pull Request 失败 (HTTP $http_code):${NC}" >&2
        echo "$body" | head -5 >&2
        return 1
    fi
}

# 批准 Pull Request
approve_pull_request() {
    local pr_id="$1"
    
    # 验证 PR ID
    if [ -z "$pr_id" ] || [[ ! "$pr_id" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ 无效的 PR ID: '$pr_id'${NC}"
        return 1
    fi
    
    echo -e "${BLUE}👍 批准 Pull Request (ID: $pr_id)...${NC}"
    
    local approve_url="https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO/pullrequests/$pr_id/approve"
    
    local temp_file=$(mktemp)
    local http_code=$(curl -s -w "%{http_code}" \
        -X POST \
        -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
        -o "$temp_file" \
        "$approve_url")
    
    local body=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
        echo -e "${GREEN}✅ Pull Request 批准成功${NC}"
    else
        echo -e "${YELLOW}⚠️  Pull Request 批准失败 (HTTP $http_code)${NC}"
    fi
}

# 合并 Pull Request
merge_pull_request() {
    local pr_id="$1"
    
    # 验证 PR ID
    if [ -z "$pr_id" ] || [[ ! "$pr_id" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ 无效的 PR ID: '$pr_id'${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔀 合并 Pull Request (ID: $pr_id)...${NC}"
    
    # 合并策略: merge_commit, squash, fast_forward
    local merge_strategy="squash"  # 可以根据需要修改
    
    local json_data=$(cat <<EOF
{
    "type": "$merge_strategy",
    "message": "Merged via admin auto-merge",
    "close_source_branch": true
}
EOF
)
    
    local merge_url="https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO/pullrequests/$pr_id/merge"
    
    local temp_file=$(mktemp)
    local http_code=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
        -d "$json_data" \
        -o "$temp_file" \
        "$merge_url")
    
    local body=$(cat "$temp_file")
    rm -f "$temp_file"
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ Pull Request 合并成功${NC}"
        return 0
    else
        echo -e "${RED}❌ Pull Request 合并失败 (HTTP $http_code):${NC}"
        echo "$body" | head -5
        return 1
    fi
}

# 显示使用帮助
show_help() {
    echo -e "${CYAN}Bitbucket Auto PR & Merge Script${NC}"
    echo ""
    echo -e "${YELLOW}功能:${NC}"
    echo "  ✅ 自动从 git remote 检测 workspace 和 repository 名称"
    echo "  ✅ 创建 Pull Request 并自动批准合并（admin 权限）"
    echo "  ✅ 支持自定义 PR 标题和描述"
    echo "  ✅ 交互式配置管理，首次使用时自动引导设置"
    echo ""
    echo -e "${YELLOW}使用方法:${NC}"
    echo "  $0 [选项]"
    echo ""
    echo -e "${YELLOW}选项:${NC}"
    echo "  -h, --help          显示此帮助信息"
    echo "  -c, --config        管理配置（重新配置或删除配置）"
    echo "  -t, --title TEXT    指定 PR 标题"
    echo "  -d, --desc TEXT     指定 PR 描述"
    echo "  --target BRANCH     指定目标分支 (默认: develop)"
    echo ""
    echo -e "${YELLOW}配置管理:${NC}"
    echo "  首次运行时会自动提示配置 Bitbucket 用户名和 App Password"
    echo "  配置文件保存在: ${CYAN}~/.bitbucket-pr/config${NC}"
    echo "  使用 ${CYAN}--config${NC} 选项可以重新配置或删除配置"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  # 首次使用（会自动引导配置）"
    echo "  $0"
    echo ""
    echo "  # 管理配置"
    echo "  $0 --config"
    echo ""
    echo "  # 自定义 PR 信息"
    echo "  $0 --title \"feat: add new feature\" --desc \"Added awesome feature\""
    echo ""
    echo "  # 指定目标分支"
    echo "  $0 --target develop"
    echo ""
    echo -e "${YELLOW}注意:${NC}"
    echo "  📍 需要在 git 仓库根目录下运行"
    echo "  🔑 配置文件包含敏感信息，仅当前用户可访问（权限 600）"
    echo "  👑 需要有仓库的 admin 权限才能自动合并"
}

# 读取本地配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${BLUE}📂 加载本地配置...${NC}"
        source "$CONFIG_FILE"
        
        if [ -n "$BITBUCKET_USERNAME" ] && [ -n "$BITBUCKET_APP_PASSWORD" ]; then
            echo -e "${GREEN}   ✅ 配置加载成功${NC}"
            echo -e "${CYAN}   用户名: $BITBUCKET_USERNAME${NC}"
            return 0
        else
            echo -e "${YELLOW}   ⚠️  配置文件不完整${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}📂 未找到本地配置文件${NC}"
        return 1
    fi
}

# 保存配置到本地
save_config() {
    local username="$1"
    local password="$2"
    
    echo -e "${BLUE}💾 保存配置到本地...${NC}"
    
    # 创建配置目录
    mkdir -p "$CONFIG_DIR"
    
    # 写入配置文件
    cat > "$CONFIG_FILE" << EOF
# Bitbucket 配置文件
# 生成时间: $(date)
# 注意: 此文件包含敏感信息，请勿分享

BITBUCKET_USERNAME="$username"
BITBUCKET_APP_PASSWORD="$password"
EOF
    
    # 设置文件权限（仅当前用户可读写）
    chmod 600 "$CONFIG_FILE"
    
    echo -e "${GREEN}   ✅ 配置保存成功${NC}"
    echo -e "${CYAN}   配置文件: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}   ⚠️  配置文件包含敏感信息，请妥善保管${NC}"
}

# 交互式配置
interactive_config() {
    echo -e "${PURPLE}🔧 首次配置 Bitbucket 信息${NC}"
    echo ""
    echo -e "${CYAN}需要配置以下信息来使用 Bitbucket API:${NC}"
    echo -e "${YELLOW}1. Bitbucket 用户名${NC}"
    echo -e "${YELLOW}2. Bitbucket App Password${NC}"
    echo ""
    echo -e "${BLUE}💡 App Password 获取方法:${NC}"
    echo -e "   1. 登录 Bitbucket"
    echo -e "   2. 点击头像 → Settings → App passwords"
    echo -e "   3. 创建新的 App Password，需要权限:"
    echo -e "      - Repositories: Read, Write"
    echo -e "      - Pull requests: Read, Write"
    echo ""
    
    # 输入用户名
    while true; do
        read -p "请输入 Bitbucket 用户名: " username
        if [ -n "$username" ]; then
            break
        else
            echo -e "${RED}❌ 用户名不能为空${NC}"
        fi
    done
    
    # 输入 App Password
    while true; do
        echo -n "请输入 Bitbucket App Password: "
        read -s password  # -s 参数隐藏输入
        echo ""
        if [ -n "$password" ]; then
            break
        else
            echo -e "${RED}❌ App Password 不能为空${NC}"
        fi
    done
    
    # 确认信息
    echo ""
    echo -e "${CYAN}📋 配置信息确认:${NC}"
    echo -e "   用户名: ${YELLOW}$username${NC}"
    echo -e "   App Password: ${YELLOW}[已设置]${NC}"
    echo ""
    
    while true; do
        read -p "是否保存配置到本地? (y/n): " confirm
        case $confirm in
            [Yy]* ) 
                save_config "$username" "$password"
                BITBUCKET_USERNAME="$username"
                BITBUCKET_APP_PASSWORD="$password"
                break
                ;;
            [Nn]* ) 
                echo -e "${YELLOW}⚠️  配置未保存，仅在此次运行中使用${NC}"
                BITBUCKET_USERNAME="$username"
                BITBUCKET_APP_PASSWORD="$password"
                break
                ;;
            * ) 
                echo -e "${RED}请输入 y 或 n${NC}"
                ;;
        esac
    done
    
    echo ""
}

# 管理配置
manage_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # 先加载配置
        source "$CONFIG_FILE"
        
        echo -e "${CYAN}📋 当前配置:${NC}"
        echo -e "   配置文件: $CONFIG_FILE"
        echo -e "   用户名: ${YELLOW}$BITBUCKET_USERNAME${NC}"
        echo -e "   App Password: ${YELLOW}[已设置]${NC}"
        echo ""
        
        while true; do
            echo -e "${YELLOW}选择操作:${NC}"
            echo "  1) 重新配置"
            echo "  2) 删除配置"
            echo "  3) 继续使用当前配置"
            read -p "请选择 (1/2/3): " choice
            
            case $choice in
                1)
                    echo -e "${BLUE}🔄 重新配置...${NC}"
                    interactive_config
                    break
                    ;;
                2)
                    read -p "确定要删除配置文件吗? (y/n): " confirm
                    if [[ $confirm =~ ^[Yy] ]]; then
                        rm -f "$CONFIG_FILE" && rmdir "$CONFIG_DIR" 2>/dev/null
                        echo -e "${GREEN}✅ 配置文件已删除${NC}"
                        interactive_config
                    fi
                    break
                    ;;
                3)
                    echo -e "${GREEN}✅ 使用当前配置${NC}"
                    break
                    ;;
                *)
                    echo -e "${RED}请输入 1、2 或 3${NC}"
                    ;;
            esac
        done
    else
        interactive_config
    fi
}

# 选择目标分支
select_target_branch() {
    echo -e "${BLUE}🎯 选择目标分支${NC}"
    echo -e "${CYAN}默认目标分支: ${YELLOW}develop${NC}"
    echo ""
    
    while true; do
        read -p "请输入目标分支名称 (直接回车使用 develop): " input_branch
        
        if [ -z "$input_branch" ]; then
            TARGET_BRANCH="develop"
            break
        else
            TARGET_BRANCH="$input_branch"
            break
        fi
    done
    
    echo -e "${GREEN}✅ 目标分支设置为: ${YELLOW}$TARGET_BRANCH${NC}"
    echo ""
}

# 主函数
main() {
    local pr_title=""
    local pr_description=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--config)
                manage_config
                exit 0
                ;;
            -t|--title)
                pr_title="$2"
                shift 2
                ;;
            -d|--desc)
                pr_description="$2"
                shift 2
                ;;
            --target)
                TARGET_BRANCH="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}❌ 未知选项: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo -e "${PURPLE}🚀 Bitbucket Auto PR & Merge Script${NC}"
    echo ""
    
    # 1. 首先从环境变量读取配置（向后兼容）
    if [ -n "$BITBUCKET_USERNAME_ENV" ]; then
        BITBUCKET_USERNAME="$BITBUCKET_USERNAME_ENV"
    fi
    
    if [ -n "$BITBUCKET_APP_PASSWORD_ENV" ]; then
        BITBUCKET_APP_PASSWORD="$BITBUCKET_APP_PASSWORD_ENV"
    fi
    
    if [ -n "$BITBUCKET_WORKSPACE_ENV" ]; then
        BITBUCKET_WORKSPACE="$BITBUCKET_WORKSPACE_ENV"
    fi
    
    if [ -n "$BITBUCKET_REPO_ENV" ]; then
        BITBUCKET_REPO="$BITBUCKET_REPO_ENV"
    fi
    
    # 2. 如果环境变量中没有用户名和密码，尝试加载本地配置
    if [ -z "$BITBUCKET_USERNAME" ] || [ -z "$BITBUCKET_APP_PASSWORD" ]; then
        if ! load_config; then
            # 3. 如果本地配置也没有，进行交互式配置
            interactive_config
        fi
    else
        echo -e "${GREEN}📂 使用环境变量配置${NC}"
        echo -e "${CYAN}   用户名: $BITBUCKET_USERNAME${NC}"
    fi
    
    # 自动检测仓库信息
    auto_detect_repo_info
    
    # 选择目标分支
    select_target_branch
    
    # 检查配置
    check_config
    
    # 检查工作目录
    check_working_directory
    
    # 获取当前分支
    local current_branch=$(get_current_branch)
    
    if [ -z "$current_branch" ]; then
        echo -e "${RED}❌ 无法获取当前分支${NC}"
        exit 1
    fi
    
    if [ "$current_branch" = "$TARGET_BRANCH" ]; then
        echo -e "${RED}❌ 不能在目标分支 '$TARGET_BRANCH' 上创建 PR${NC}"
        echo -e "${YELLOW}请切换到其他分支后再运行此脚本${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}📋 信息概览:${NC}"
    echo -e "   当前分支: ${YELLOW}$current_branch${NC}"
    echo -e "   目标分支: ${YELLOW}$TARGET_BRANCH${NC}"
    echo -e "   仓库: ${YELLOW}$BITBUCKET_WORKSPACE/$BITBUCKET_REPO${NC}"
    echo ""
    
    # 推送分支
    push_branch "$current_branch"
    
    # 创建 PR
    local pr_id=$(create_pull_request "$current_branch" "$pr_title" "$pr_description")
    local create_result=$?
    
    if [ $create_result -ne 0 ] || [ -z "$pr_id" ]; then
        echo -e "${RED}❌ 无法创建或获取 PR ID，流程终止${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}📋 PR ID 获取成功: $pr_id${NC}"
    echo ""
    
    # 批准 PR (作为 admin)
    approve_pull_request "$pr_id"
    
    # 等待一下让 Bitbucket 处理批准
    echo -e "${BLUE}⏳ 等待 Bitbucket 处理批准...${NC}"
    sleep 2
    
    # 合并 PR
    if merge_pull_request "$pr_id"; then
        echo -e "${GREEN}🎉 Pull Request 已成功合并!${NC}"
        
        echo ""
        echo -e "${GREEN}✅ 所有操作完成!${NC}"
        echo -e "${CYAN}📍 查看 PR: https://bitbucket.org/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO/pull-requests/$pr_id${NC}"
    else
        echo -e "${RED}❌ Pull Request 合并失败${NC}"
        exit 1
    fi
}

# 运行主函数
main "$@"
