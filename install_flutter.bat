@echo off
echo Flutter 설치 시작... > C:\Users\91618\WriteMon\install_log.txt
echo ======================== >> C:\Users\91618\WriteMon\install_log.txt

REM winget으로 Flutter 설치 (관리자 권한 필요)
echo [1] winget Flutter 설치 중... >> C:\Users\91618\WriteMon\install_log.txt
winget install --id Google.Flutter --accept-source-agreements --accept-package-agreements >> C:\Users\91618\WriteMon\install_log.txt 2>&1

echo. >> C:\Users\91618\WriteMon\install_log.txt
echo [2] 설치 후 PATH 확인... >> C:\Users\91618\WriteMon\install_log.txt
where flutter >> C:\Users\91618\WriteMon\install_log.txt 2>&1

echo. >> C:\Users\91618\WriteMon\install_log.txt
echo [3] flutter --version 확인... >> C:\Users\91618\WriteMon\install_log.txt
flutter --version >> C:\Users\91618\WriteMon\install_log.txt 2>&1

echo. >> C:\Users\91618\WriteMon\install_log.txt
echo [4] flutter pub get 실행... >> C:\Users\91618\WriteMon\install_log.txt
cd /d C:\Users\91618\WriteMon
flutter pub get >> C:\Users\91618\WriteMon\install_log.txt 2>&1

echo. >> C:\Users\91618\WriteMon\install_log.txt
echo [5] flutter analyze 실행... >> C:\Users\91618\WriteMon\install_log.txt
flutter analyze >> C:\Users\91618\WriteMon\install_log.txt 2>&1

echo. >> C:\Users\91618\WriteMon\install_log.txt
echo === 완료 === >> C:\Users\91618\WriteMon\install_log.txt
