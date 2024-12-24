@echo off

rem �]�w��J�M��X��Ƨ�
set "inputDir=%~dp0Video"
set "outputDir=%~dp0webm"

rem �T�O��J�M��X��Ƨ��s�b
if not exist "%inputDir%" (
    echo ��J��Ƨ� "%inputDir%" ���s�b�A�нT�{�I
    pause
    exit /b
)

if not exist "%outputDir%" (
    mkdir "%outputDir%"
)

rem ���ܥΤ��J�Ѽ�
set /p videoWidth=�п�J�v�����̤j�e�ס]�Ҧp�G1280,640,480�A�� Enter ���L�^�G 
set /p videoHeight=�п�J�v�����̤j���ס]�Ҧp�G720,480,360�A�� Enter ���L�^�G 
set /p audioBitrate=�п�J���T����S�v�]���Gk�A�Ҧp�G30�A�� Enter �w�]�� 30�^�G 
set /p crfValue=�п�J�v���� CRF �ȡ]�d��G0-63�A�� Enter �w�]�� 35�^�G 

rem �]�w�w�]��
if not defined audioBitrate set "audioBitrate=30"
if not defined crfValue set "crfValue=35"

rem ��ܳ]�w�T�{
echo �v���e�סG%videoWidth%
echo �v�����סG%videoHeight%
echo ���T��S�v�G%audioBitrate%k
echo CRF �ȡG%crfValue%
pause

rem �c���Y��Ѽ�
set "scaleOption="
if defined videoWidth if defined videoHeight (
    set "scaleOption=-vf scale='if(gt(iw/ih,%videoWidth%/%videoHeight%),%videoWidth%,-1)':'if(gt(iw/ih,%videoWidth%/%videoHeight%),-1,%videoHeight%)'"
) else (
    rem �Y�S���e���A�h���[�Y��Ѽ�
    set "scaleOption="
)

rem �O���_�l�ɶ�
set startTime=%time%

rem �j���óB�z��J��Ƨ������ɮ�
for %%i in ("%inputDir%\*.*") do (
    echo �B�z�ɮסG%%~nxi
    ffmpeg -i "%%i" -c:v libvpx-vp9 -crf %crfValue% -b:v 0 %scaleOption% -c:a libopus -b:a %audioBitrate%k "%outputDir%\%%~ni.webm"
    if errorlevel 1 (
        echo �ഫ���ѡA���ˬd��J�ɮשΰѼơI
        pause
        exit /b
    )
)

rem �O�������ɶ�
set endTime=%time%

rem �p��Ӯ�
call :calculateTime "%startTime%" "%endTime%"

echo �����I
powershell -Command "[console]::beep(1400,300)"
msg * "�ഫ�����I"

rem �������O���}��
pause
exit /b

:calculateTime
setlocal
set "start=%~1"
set "end=%~2"

rem �ѪR�_�l�ɶ�
for /f "tokens=1-4 delims=:., " %%a in ("%start%") do (
    set /a "startH=%%a, startM=%%b, startS=%%c, startMS=%%d"
)

rem �ѪR�����ɶ�
for /f "tokens=1-4 delims=:., " %%a in ("%end%") do (
    set /a "endH=%%a, endM=%%b, endS=%%c, endMS=%%d"
)

rem �N�ɶ��ର�`�@���
set /a "startTotalMS=(startH*3600 + startM*60 + startS)*1000 + startMS"
set /a "endTotalMS=(endH*3600 + endM*60 + endS)*1000 + endMS"

rem �B�z��ȩ]�����p
if %endTotalMS% lss %startTotalMS% set /a "endTotalMS+=86400000"

rem �p��Ӯ��`�@���
set /a "elapsedMS=endTotalMS - startTotalMS"
set /a "elapsedS=elapsedMS / 1000, elapsedMS=elapsedMS %% 1000"
set /a "elapsedM=elapsedS / 60, elapsedS=elapsedS %% 60"

rem ��X�榡�ƪ����G
echo �`�ӮɡG%elapsedM% �� %elapsedS% ��
exit /b
