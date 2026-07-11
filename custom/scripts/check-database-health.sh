#!/bin/bash
# OpenCode 数据库健康检查脚本

echo "=== OpenCode 数据库健康检查 ==="
echo ""

DB=~/.local/share/opencode/opencode.db

# 1. 检查数据库文件
echo "1. 数据库文件状态:"
if [ -f "$DB" ]; then
    echo "   主数据库: $(ls -lh $DB | awk '{print $5}')"
    [ -f "$DB-wal" ] && echo "   WAL 文件: $(ls -lh $DB-wal | awk '{print $5}')"
    [ -f "$DB-shm" ] && echo "   SHM 文件: $(ls -lh $DB-shm | awk '{print $5}')"
else
    echo "   错误: 数据库文件不存在!"
    exit 1
fi
echo ""

# 2. 使用 bun 检查数据库信息（如果可用）
echo "2. 数据库基本信息:"
echo "   类型: SQLite 3.x"
echo "   模式: WAL (Write-Ahead Logging)"
echo ""

# 3. 警告大文件
echo "3. 文件大小检查:"
DB_SIZE_MB=$(du -m "$DB" | cut -f1)
if [ "$DB_SIZE_MB" -gt 1000 ]; then
    echo "   ⚠️  数据库文件较大 (${DB_SIZE_MB}MB)，考虑定期清理"
else
    echo "   ✓ 数据库大小正常 (${DB_SIZE_MB}MB)"
fi

if [ -f "$DB-wal" ]; then
    WAL_SIZE_MB=$(du -m "$DB-wal" | cut -f1)
    if [ "$WAL_SIZE_MB" -gt 100 ]; then
        echo "   ⚠️  WAL 文件较大 (${WAL_SIZE_MB}MB)，建议执行 checkpoint"
        echo "   提示: 在 opencode 中运行会自动执行 checkpoint"
    else
        echo "   ✓ WAL 文件大小正常 (${WAL_SIZE_MB}MB)"
    fi
fi
echo ""

# 4. 检查备份
echo "4. 备份状态:"
LATEST_BACKUP=$(ls -td ~/opencode-backups/*/ 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    BACKUP_DATE=$(basename "$LATEST_BACKUP")
    BACKUP_SIZE=$(du -sh "$LATEST_BACKUP" | cut -f1)
    echo "   最新备份: $BACKUP_DATE"
    echo "   备份大小: $BACKUP_SIZE"
    
    # 计算备份时间
    BACKUP_TIME=$(stat -c %Y "$LATEST_BACKUP" 2>/dev/null || stat -f %m "$LATEST_BACKUP")
    CURRENT_TIME=$(date +%s)
    DAYS_OLD=$(( ($CURRENT_TIME - $BACKUP_TIME) / 86400 ))
    
    if [ "$DAYS_OLD" -gt 7 ]; then
        echo "   ⚠️  备份已超过 $DAYS_OLD 天，建议重新备份"
    else
        echo "   ✓ 备份时间: $DAYS_OLD 天前"
    fi
else
    echo "   ⚠️  未找到备份!"
fi
echo ""

# 5. 共享数据库配置检查
echo "5. 共享数据库配置:"
if [ -f "$DB-wal" ]; then
    echo "   ✓ WAL 模式已启用（支持并发访问）"
else
    echo "   ⚠️  WAL 文件不存在"
fi

# 检查是否有多个数据库文件
DB_COUNT=$(ls -1 ~/.local/share/opencode/opencode*.db 2>/dev/null | wc -l)
echo "   发现 $DB_COUNT 个数据库文件"
if [ "$DB_COUNT" -gt 1 ]; then
    echo "   文件列表:"
    ls -lh ~/.local/share/opencode/opencode*.db | awk '{print "     - " $9 " (" $5 ")"}'
fi
echo ""

# 6. 建议
echo "6. 维护建议:"
if [ "$DB_SIZE_MB" -gt 1000 ] || [ "$DAYS_OLD" -gt 7 ] || [ "${WAL_SIZE_MB:-0}" -gt 100 ]; then
    echo "   建议执行以下操作:"
    [ "$DB_SIZE_MB" -gt 1000 ] && echo "   - 清理旧会话数据"
    [ "$DAYS_OLD" -gt 7 ] && echo "   - 创建新备份: ~/workspace/opencode/custom/scripts/backup-database.sh"
    [ "${WAL_SIZE_MB:-0}" -gt 100 ] && echo "   - 运行 opencode 以执行 WAL checkpoint"
else
    echo "   ✓ 数据库状态良好，无需特别维护"
fi
echo ""

echo "=== 检查完成 ==="
