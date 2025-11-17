# 📦 详细安装说明

## 系统要求检查

### 1. 检查macOS版本
```bash
sw_vers
```
需要 macOS 10.15 (Catalina) 或更高版本。

### 2. 检查Python版本
```bash
python3 --version
```
需要 Python 3.7 或更高版本。

### 3. 检查Chrome浏览器
确保已安装 Google Chrome 浏览器。

## 安装步骤

### 方法一：使用pip安装依赖
```bash
# 安装必需的Python包
pip3 install requests selenium moviepy webdriver-manager

# 验证安装
python3 -c "import requests, selenium, moviepy; print('所有依赖安装成功')"
```

### 方法二：使用虚拟环境（推荐）
```bash
# 创建虚拟环境
python3 -m venv soda-music-env

# 激活虚拟环境
source soda-music-env/bin/activate

# 安装依赖
pip install requests selenium moviepy webdriver-manager

# 验证安装
python -c "import requests, selenium, moviepy; print('虚拟环境设置成功')"
```

## 权限设置

### 1. 终端权限
首次运行脚本时，系统可能会要求授予终端以下权限：
- 辅助功能访问
- 屏幕录制权限

在 **系统偏好设置** → **安全性与隐私** → **隐私** 中授予相应权限。

### 2. 网络权限
确保防火墙允许脚本访问网络。

## 测试安装

### 1. 基本功能测试
```bash
# 进入脚本目录
cd scripts

# 测试剪贴板功能
echo "test" | pbcopy && pbpaste

# 测试网络连接
curl -I https://qishui.douyin.com
```

### 2. 运行测试脚本
```bash
# 运行主脚本（测试模式）
timeout 5s ./auto_download_final.sh
```

## 故障排除

### 问题1: Python包安装失败
```bash
# 升级pip
pip3 install --upgrade pip

# 使用国内镜像源
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple requests selenium moviepy webdriver-manager
```

### 问题2: Chrome WebDriver问题
```bash
# 手动安装ChromeDriver
brew install chromedriver

# 或者让脚本自动下载
python3 -c "from webdriver_manager.chrome import ChromeDriverManager; ChromeDriverManager().install()"
```

### 问题3: 权限被拒绝
```bash
# 给脚本执行权限
chmod +x scripts/*.sh

# 检查文件权限
ls -la scripts/
```

### 问题4: 网络连接问题
```bash
# 测试网络连接
ping qishui.douyin.com

# 检查DNS设置
nslookup qishui.douyin.com
```

## 高级配置

### 自定义下载目录
编辑脚本文件，修改 `DOWNLOAD_DIR` 变量：
```bash
DOWNLOAD_DIR="/path/to/your/music/folder"
```

### 自定义音频质量
在脚本中可以调整音频转换参数：
```bash
# 在converter.py中修改bitrate参数
bitrate="320k"  # 高质量
bitrate="128k"  # 标准质量
```

## 卸载

### 删除Python包
```bash
pip3 uninstall requests selenium moviepy webdriver-manager
```

### 删除项目文件
```bash
rm -rf soda-music-downloader/
```

### 清理虚拟环境
```bash
rm -rf soda-music-env/
```

## 更新

### 更新Python包
```bash
pip3 install --upgrade requests selenium moviepy webdriver-manager
```

### 更新项目代码
```bash
git pull origin main
```
