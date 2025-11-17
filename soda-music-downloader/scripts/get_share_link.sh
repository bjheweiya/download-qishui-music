#!/bin/bash

# 汽水音乐分享链接获取和下载脚本
echo "🎵 汽水音乐分享链接获取器"
echo "========================"
echo ""

# 检查汽水音乐是否运行
check_soda_running() {
    SODA_PID=$(ps aux | grep "汽水音乐.app/Contents/MacOS/汽水音乐$" | grep -v grep | awk '{print $2}' | head -1)
    if [ -z "$SODA_PID" ]; then
        echo "❌ 汽水音乐未运行，请先启动汽水音乐"
        exit 1
    fi
    echo "✅ 汽水音乐正在运行 (PID: $SODA_PID)"
}

# 尝试获取当前窗口标题
get_current_song() {
    echo "🔍 尝试获取当前播放歌曲..."
    
    # 使用AppleScript获取窗口标题
    WINDOW_TITLE=$(osascript -e '
    tell application "System Events"
        try
            tell process "汽水音乐"
                set windowTitle to name of front window
                return windowTitle
            end tell
        on error
            return "无法获取"
        end try
    end tell
    ' 2>/dev/null)
    
    if [ "$WINDOW_TITLE" != "无法获取" ] && [ ! -z "$WINDOW_TITLE" ]; then
        echo "🎵 当前窗口: $WINDOW_TITLE"
    else
        echo "⚠️ 无法自动获取歌曲信息，需要手动操作"
    fi
}

# 引导用户手动获取分享链接
guide_manual_share() {
    echo ""
    echo "📖 手动获取分享链接步骤:"
    echo "========================"
    echo "1. 🎵 确保汽水音乐正在播放歌曲"
    echo "2. 🔍 在汽水音乐界面找到【分享】按钮"
    echo "3. 👆 点击【分享】按钮"
    echo "4. 📋 选择【复制链接】"
    echo "5. ✅ 链接已复制到剪贴板"
    echo ""
    echo "⏳ 请按照上述步骤操作，然后按回车键继续..."
    read -p ""
}

# 检查剪贴板中的链接
check_clipboard() {
    echo "🔍 检查剪贴板内容..."
    
    CLIPBOARD_CONTENT=$(pbpaste 2>/dev/null)
    MUSIC_URL=$(echo "$CLIPBOARD_CONTENT" | grep -oE "https://qishui\.douyin\.com/s/[a-zA-Z0-9]+/" | head -1)
    
    if [ ! -z "$MUSIC_URL" ]; then
        echo "✅ 发现汽水音乐分享链接:"
        echo "🔗 $MUSIC_URL"
        return 0
    else
        echo "❌ 剪贴板中没有找到汽水音乐链接"
        echo "📋 当前剪贴板内容: $(echo "$CLIPBOARD_CONTENT" | head -c 50)..."
        return 1
    fi
}

# 启动下载
start_download() {
    echo ""
    echo "🚀 启动自动下载..."
    echo "=================="
    
    cd /Volumes/HE5-0/汽水音乐下载
    
    # 运行下载脚本
    echo "执行下载脚本..."
    timeout 60s ./auto_download_final.sh &
    DOWNLOAD_PID=$!
    
    echo "⏳ 下载进行中... (最多等待60秒)"
    echo "💡 如果下载完成，脚本会自动停止"
    
    # 等待下载完成
    wait $DOWNLOAD_PID 2>/dev/null
    
    echo ""
    echo "✅ 下载处理完成!"
    
    # 显示下载结果
    echo ""
    echo "📁 检查下载结果:"
    ls -la download_music/ | tail -3
}

# 主流程
main() {
    check_soda_running
    echo ""
    
    get_current_song
    echo ""
    
    guide_manual_share
    
    # 检查剪贴板，最多尝试3次
    for i in {1..3}; do
        if check_clipboard; then
            start_download
            break
        else
            if [ $i -lt 3 ]; then
                echo ""
                echo "🔄 请重新复制分享链接，然后按回车键 (尝试 $i/3)..."
                read -p ""
            else
                echo ""
                echo "❌ 多次尝试失败，请检查操作步骤"
                echo "💡 提示: 确保点击的是【分享】->【复制链接】"
            fi
        fi
    done
}

# 运行主流程
main
