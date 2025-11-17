#!/bin/bash

# 最终版汽水音乐自动下载脚本 - 只处理汽水音乐链接
SCRIPT_DIR="/Volumes/HE5-0/汽水音乐下载"
DOWNLOAD_DIR="$SCRIPT_DIR/download_music"
CRAWLER_DIR="$SCRIPT_DIR/Soda_music_crawler"
HISTORY_FILE="$SCRIPT_DIR/download_history.txt"

mkdir -p "$DOWNLOAD_DIR"
touch "$HISTORY_FILE"

echo "🎵 汽水音乐自动下载器 (最终版)"
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
                
                cd "$CRAWLER_DIR"
                source venv/bin/activate
                
                # 将URL写入临时文件
                echo "$music_url" > /tmp/music_url.txt
                
                python -c "
import requests
import re
import os
from src.converter import AudioConverter
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
import time

# 从文件读取URL
with open('/tmp/music_url.txt', 'r') as f:
    url = f.read().strip()

chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--no-sandbox')
chrome_options.add_argument('--disable-dev-shm-usage')

service = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=service, options=chrome_options)

try:
    print('🔍 获取页面内容...')
    response = requests.get(url, allow_redirects=True)
    final_url = response.url
    
    driver.get(final_url)
    time.sleep(3)
    html = driver.page_source
    
    # 提取歌曲信息
    artist_name = '未知艺术家'
    song_name = '未知歌曲'
    
    # 从页面标题提取
    title_match = re.search(r'<title[^>]*>([^<]+)</title>', html, re.IGNORECASE)
    if title_match:
        title = title_match.group(1).strip()
        print(f'页面标题: {title}')
        
        title = re.sub(r'-汽水音乐$', '', title).strip()
        
        if '-' in title:
            parts = title.split('-')
            if len(parts) >= 2:
                song_name = parts[0].strip()
                artist_name = parts[1].strip()
    
    # 清理文件名
    def clean_filename(name):
        name = re.sub(r'[<>:\"/\\|?*]', '', name)
        name = re.sub(r'[《》@汽水音乐]', '', name)
        return name.strip()
    
    artist_name = clean_filename(artist_name)
    song_name = clean_filename(song_name)
    
    print(f'🎤 艺术家: {artist_name}')
    print(f'🎵 歌曲名: {song_name}')
    
    # 查找音频URL
    audio_url = None
    audio_match = re.search(r'src=\"([^\"]*douyinvod[^\"]*?)\"', html)
    if audio_match:
        audio_url = audio_match.group(1).replace('&amp;', '&')
        print('✅ 找到音频URL')
    
    if audio_url:
        print('⬇️ 开始下载...')
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
            'Referer': 'https://music.douyin.com/'
        }
        
        response = requests.get(audio_url, headers=headers, stream=True)
        if response.status_code == 200:
            temp_filename = f'temp_{int(time.time())}.mp4'
            temp_filepath = f'downloads/{temp_filename}'
            
            with open(temp_filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            file_size = os.path.getsize(temp_filepath)
            print(f'✅ 下载成功: {file_size} bytes')
            
            # 转换为MP3
            converter = AudioConverter()
            result = converter.convert_audio(temp_filepath, keep_original=False)
            
            if result:
                temp_mp3 = temp_filepath.replace('.mp4', '.mp3')
                final_filename = f'{artist_name} - {song_name}.mp3'
                target_path = f'$DOWNLOAD_DIR/{final_filename}'
                
                import shutil
                shutil.move(temp_mp3, target_path)
                print(f'📁 已保存为: {final_filename}')
                
                # 标记下载成功
                with open('/tmp/download_success', 'w') as f:
                    f.write('success')
            else:
                print('❌ 转换失败')
        else:
            print(f'❌ 下载失败: HTTP {response.status_code}')
    else:
        print('❌ 未找到音频URL')
        
except Exception as e:
    print(f'❌ 错误: {e}')
finally:
    driver.quit()
    if os.path.exists('/tmp/music_url.txt'):
        os.remove('/tmp/music_url.txt')
"
                
                cd "$SCRIPT_DIR"
                
                # 检查是否下载成功，如果成功则记录到历史文件
                if [ -f "/tmp/download_success" ]; then
                    echo "$music_url" >> "$HISTORY_FILE"
                    echo "📝 已记录到历史文件"
                    rm -f "/tmp/download_success"
                fi
                
                echo ""
            fi
        fi
        # 如果不是汽水音乐链接，静默忽略，不显示任何信息
        
        last_clipboard="$current_clipboard"
    fi
    
    sleep 1
done
