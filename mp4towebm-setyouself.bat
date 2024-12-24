@echo off
setlocal EnableDelayedExpansion

rem 設定輸入和輸出資料夾
set "inputDir=%~dp0Video"
set "outputDir=%~dp0webm"
set "logFile=%~dp0error.log"

rem 初始化日誌文件
echo [%date% %time%] 批處理開始運行 >> "%logFile%"

rem 確保輸入和輸出資料夾存在
if not exist "%inputDir%" (
    echo 輸入資料夾 "%inputDir%" 不存在，請確認！
    echo [%date% %time%] 輸入資料夾 "%inputDir%" 不存在，請確認！ >> "%logFile%"
    goto error
)

if not exist "%outputDir%" (
    mkdir "%outputDir%"
)

rem 提示用戶輸入參數
echo 請輸入影片的最大寬度（例如：1280,640,480，直接按 Enter 保持原始寬度）：
set /p "width="
if not "!width!"=="" (
    set "videoWidth=!width!"
) else (
    set "videoWidth="
)

echo 請輸入影片的最大高度（例如：720,480,360，直接按 Enter 保持原始高度）：
set /p "height="
if not "!height!"=="" (
    set "videoHeight=!height!"
) else (
    set "videoHeight="
)

set /p audioBitrate=請輸入音訊的比特率（單位：k，例如：30，按 Enter 預設為 30）：
set /p crfValue=請輸入影片的 CRF 值（範圍：0-63，按 Enter 預設為 35）：

rem 設定預設值
if "!audioBitrate!"=="" set "audioBitrate=30"
if "!crfValue!"=="" set "crfValue=35"

rem 驗證數值輸入
if not "!videoWidth!"=="" (
    for /f "delims=0123456789" %%i in ("!videoWidth!") do (
        echo 影片寬度必須是純數字！
        goto error
    )
)

if not "!videoHeight!"=="" (
    for /f "delims=0123456789" %%i in ("!videoHeight!") do (
        echo 影片高度必須是純數字！
        goto error
    )
)

rem 顯示設定確認
echo.
echo 當前設定：
echo -------------------
if "!videoWidth!"=="" (
    echo 影片寬度：保持原始寬度
) else (
    echo 影片寬度：!videoWidth!
)
if "!videoHeight!"=="" (
    echo 影片高度：保持原始高度
) else (
    echo 影片高度：!videoHeight!
)
echo 音訊比特率：!audioBitrate!k
echo CRF 值：!crfValue!
echo -------------------
echo.
pause

rem 構建 ffmpeg 命令
set "scaleOption="
if not "!videoWidth!"=="" if not "!videoHeight!"=="" (
    set "scaleOption=-vf scale=!videoWidth!:!videoHeight!"
)

rem 搜索並處理輸入資料夾中的檔案
for %%i in ("%inputDir%\*.*") do (
    echo.
    echo 開始處理：%%~nxi
    echo [%date% %time%] 開始處理檔案：%%~nxi >> "%logFile%"
    
    if "!scaleOption!"=="" (
        ffmpeg -i "%%i" -c:v libvpx-vp9 -crf !crfValue! -b:v 0 -c:a libopus -b:a !audioBitrate!k "%outputDir%\%%~ni.webm"
    ) else (
        ffmpeg -i "%%i" -c:v libvpx-vp9 -crf !crfValue! -b:v 0 !scaleOption! -c:a libopus -b:a !audioBitrate!k "%outputDir%\%%~ni.webm"
    )
    
    if errorlevel 1 (
        echo.
        echo 轉換失敗，請檢查輸入檔案或參數！
        echo [%date% %time%] 轉換失敗，檔案：%%~nxi >> "%logFile%"
        goto error
    ) else (
        echo.
        echo 轉換成功：%%~nxi
        echo [%date% %time%] 成功處理檔案：%%~nxi >> "%logFile%"
    )
)
rem 顯示完成消息
echo.
echo 所有檔案轉換完成！
powershell -Command "[console]::beep(1400,300)"
msg * "轉換完成！"

goto end

:error
echo.
echo 發生錯誤，程式將退出
echo 請檢查 error.log 檔案以獲取詳細資訊
pause
exit /b 1

:end
echo.
echo 按任意鍵退出程式...
pause > nul
exit /b 0
