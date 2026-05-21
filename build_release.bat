@echo off
chcp 65001 > nul
cd /d C:\Users\91618\WriteMon
set PATH=C:\Users\91618\flutter\bin;%PATH%
echo =============================================
echo  WriteMon APK Build
echo =============================================
echo.
flutter build apk --release > build_release_log.txt 2>&1
type build_release_log.txt
echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "writemon_sprite.apk"
    echo =============================================
    echo  BUILD SUCCESS - writemon_sprite.apk created
    echo =============================================
) else (
    echo =============================================
    echo  BUILD FAILED - check build_release_log.txt
    echo =============================================
)
echo.
pause
