@echo off
chcp 65001 > nul
echo ============================================
echo  Text Saver - Windows 安裝程式
echo ============================================
echo.

:: 檢查 Python
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] 找不到 Python！
    echo 請先安裝 Python 3.x: https://www.python.org/downloads/
    echo 安裝時請勾選 "Add Python to PATH"
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo [OK] 找到 %%i

:: 檢查 AutoHotkey
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" (
    echo [OK] 找到 AutoHotkey
) else if exist "%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe" (
    echo [OK] 找到 AutoHotkey
) else (
    echo [WARN] 未找到 AutoHotkey
    echo 請安裝 AutoHotkey v1.1+: https://www.autohotkey.com/
    echo.
)

:: 建立設定中的資料夾
echo.
echo [*] 建立儲存資料夾...
python -c "
import json, os
with open('config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)
for key in ['inbox_folder', 'daily_folder']:
    if key in config:
        folder = os.path.expanduser(config[key])
        os.makedirs(folder, exist_ok=True)
        print(f'  建立: {folder}')
print('  完成！')
"

:: 詢問是否加入開機自動啟動
echo.
set /p ADD_STARTUP="是否加入 Windows 開機自動啟動？(y/n): "
if /i "%ADD_STARTUP%"=="y" (
    set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
    copy /y "%~dp0text_saver.ahk" "%STARTUP_DIR%\text_saver.ahk" > nul
    echo [OK] 已加入開機啟動: %STARTUP_DIR%\text_saver.ahk
)

:: 詢問是否立即啟動
echo.
set /p RUN_NOW="是否立即啟動 Text Saver？(y/n): "
if /i "%RUN_NOW%"=="y" (
    start "" "%~dp0text_saver.ahk"
    echo [OK] Text Saver 已啟動！
)

echo.
echo ============================================
echo  安裝完成！
echo  使用方式：選取文字後按 Ctrl+Shift+S 儲存
echo  模式設定：編輯 config.json 或點擊系統匣圖示
echo ============================================
echo.
pause
