@echo off
echo === 스프라이트 추출 및 APK 빌드 ===
C:
cd "C:\Users\91618\WriteMon"
echo [1/3] Installing dependencies...
py -3 -m pip install Pillow numpy --quiet
echo [2/3] Extracting sprites...
py -3 extract_sprites_new.py
if %errorlevel% neq 0 (
    echo ERROR: Sprite extraction failed!
    pause
    exit /b 1
)
echo [3/3] Building APK...
flutter build apk --release
if %errorlevel% == 0 (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "writemon_new_sprites.apk"
    echo.
    echo *** SUCCESS: writemon_new_sprites.apk ***
) else (
    echo *** BUILD FAILED ***
)
pause
