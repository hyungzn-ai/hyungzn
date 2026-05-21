@echo off
cd /d "C:\Users\91618\WriteMon"
echo Installing Pillow...
py -3 -m pip install Pillow --quiet
echo.
echo Extracting sprites...
py -3 extract_sprites_new.py
echo.
echo Done. Check output above.
pause
