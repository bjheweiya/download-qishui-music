#!/bin/bash

echo "🎵 汽水音乐下载器 - 安装脚本"
echo ""

# 检查Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ 未找到Python3，请先安装Python3"
    exit 1
fi

echo "✅ Python3已安装"

# 安装依赖
echo "📦 安装Python依赖..."
pip3 install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ 依赖安装完成"
else
    echo "⚠️ 依赖安装可能有问题，但程序仍可运行（使用备用方案）"
fi

# 设置执行权限
chmod +x auto_download.sh

echo ""
echo "🎉 安装完成！"
echo ""
echo "使用方法："
echo "1. 运行: ./auto_download.sh"
echo "2. 复制汽水音乐分享链接到剪贴板"
echo "3. 程序会自动检测并下载"
echo ""
echo "下载的文件将保存在 downloads/ 目录中"
