#!/bin/bash

# 汽水音乐下载器安装脚本
echo "🎵 汽水音乐下载器安装程序"
echo "========================="
echo ""

# 检查系统要求
check_requirements() {
    echo "🔍 检查系统要求..."
    
    # 检查macOS版本
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "❌ 此工具仅支持macOS系统"
        exit 1
    fi
    
    # 检查Python版本
    if ! command -v python3 &> /dev/null; then
        echo "❌ 未找到Python3，请先安装Python 3.7+"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    echo "✅ Python版本: $PYTHON_VERSION"
    
    # 检查pip
    if ! command -v pip3 &> /dev/null; then
        echo "❌ 未找到pip3，请先安装pip"
        exit 1
    fi
    
    echo "✅ 系统要求检查通过"
}

# 安装Python依赖
install_dependencies() {
    echo ""
    echo "📦 安装Python依赖..."
    
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt
        if [ $? -eq 0 ]; then
            echo "✅ Python依赖安装成功"
        else
            echo "❌ Python依赖安装失败"
            echo "💡 尝试使用虚拟环境："
            echo "   python3 -m venv venv"
            echo "   source venv/bin/activate"
            echo "   pip install -r requirements.txt"
            exit 1
        fi
    else
        echo "❌ 未找到requirements.txt文件"
        exit 1
    fi
}

# 设置脚本权限
setup_permissions() {
    echo ""
    echo "🔧 设置脚本权限..."
    
    chmod +x scripts/*.sh
    echo "✅ 脚本权限设置完成"
}

# 创建必要目录
create_directories() {
    echo ""
    echo "📁 创建必要目录..."
    
    mkdir -p download_music
    touch download_history.txt
    
    echo "✅ 目录创建完成"
}

# 测试安装
test_installation() {
    echo ""
    echo "🧪 测试安装..."
    
    # 测试Python导入
    python3 -c "import requests, selenium, moviepy; print('✅ Python包导入成功')" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "❌ Python包导入失败"
        return 1
    fi
    
    # 测试剪贴板功能
    echo "test" | pbcopy && pbpaste > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ 剪贴板功能正常"
    else
        echo "❌ 剪贴板功能异常"
        return 1
    fi
    
    echo "✅ 安装测试通过"
}

# 显示使用说明
show_usage() {
    echo ""
    echo "🎉 安装完成！"
    echo "============"
    echo ""
    echo "📖 使用方法："
    echo "1. 启动下载器："
    echo "   cd scripts"
    echo "   ./auto_download_final.sh"
    echo ""
    echo "2. 在汽水音乐中复制分享链接"
    echo "3. 脚本会自动检测并下载"
    echo ""
    echo "📁 下载的音乐保存在: download_music/"
    echo "📝 历史记录保存在: download_history.txt"
    echo ""
    echo "🔧 管理工具："
    echo "   ./scripts/manage_history.sh list    # 查看下载历史"
    echo "   ./scripts/get_share_link.sh         # 获取分享链接助手"
    echo ""
    echo "📚 更多信息请查看 README.md"
}

# 主安装流程
main() {
    check_requirements
    install_dependencies
    setup_permissions
    create_directories
    
    if test_installation; then
        show_usage
    else
        echo ""
        echo "⚠️ 安装完成但测试失败，请检查错误信息"
        echo "💡 可以尝试手动运行脚本进行测试"
    fi
}

# 运行安装
main
