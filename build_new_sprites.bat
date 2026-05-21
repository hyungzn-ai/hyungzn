@echo off
echo === WriteMon APK Build ===
C:
cd "C:\Users\91618\WriteMon"
echo Working in: %CD%
echo Building APK...
flutter build apk --release
set RESULT=%errorlevel%
if %RESULT% == 0 (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "writemon_new_sprites.apk"
    echo.
    echo *** SUCCESS: writemon_new_sprites.apk created! ***
) else (
    echo.
    echo *** BUILD FAILED (code=%RESULT%) ***
)
pause
