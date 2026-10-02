# DailyFlow Multi-Platform Release Build Script
$env:ComSpec = "C:\Windows\System32\cmd.exe"
$env:PATH = "C:\flutter\bin;C:\Program Files\Git\cmd;C:\Windows\System32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0\;" + $env:PATH

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  DailyFlow 🌊 - Release Build Script     " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Create Output Releases Directory
$distDir = Join-Path $PSScriptRoot "DailyFlow_Releases"
if (-not (Test-Path $distDir)) {
    New-Item -ItemType Directory -Path $distDir | Out-Null
}

Write-Host "`n1. Building Production Web App Release..." -ForegroundColor Yellow
flutter build web --release
if (Test-Path "$PSScriptRoot\build\web") {
    $webTarget = "$distDir\DailyFlow_Web"
    if (Test-Path $webTarget) { Remove-Item $webTarget -Recurse -Force }
    Copy-Item "$PSScriptRoot\build\web" -Destination $webTarget -Recurse
    Write-Host "✅ Web release saved to: $webTarget" -ForegroundColor Green
}

Write-Host "`n2. Building Android APK Release..." -ForegroundColor Yellow
flutter build apk --release
if (Test-Path "$PSScriptRoot\build\app\outputs\flutter-apk\app-release.apk") {
    Copy-Item "$PSScriptRoot\build\app\outputs\flutter-apk\app-release.apk" -Destination "$distDir\DailyFlow_Android.apk" -Force
    Write-Host "✅ Android APK saved to: $distDir\DailyFlow_Android.apk" -ForegroundColor Green
}

Write-Host "`n3. Building Windows Desktop EXE Release..." -ForegroundColor Yellow
flutter build windows --release
if (Test-Path "$PSScriptRoot\build\windows\x64\runner\Release") {
    $winTarget = "$distDir\DailyFlow_Windows_Desktop"
    if (Test-Path $winTarget) { Remove-Item $winTarget -Recurse -Force }
    Copy-Item "$PSScriptRoot\build\windows\x64\runner\Release" -Destination $winTarget -Recurse
    Write-Host "✅ Windows Desktop EXE saved to: $winTarget" -ForegroundColor Green
}

Write-Host "`n🎉 All builds complete! Check $distDir folder." -ForegroundColor Cyan
