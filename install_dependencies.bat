@echo off
echo AI Music Player - 依赖安装脚本
echo.

REM 检查是否安装了Flutter
where flutter >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo 错误: 未找到Flutter命令
    echo 请先安装Flutter SDK并将其添加到系统PATH环境变量中
    echo 访问 https://docs.flutter.dev/get-started/install/windows 获取安装说明
    pause
    exit /b 1
)

echo 检测到Flutter安装，版本信息：
flutter --version
echo.

echo 正在安装项目依赖...
flutter pub get
if %ERRORLEVEL% neq 0 (
    echo 依赖安装失败
    pause
    exit /b 1
)

echo 依赖安装完成！

REM 检查并启用桌面支持
echo.
echo 检查桌面平台支持...
flutter devices
echo.

echo 安装完成！您可以运行以下命令启动应用：
echo flutter run -d windows
echo.
pause