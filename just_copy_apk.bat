@echo off
cd /d C:\Users\91618\WriteMon
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "writemon_sprite.apk"
echo Done. Size:
dir writemon_sprite.apk
pause
