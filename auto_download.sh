#!/bin/bash

# 汽水音乐自动下载器 - 增强歌词版
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOWNLOAD_DIR="$SCRIPT_DIR/downloads"
HISTORY_FILE="$SCRIPT_DIR/download_history.txt"

# 设置环境变量抑制numpy警告
export PYTHONWARNINGS="ignore::RuntimeWarning"
export NPY_DISABLE_SVML=1

mkdir -p "$DOWNLOAD_DIR"
touch "$HISTORY_FILE"

echo "🎵 汽水音乐自动下载器 (增强歌词版)"
echo "📁 下载目录: $DOWNLOAD_DIR"
echo "📝 历史记录: $HISTORY_FILE"
echo "📋 监听汽水音乐链接中... (按 Ctrl+C 停止)"
echo ""

last_clipboard=""

while true; do
    current_clipboard=$(pbpaste 2>/dev/null)
    
    if [ "$current_clipboard" != "$last_clipboard" ] && [ ! -z "$current_clipboard" ]; then
        # 只处理汽水音乐链接
        music_url=$(echo "$current_clipboard" | grep -oE "https://qishui\.douyin\.com/s/[a-zA-Z0-9]+/" | head -1)
        
        if [ ! -z "$music_url" ]; then
            echo "🎵 发现汽水音乐链接: $music_url"
            
            # 检查是否已下载过
            if grep -Fxq "$music_url" "$HISTORY_FILE"; then
                echo "⚠️ 该链接已下载过，跳过"
                echo ""
            else
                echo "✅ 新链接，开始下载..."
                
                # 调用Python下载脚本
                python3 "$SCRIPT_DIR/downloader.py" "$music_url" "$DOWNLOAD_DIR"
                
                # 检查是否下载成功
                if [ $? -eq 0 ]; then
                    echo "$music_url" >> "$HISTORY_FILE"
                    echo "📝 已记录到历史文件"
                fi
                
                echo ""
            fi
        fi
        
        last_clipboard="$current_clipboard"
    fi
    
    sleep 1
done
