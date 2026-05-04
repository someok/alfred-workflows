#!/bin/zsh

arg="$1"

workspace_path="${arg%%||*}"
profile="${arg#*||}"

# echo "Workspace Path: $workspace_path"
# echo "Profile: $profile"

# 以登录 shell 方式启动，以便能够载入 .zshrc 中的环境变量
# 使用 -c 的特性：在命令字符串内使用 $1, $2 等位置参数，然后在 -c 后面按顺序提供实际的值。
zsh -l -c 'code --profile "$1" "$2"' _ "$profile" "$workspace_path"
