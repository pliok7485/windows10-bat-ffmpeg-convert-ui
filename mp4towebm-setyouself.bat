chcp 65001
@echo off
setlocal EnableDelayedExpansion

rem 設定輸入和輸出資料夾
set "inputDir=%~dp0Video"
set "outputDir=%~dp0webm"

rem 記錄開始時間
set "startTime=%time%"

rem 檢查並創建輸入資料夾
if not exist "%inputDir%" (
    echo 輸入資料夾 "%inputDir%" 不存在，正在建立...
    mkdir "%inputDir%"
    echo 已建立輸入資料夾："%inputDir%"
    echo 請將要轉換的影片放入 Video 資料夾中
    pause
    goto end
)

rem 檢查並創建輸出資料夾
if not exist "%outputDir%" (
    echo 輸出資料夾 "%outputDir%" 不存在，正在建立...
    mkdir "%outputDir%"
    echo 已建立輸出資料夾："%outputDir%"
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
    
    if "!scaleOption!"=="" (
        ffmpeg -i "%%i" -c:v libvpx-vp9 -crf !crfValue! -b:v 0 -c:a libopus -b:a !audioBitrate!k "%outputDir%\%%~ni.webm"
    ) else (
        ffmpeg -i "%%i" -c:v libvpx-vp9 -crf !crfValue! -b:v 0 !scaleOption! -c:a libopus -b:a !audioBitrate!k "%outputDir%\%%~ni.webm"
    )
    
    if errorlevel 1 (
        echo.
        echo 轉換失敗，請檢查輸入檔案或參數！
        goto error
    ) else (
        echo.
        echo 轉換成功：%%~nxi
    )
)

rem 計算並顯示轉換時間
set "endTime=%time%"
for /f "tokens=1-4 delims=:.," %%a in ("%startTime%") do set /a "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
for /f "tokens=1-4 delims=:.," %%a in ("%endTime%") do set /a "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
set /a elapsed=end-start
set /a hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100, cc=rest%%100
if %hh% lss 10 set hh=0%hh%
if %mm% lss 10 set mm=0%mm%
if %ss% lss 10 set ss=0%ss%

rem 顯示完成消息
echo.
echo 所有檔案轉換完成！
echo 總轉換時間：%hh%時%mm%分%ss%秒
powershell -Command "[console]::beep(1400,300)"
msg * "轉換完成！"

goto end

:error
echo.
echo 發生錯誤，程式將退出
pause
exit /b 1

:end
echo.
echo 按任意鍵退出程式...
pause > nul
exit /b 0
