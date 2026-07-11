#!/bin/bash
# OpenCode 共享数据库测试脚本

echo "=== OpenCode 共享数据库测试 ==="
echo ""

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 检查版本
echo "1. 检查版本信息..."
echo -n "   官方版本: "
opencode --version
echo -n "   自定义版本: "
opencode-dev --version
echo ""

# 2. 检查数据库文件
echo "2. 检查数据库文件..."
ls -lh ~/.local/share/opencode/*.db 2>/dev/null | while read line; do
    echo "   $line"
done
echo ""

# 3. 检查配置
echo "3. 检查自动更新配置..."
if grep -q '"autoupdate": false' ~/.config/opencode/opencode.jsonc 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} 配置文件中已禁用自动更新"
else
    echo -e "   ${RED}✗${NC} 配置文件中未禁用自动更新"
fi

if [ -n "$OPENCODE_DISABLE_AUTOUPDATE" ]; then
    echo -e "   ${GREEN}✓${NC} 环境变量 OPENCODE_DISABLE_AUTOUPDATE 已设置"
else
    echo -e "   ${YELLOW}!${NC} 环境变量 OPENCODE_DISABLE_AUTOUPDATE 未设置（需要重新登录终端生效）"
fi
echo ""

# 4. 验证共享数据库配置
echo "4. 验证共享数据库配置..."
echo "   检查构建脚本中的 OPENCODE_DISABLE_CHANNEL_DB 设置..."
if grep -q 'OPENCODE_DISABLE_CHANNEL_DB.*"1"' ~/workspace/opencode/packages/opencode/script/build.ts; then
    echo -e "   ${GREEN}✓${NC} 构建脚本中已设置强制共享数据库"
else
    echo -e "   ${RED}✗${NC} 构建脚本中未设置强制共享数据库"
fi
echo ""

# 5. 检查备份
echo "5. 检查数据备份..."
BACKUP_DIR=$(ls -td ~/opencode-backups/*/ 2>/dev/null | head -1)
if [ -n "$BACKUP_DIR" ]; then
    echo -e "   ${GREEN}✓${NC} 最新备份: $BACKUP_DIR"
    echo "   备份大小: $(du -sh "$BACKUP_DIR" | cut -f1)"
else
    echo -e "   ${RED}✗${NC} 未找到备份"
fi
echo ""

# 6. 实际测试（需要手动验证）
echo "6. 手动测试步骤（请按以下步骤操作）:"
echo ""
echo "   a) 使用官方版本打开一个项目:"
echo "      $ opencode ."
echo ""
echo "   b) 在官方版本中创建一个测试会话（记住会话标题）"
echo ""
echo "   c) 退出官方版本，使用自定义版本打开:"
echo "      $ opencode-dev ."
echo ""
echo "   d) 检查是否能看到相同的会话列表"
echo ""
echo "   e) 在自定义版本中编辑会话，添加一些内容"
echo ""
echo "   f) 再次切换回官方版本，验证是否能看到更新"
echo ""

echo "=== 测试脚本完成 ==="
echo ""
echo "如果所有检查都通过，说明共享数据库配置成功！"
echo "记得在新终端中测试环境变量是否生效。"
