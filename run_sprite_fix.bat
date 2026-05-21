@echo off
chcp 65001 > nul
cd /d C:\Users\91618\WriteMon
echo =============================================
echo  스프라이트 시트 분석 및 추출
echo =============================================
pip install Pillow --quiet 2>nul
python sprite_fix.py
echo.
echo 완료! sprite_preview.png 를 열어서 확인하세요.
pause
