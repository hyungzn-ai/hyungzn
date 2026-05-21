@echo off
chcp 65001 > nul
cd /d C:\Users\91618\WriteMon
set PATH=C:\Users\91618\flutter\bin;%PATH%
echo Building APK...
flutter build apk --release 2>&1
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "writemon_sprite.apk"
    echo BUILD SUCCESS
) else (
    echo BUILD FAILED
)
pause
