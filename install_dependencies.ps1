Write-Host "AI Music Player - 依赖安装脚本" -ForegroundColor Green
Write-Host ""

# 检查是否安装了Flutter
try {
    $flutterVersion = flutter --version
    Write-Host "检测到Flutter安装：" -ForegroundColor Green
    Write-Host $flutterVersion
    Write-Host ""
} 
catch {
    Write-Host "错误: 未找到Flutter命令" -ForegroundColor Red
    Write-Host "请先安装Flutter SDK并将其添加到系统PATH环境变量中" -ForegroundColor Red
    Write-Host "访问 https://docs.flutter.dev/get-started/install/windows 获取安装说明" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

Write-Host "正在安装项目依赖..." -ForegroundColor Yellow
try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "依赖安装失败"
    }
    Write-Host "依赖安装完成！" -ForegroundColor Green
}
catch {
    Write-Host "依赖安装失败: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

Write-Host ""
Write-Host "检查桌面平台支持..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "安装完成！您可以运行以下命令启动应用：" -ForegroundColor Green
Write-Host "flutter run -d windows" -ForegroundColor Cyan
Write-Host ""
Read-Host "按任意键退出"