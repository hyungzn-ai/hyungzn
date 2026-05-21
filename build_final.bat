@echo off
cd /d C:\Users\91618\WriteMon
set PATH=C:\Users\91618\flutter\bin;%PATH%
flutter build apk --release
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "writemon_new_20260502.apk"
    echo SUCCESS
) else (
    echo FAILED
)
pause
