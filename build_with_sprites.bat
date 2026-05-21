@echo off
echo === WriteMon: 스프라이트 추출 + APK 빌드 ===
C:
cd "C:\Users\91618\WriteMon"
echo 작업 디렉토리: %CD%

echo.
echo [1/3] Pillow / numpy 설치 확인...
py -3 -m pip install pillow numpy --quiet
if %errorlevel% neq 0 (
    echo pip 실패, python으로 재시도...
    python -m pip install pillow numpy --quiet
)

echo.
echo [2/3] 스프라이트 추출 중...
py -3 extract_sprites_new.py
if %errorlevel% neq 0 (
    echo.
    echo *** 스프라이트 추출 실패! ***
    pause
    exit /b 1
)

echo.
echo [3/3] APK 빌드 중...
flutter build apk --release
set RESULT=%errorlevel%
if %RESULT% == 0 (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "writemon_new_sprites.apk"
    echo.
    echo *** 빌드 성공: writemon_new_sprites.apk 생성 완료! ***
) else (
    echo.
    echo *** APK 빌드 실패 (코드=%RESULT%) ***
)
pause
