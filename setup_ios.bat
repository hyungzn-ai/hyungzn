@echo off
chcp 65001 > nul
cd /d "C:\Users\91618\WriteMon"
echo === WriteMon iOS 환경 설정 ===
echo 작업 디렉토리: %CD%
echo.

echo [1/3] Flutter iOS 플랫폼 추가 (ios/ 폴더 생성)
call flutter create --platforms=ios .
if %errorlevel% neq 0 (
    echo *** flutter create 실패 ***
    pause
    exit /b 1
)

echo.
echo [2/3] Info.plist 커스터마이징 (앱 이름: 영작몬)
py -3 customize_ios.py
if %errorlevel% neq 0 (
    echo *** customize_ios.py 실패 ***
    pause
    exit /b 1
)

echo.
echo [3/3] flutter pub get
call flutter pub get
if %errorlevel% neq 0 (
    echo *** pub get 실패 ***
    pause
    exit /b 1
)

echo.
echo ========================================
echo  iOS 환경 설정 완료!
echo ========================================
echo 다음 단계: iOS_빌드_가이드.md 참고
pause
