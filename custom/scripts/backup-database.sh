#!/bin/bash
# OpenCode 数据库备份脚本

echo "=== OpenCode 数据库备份 ==="
echo ""

# 配置
DATA_DIR=~/.local/share/opencode
CONFIG_DIR=~/.config/opencode
STATE_DIR=~/.local/state/opencode
BACKUP_ROOT=~/opencode-backups
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

echo "备份目录: $BACKUP_DIR"
echo ""

# 1. 备份数据库文件
echo "1. 备份数据库文件..."
if [ -d "$DATA_DIR" ]; then
    cp -v "$DATA_DIR"/*.db* "$BACKUP_DIR/" 2>&1 | grep -E "opencode.*\.db" | sed 's/^/   /'
    echo "   ✓ 数据库文件备份完成"
else
    echo "   ⚠️  数据目录不存在: $DATA_DIR"
fi
echo ""

# 2. 备份配置文件
echo "2. 备份配置文件..."
if [ -d "$CONFIG_DIR" ]; then
    cp -r "$CONFIG_DIR" "$BACKUP_DIR/config" 2>/dev/null
    echo "   ✓ 配置文件备份完成"
else
    echo "   ⚠️  配置目录不存在: $CONFIG_DIR"
fi
echo ""

# 3. 备份状态文件（可选）
echo "3. 备份状态文件..."
if [ -d "$STATE_DIR" ]; then
    # 只备份关键状态文件，不备份大文件
    mkdir -p "$BACKUP_DIR/state"
    for file in session.json model.json plugin-meta.json kv.json; do
        if [ -f "$STATE_DIR/$file" ]; then
            cp -v "$STATE_DIR/$file" "$BACKUP_DIR/state/" 2>&1 | sed 's/^/   /'
        fi
    done
    echo "   ✓ 状态文件备份完成"
else
    echo "   ⚠️  状态目录不存在: $STATE_DIR"
fi
echo ""

# 4. 创建备份信息文件
echo "4. 创建备份信息..."
cat > "$BACKUP_DIR/backup-info.txt" << EOF
OpenCode 备份信息
================

备份时间: $(date '+%Y-%m-%d %H:%M:%S')
备份目录: $BACKUP_DIR

版本信息:
- 官方版本: $(opencode --version 2>/dev/null || echo "未安装")
- 自定义版本: $(opencode-dev --version 2>/dev/null || echo "未安装")

数据库文件:
$(ls -lh "$BACKUP_DIR"/*.db 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}')

配置文件:
$([ -d "$BACKUP_DIR/config" ] && echo "  已备份" || echo "  未备份")

状态文件:
$([ -d "$BACKUP_DIR/state" ] && echo "  已备份" || echo "  未备份")

总大小: $(du -sh "$BACKUP_DIR" | cut -f1)

恢复方法:
========

恢复数据库:
  cp "$BACKUP_DIR/opencode.db" ~/.local/share/opencode/

恢复配置:
  cp -r "$BACKUP_DIR/config/"* ~/.config/opencode/

恢复状态:
  cp "$BACKUP_DIR/state/"* ~/.local/state/opencode/
EOF

echo "   ✓ 备份信息已保存到 backup-info.txt"
echo ""

# 5. 显示备份摘要
echo "5. 备份摘要:"
echo "   位置: $BACKUP_DIR"
echo "   大小: $(du -sh "$BACKUP_DIR" | cut -f1)"
echo "   文件数: $(find "$BACKUP_DIR" -type f | wc -l)"
echo ""

# 6. 清理旧备份（保留最近 10 个）
echo "6. 清理旧备份..."
BACKUP_COUNT=$(ls -1d "$BACKUP_ROOT"/*/ 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    echo "   当前有 $BACKUP_COUNT 个备份，清理旧备份..."
    ls -1td "$BACKUP_ROOT"/*/ | tail -n +11 | while read old_backup; do
        echo "   删除: $old_backup"
        rm -rf "$old_backup"
    done
    echo "   ✓ 保留最近 10 个备份"
else
    echo "   ✓ 当前有 $BACKUP_COUNT 个备份，无需清理"
fi
echo ""

echo "=== 备份完成 ==="
echo ""
echo "备份已保存到: $BACKUP_DIR"
echo "查看备份信息: cat $BACKUP_DIR/backup-info.txt"
