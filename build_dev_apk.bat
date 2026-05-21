@echo off
cd /d C:\Users\91618\WriteMon
set PATH=C:\Users\91618\flutter\bin;%PATH%
flutter build apk --release
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "writemon_dev.apk"
    echo SUCCESS: writemon_dev.apk created
) else (
    echo FAILED: APK not found
)
pause
