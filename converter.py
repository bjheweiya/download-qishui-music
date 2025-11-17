# -*- coding: utf-8 -*-

import os
import shutil
from pathlib import Path

try:
    from moviepy import AudioFileClip, VideoFileClip
    MOVIEPY_AVAILABLE = True
except ImportError:
    MOVIEPY_AVAILABLE = False

class AudioConverter:
    """音频转换器"""
    
    def __init__(self, output_format: str = "mp3", bitrate: str = "192k"):
        self.output_format = output_format
        self.bitrate = bitrate
    
    def has_video_stream(self, input_file: str) -> bool:
        """检测MP4文件是否包含视频流"""
        if not MOVIEPY_AVAILABLE:
            return False
            
        try:
            video_clip = VideoFileClip(input_file)
            has_video = video_clip.w > 0 and video_clip.h > 0
            video_clip.close()
            return has_video
        except:
            return False
    
    def convert_audio(self, input_file: str, keep_original: bool = False):
        """转换音频格式"""
        if not MOVIEPY_AVAILABLE:
            print("⚠️ MoviePy未安装，使用备用方案")
            return self._fallback_rename(input_file, keep_original)
            
        try:
            output_file = input_file.replace('.mp4', f'.{self.output_format}')
            
            print(f"🔄 开始转换音频格式: {os.path.basename(input_file)} -> {self.output_format.upper()}")
            
            # 检测是否有视频流
            has_video = self.has_video_stream(input_file)
            if has_video:
                print("📹 检测到视频内容，将保留MP4和MP3两个文件")
                keep_original = True
            else:
                print("🎵 仅包含音频内容")
            
            # 使用MoviePy转换
            audio_clip = AudioFileClip(input_file)
            
            try:
                audio_clip.write_audiofile(output_file, bitrate=self.bitrate, logger=None)
            except:
                audio_clip.write_audiofile(output_file, logger=None)
            
            audio_clip.close()
            
            print(f"✅ 音频转换完成: {os.path.basename(output_file)}")
            
            if not keep_original:
                os.remove(input_file)
                print(f"🗑️ 已删除原文件: {os.path.basename(input_file)}")
            
            return output_file
            
        except Exception as e:
            print(f"❌ 音频转换失败: {e}")
            return self._fallback_rename(input_file, keep_original)
    
    def _fallback_rename(self, input_file: str, keep_original: bool):
        """备用方案：重命名文件"""
        try:
            print("🔄 使用备用方案：重命名文件")
            output_file = input_file.replace('.mp4', f'.{self.output_format}')
            shutil.copy2(input_file, output_file)
            
            if not keep_original:
                os.remove(input_file)
                print(f"🗑️ 已删除原文件: {os.path.basename(input_file)}")
            
            print(f"✅ 文件已重命名: {os.path.basename(output_file)}")
            return output_file
            
        except Exception as e:
            print(f"❌ 备用方案失败: {e}")
            return None
