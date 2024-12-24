@echo off

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
    pause
    exit /b
)

if not exist "%outputDir%" (
    mkdir "%outputDir%"
)

rem 提示用戶輸入參數
set /p videoWidth=請輸入影片的最大寬度（例如：1280,640,480，按 Enter 跳過）： 
set /p videoHeight=請輸入影片的最大高度（例如：720,480,360，按 Enter 跳過）： 
set /p audioBitrate=請輸入音訊的比特率（單位：k，例如：30，按 Enter 預設為 30）： 
set /p crfValue=請輸入影片的 CRF 值（範圍：0-63，按 Enter 預設為 35）： 

rem 設定預設值
if not defined audioBitrate set "audioBitrate=30"
if not defined crfValue set "crfValue=35"

rem 驗證輸入值
if defined videoWidth if defined videoHeight (
    if not "%videoWidth%"=="%videoWidth:~-4%" (
        echo 影片寬度應為數值！
        echo [%date% %time%] 影片寬度應為數值！ >> "%logFile%"
        pause
        exit /b
    )
    if not "%videoHeight%"=="%videoHeight:~-4%" (
        echo 影片高度應為數值！
        echo [%date% %time%] 影片高度應為數值！ >> "%logFile%"
        pause
        exit /b
    )
)
if not "%audioBitrate%"=="%audioBitrate:~-4%" (
    echo 音訊比特率應為數值！
    echo [%date% %time%] 音訊比特率應為數值！ >> "%logFile%"
    pause
    exit /b
)
if %crfValue% lss 0 if %crfValue% gtr 63 (
    echo CRF 值應在範圍 0-63 之間！
    echo [%date% %time%] CRF 值應在範圍 0-63 之間！ >> "%logFile%"
    pause
    exit /b
)

rem 顯示設定確認
echo 影片寬度：%videoWidth%
echo 影片高度：%videoHeight%
echo 音訊比特率：%audioBitrate%k
echo CRF 值：%crfValue%
pause

rem 構建縮放參數
set "scaleOption="
if defined videoWidth if defined videoHeight (
    set "scaleOption=-vf scale='if(gt(iw/ih,%videoWidth%/%videoHeight%),%videoWidth%,-1)':'if(gt(iw/ih,%videoWidth%/%videoHeight%),-1,%videoHeight%)'"
) else (
    rem 若沒有寬高，則不加縮放參數
    set "scaleOption="
)

rem 記錄起始時間
set startTime=%time%

rem 搜索並處理輸入資料夾中的檔案
for %%i in ("%inputDir%\*.*") do (
    echo 處理檔案：%%~nxi
    ffmpeg -i "%%i" -c:v libvpx-vp9 -crf %crfValue% -b:v 0 %scaleOption% -c:a libopus -b:a %audioBitrate%k "%outputDir%\%%~ni.webm" 2>> "%logFile%"
    if errorlevel 1 (
        echo 轉換失敗，請檢查輸入檔案或參數！
        echo [%date% %time%] 轉換失敗，檔案：%%~nxi，請檢查輸入檔案或參數！ >> "%logFile%"
        pause
        exit /b
    )
)

rem 記錄結束時間
set endTime=%time%

rem 計算耗時
call :calculateTime "%startTime%" "%endTime%"

echo 完成！
powershell -Command "[console]::beep(1400,300)"
msg * "轉換完成！"

rem 讓視窗保持開啟
pause
exit /b

:calculateTime
setlocal
set "start=%~1"
set "end=%~2"

rem 解析起始時間
for /f "tokens=1-4 delims=:., " %%a in ("%start%") do (
    set /a "startH=%%a, startM=%%b, startS=%%c, startMS=%%d"
)

rem 解析結束時間
for /f "tokens=1-4 delims=:., " %%a in ("%end%") do (
    set /a "endH=%%a, endM=%%b, endS=%%c, endMS=%%d"
)

rem 將時間轉為總毫秒數
set /a "startTotalMS=(startH*3600 + startM*60 + startS)*1000 + startMS"
set /a "endTotalMS=(endH*3600 + endM*60 + endS)*1000 + endMS"

rem 處理跨午夜的情況
if %endTotalMS% lss %startTotalMS% set /a "endTotalMS+=86400000"

rem 計算耗時總毫秒數
set /a "elapsedMS=endTotalMS - startTotalMS"
set /a "elapsedS=elapsedMS / 1000, elapsedMS=elapsedMS %% 1000"
set /a "elapsedM=elapsedS / 60, elapsedS=elapsedS %% 60"

rem 輸出格式化的結果
echo 總耗時：%elapsedM% 分 %elapsedS% 秒
exit /b
