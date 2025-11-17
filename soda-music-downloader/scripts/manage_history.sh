#!/bin/bash

# 下载历史管理工具
HISTORY_FILE="/Volumes/HE5-0/汽水音乐下载/download_history.txt"

echo "📝 汽水音乐下载历史管理"
echo "========================"
echo ""

case "$1" in
    "list"|"")
        echo "📋 已下载的链接:"
        if [ -f "$HISTORY_FILE" ]; then
            grep -v "^#" "$HISTORY_FILE" | nl
        else
            echo "暂无下载记录"
        fi
        ;;
    "count")
        count=$(grep -v "^#" "$HISTORY_FILE" 2>/dev/null | wc -l)
        echo "📊 总共下载了 $count 首歌曲"
        ;;
    "clear")
        echo "# 汽水音乐下载历史记录" > "$HISTORY_FILE"
        echo "# 格式: URL" >> "$HISTORY_FILE"
        echo "🗑️ 历史记录已清空"
        ;;
    "add")
        if [ ! -z "$2" ]; then
            echo "$2" >> "$HISTORY_FILE"
            echo "✅ 已添加链接到历史记录"
        else
            echo "❌ 请提供要添加的链接"
        fi
        ;;
    "remove")
        if [ ! -z "$2" ]; then
            grep -v "$2" "$HISTORY_FILE" > /tmp/history_temp && mv /tmp/history_temp "$HISTORY_FILE"
            echo "🗑️ 已从历史记录中移除"
        else
            echo "❌ 请提供要移除的链接"
        fi
        ;;
    *)
        echo "用法: $0 [命令]"
        echo ""
        echo "命令:"
        echo "  list    - 显示所有已下载的链接 (默认)"
        echo "  count   - 显示下载总数"
        echo "  clear   - 清空历史记录"
        echo "  add     - 添加链接到历史记录"
        echo "  remove  - 从历史记录中移除链接"
        ;;
esac
