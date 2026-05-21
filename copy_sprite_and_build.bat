@echo off
cd /d C:\Users\91618\WriteMon

echo [1/3] 스프라이트 이미지 복사 중...

:: 새 이미지를 assets 폴더로 복사
copy /Y "%APPDATA%\Claude\local-agent-mode-sessions\3d7d6dbd-f02a-4e40-ae0b-77818710ded7\0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\agent\local_ditto_0ac4ea5d-3bc8-4386-bf72-dcf268e040fc\uploads\3dba61c0-Gemini_Generated_Image_h54lp8h54lp8h54l.png" "assets\images\monsters_sprite.png"

if not exist "assets\images\monsters_sprite.png" (
    echo [오류] 이미지 복사 실패! 수동으로 복사하세요.
    pause
    exit /b 1
)
echo 이미지 복사 완료!

echo [2/3] 이미지 크기 확인...
python -c "
import struct
with open(r'assets\images\monsters_sprite.png','rb') as f:
    f.read(8); f.read(4); f.read(4)
    w=struct.unpack('>I',f.read(4))[0]
    h=struct.unpack('>I',f.read(4))[0]
print(f'  이미지 크기: {w} x {h}px')
print(f'  → sprite_coordinates.dart 의 imageWidth={w}, imageHeight={h} 로 맞추세요')
"

echo.
echo [3/3] APK 빌드 중...
set PATH=C:\Users\91618\flutter\bin;%PATH%
flutter build apk --release
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "writemon_sprite.apk"
    echo.
    echo ===== 빌드 성공! writemon_sprite.apk =====
) else (
    echo ===== 빌드 실패 =====
)
pause
