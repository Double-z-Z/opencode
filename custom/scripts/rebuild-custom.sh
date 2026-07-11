#!/bin/bash
# OpenCode 自定义版本快速重新构建和安装脚本

set -e

echo "=== OpenCode 自定义版本构建脚本 ==="
echo ""

# 获取脚本所在目录的父目录（即项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 切换到项目根目录
cd "$PROJECT_ROOT"

# 检查是否在正确的目录
if [ ! -d "custom" ]; then
    echo "错误：找不到 custom 目录，请确认在 opencode 仓库根目录"
    exit 1
fi

# 显示当前分支和版本
echo "当前分支: $(git branch --show-current)"
echo "最新提交: $(git log -1 --oneline)"
echo ""

# 询问是否跳过 Web UI 构建（更快）
read -p "是否跳过 Web UI 构建？(更快，但没有 web 界面) [y/N]: " skip_web_ui
SKIP_FLAG=""
if [[ "$skip_web_ui" =~ ^[Yy]$ ]]; then
    SKIP_FLAG="--skip-embed-web-ui"
    echo "将跳过 Web UI 构建"
else
    echo "将包含 Web UI 构建"
fi
echo ""

# 进入构建目录
cd packages/opencode

# 构建
echo "开始构建..."
OPENCODE_BINARY_NAME=opencode-dev bun run script/build.ts --single $SKIP_FLAG

# 检查构建是否成功
if [ ! -f "dist/opencode-linux-x64/bin/opencode-dev" ]; then
    echo ""
    echo "错误：构建失败，找不到生成的可执行文件"
    exit 1
fi

echo ""
echo "构建成功！"
echo ""

# 询问是否安装
read -p "是否安装到 ~/.local/bin/opencode-dev？[Y/n]: " install_binary
if [[ ! "$install_binary" =~ ^[Nn]$ ]]; then
    cp dist/opencode-linux-x64/bin/opencode-dev ~/.local/bin/
    chmod +x ~/.local/bin/opencode-dev
    echo ""
    echo "已安装到 ~/.local/bin/opencode-dev"
    echo ""
    echo "版本信息："
    ~/.local/bin/opencode-dev --version
else
    echo ""
    echo "已跳过安装，可执行文件位于："
    echo "  $(pwd)/dist/opencode-linux-x64/bin/opencode-dev"
fi

echo ""
echo "=== 构建完成 ==="
