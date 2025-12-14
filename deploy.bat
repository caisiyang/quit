@echo off
chcp 65001 >nul
title GitHub 自动部署脚本
color 0A

echo ========================================
echo           GitHub 自动部署助手
echo ========================================
echo.

:INPUT_COMMIT
set /p "commit_msg=请输入提交描述 (按回车默认 'Update'): "
if "%commit_msg%"=="" set "commit_msg=Update"

echo.
echo [1/3] 正在添加文件...
git add .
if %errorlevel% neq 0 (
    color 0C
    echo [错误] 添加文件失败，请检查Git状态。
    pause
    exit /b
)

echo.
echo [2/3] 正在提交更改...
git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo [提示] 没有需要提交的更改，正在尝试推送现有提交...
)

echo.
echo [3/3] 正在推送到 GitHub...
git push
if %errorlevel% equ 0 goto SUCCESS

echo.
color 0E
echo [冲突] 推送被拒绝，可能是远程有新版本。
echo [修复] 正在尝试拉取最新代码并合并...
echo.

git pull --rebase
if %errorlevel% neq 0 (
    color 0C
    echo [致命错误] 拉取代码失败，可能存在无法自动解决的冲突。
    echo 请手动打开终端运行 'git status' 解决冲突。
    pause
    exit /b
)

echo.
echo [重试] 正在再次尝试推送...
git push
if %errorlevel% neq 0 (
    color 0C
    echo [失败] 最终推送失败，请检查网络或权限。
    pause
    exit /b
)

:SUCCESS
echo.
color 0A
echo ========================================
echo        🎉 部署成功！
echo ========================================
timeout /t 3 >nul
exit
