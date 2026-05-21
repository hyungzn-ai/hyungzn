@echo off
cd /d C:\Users\91618\WriteMon
echo APK 빌드 시작...
C:\Users\91618\flutter\bin\flutter.bat build apk --release > C:\Users\91618\WriteMon\build_apk_log.txt 2>&1
echo 빌드 완료! >> C:\Users\91618\WriteMon\build_apk_log.txt
echo.
echo === 빌드 결과 ===
if exist "C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release.apk" (
    echo 성공! APK 파일 생성됨
    copy "C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release.apk" "C:\Users\91618\WriteMon\writemon.apk"
    echo writemon.apk 복사 완료
) else (
    echo 실패. build_apk_log.txt 확인 필요
)
pause
