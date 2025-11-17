#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import warnings
warnings.filterwarnings('ignore', category=RuntimeWarning)

import os
import sys
import requests
import re
import time
import json
from converter import AudioConverter

def ms_to_lrc_time(ms):
    """将毫秒转换为LRC时间格式 [mm:ss.xx]"""
    minutes = ms // 60000
    seconds = (ms % 60000) // 1000
    centiseconds = (ms % 1000) // 10
    return f'[{minutes:02d}:{seconds:02d}.{centiseconds:02d}]'

def extract_lyrics_from_json(html):
    """从页面JSON数据中提取歌词"""
    try:
        json_patterns = [
            r'window\.__ROUTER_DATA__\s*=\s*(\{.*?\});',
            r'_ROUTER_DATA\s*=\s*(\{.*?\});',
            r'window\.__INITIAL_STATE__\s*=\s*(\{.*?\});'
        ]
        
        for pattern in json_patterns:
            matches = re.findall(pattern, html, re.DOTALL)
            for match in matches:
                try:
                    data = json.loads(match)
                    
                    def find_lyrics_data(obj):
                        if isinstance(obj, dict):
                            if 'lyrics' in obj and isinstance(obj['lyrics'], dict):
                                if 'sentences' in obj['lyrics']:
                                    return obj['lyrics']
                            for value in obj.values():
                                result = find_lyrics_data(value)
                                if result:
                                    return result
                        elif isinstance(obj, list):
                            for item in obj:
                                result = find_lyrics_data(item)
                                if result:
                                    return result
                        return None
                    
                    lyrics_data = find_lyrics_data(data)
                    if lyrics_data and 'sentences' in lyrics_data:
                        lrc_lines = []
                        for sentence in lyrics_data['sentences']:
                            if 'startMs' in sentence and 'text' in sentence:
                                time_tag = ms_to_lrc_time(sentence['startMs'])
                                text = sentence['text']
                                lrc_lines.append(f'{time_tag}{text}')
                        
                        if lrc_lines:
                            return '\n'.join(lrc_lines)
                            
                except json.JSONDecodeError:
                    continue
                    
        return None
    except Exception as e:
        print(f'JSON歌词提取失败: {e}')
        return None

def clean_filename(name):
    """清理文件名"""
    name = re.sub(r'[<>:"/\\|?*]', '', name)
    name = re.sub(r'[《》@汽水音乐]', '', name)
    return name.strip()

def download_music(url, download_dir):
    """下载音乐和歌词"""
    try:
        print('🔍 获取页面内容...')
        headers = {
            'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1'
        }
        
        response = requests.get(url, headers=headers, allow_redirects=True, timeout=10)
        html = response.text
        
        # 提取歌曲信息
        artist_name = '未知艺术家'
        song_name = '未知歌曲'
        
        track_name_match = re.search(r'"trackName":"([^"]+)"', html)
        if track_name_match:
            song_name = track_name_match.group(1)
            print(f'🎵 歌曲名: {song_name}')
        
        artist_name_match = re.search(r'"artistName":"([^"]+)"', html)
        if artist_name_match:
            artist_name = artist_name_match.group(1)
            print(f'🎤 艺术家: {artist_name}')
        
        # 获取歌词
        print('🔍 查找歌词信息...')
        lyrics_text = extract_lyrics_from_json(html)
        
        if not lyrics_text:
            lyrics_patterns = [
                r'"lyrics":"([^"]+)"',
                r'"lyric":"([^"]+)"',
                r'"lrcContent":"([^"]+)"',
                r'"lrc":"([^"]+)"'
            ]
            
            for pattern in lyrics_patterns:
                lyrics_match = re.search(pattern, html)
                if lyrics_match:
                    lyrics_text = lyrics_match.group(1)
                    lyrics_text = lyrics_text.replace('\\n', '\n').replace('\\r', '')
                    break
        
        # 清理文件名
        artist_name = clean_filename(artist_name)
        song_name = clean_filename(song_name)
        
        # 获取音频URL
        pattern = r'"url":"([^"]*douyinvod[^"]*?)"'
        audio_match = re.search(pattern, html)
        
        if not audio_match:
            print('❌ 未找到音频URL')
            return False
        
        audio_url = audio_match.group(1).replace('\\u002F', '/').replace('\\u0026', '&').replace('&amp;', '&')
        print('✅ 找到音频URL')
        
        # 下载音频
        print('⬇️ 开始下载...')
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Referer': 'https://music.douyin.com/',
        }
        
        response = requests.get(audio_url, headers=headers, stream=True, timeout=30)
        if response.status_code != 200:
            print(f'❌ 下载失败: HTTP {response.status_code}')
            return False
        
        # 保存临时文件
        temp_filename = f'temp_{int(time.time())}.mp4'
        temp_filepath = os.path.join(download_dir, temp_filename)
        
        with open(temp_filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
        
        file_size = os.path.getsize(temp_filepath)
        print(f'✅ 下载成功: {file_size} bytes')
        
        if file_size < 1000:
            print('❌ 下载的文件太小')
            os.remove(temp_filepath)
            return False
        
        # 转换为MP3
        try:
            converter = AudioConverter()
            result = converter.convert_audio(temp_filepath)
            
            if result:
                temp_mp3 = temp_filepath.replace('.mp4', '.mp3')
                final_filename = f'{artist_name} - {song_name}.mp3'
                target_path = os.path.join(download_dir, final_filename)
                
                import shutil
                shutil.move(temp_mp3, target_path)
                print(f'📁 已保存为: {final_filename}')
            else:
                # 转换失败，保存原文件
                final_filename = f'{artist_name} - {song_name}.mp4'
                target_path = os.path.join(download_dir, final_filename)
                import shutil
                shutil.move(temp_filepath, target_path)
                print(f'📁 已保存原文件为: {final_filename}')
        except Exception as e:
            print(f'转换失败: {e}，保存原文件')
            final_filename = f'{artist_name} - {song_name}.mp4'
            target_path = os.path.join(download_dir, final_filename)
            import shutil
            shutil.move(temp_filepath, target_path)
            print(f'📁 已保存原文件为: {final_filename}')
        
        # 保存歌词
        if lyrics_text:
            lyrics_filename = f'{artist_name} - {song_name}.lrc'
            lyrics_path = os.path.join(download_dir, lyrics_filename)
            
            with open(lyrics_path, 'w', encoding='utf-8') as f:
                f.write(lyrics_text)
            print(f'📝 歌词已保存为: {lyrics_filename}')
        
        return True
        
    except Exception as e:
        print(f'❌ 错误: {e}')
        return False

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('用法: python3 downloader.py <URL> <下载目录>')
        sys.exit(1)
    
    url = sys.argv[1]
    download_dir = sys.argv[2]
    
    os.makedirs(download_dir, exist_ok=True)
    
    success = download_music(url, download_dir)
    sys.exit(0 if success else 1)
