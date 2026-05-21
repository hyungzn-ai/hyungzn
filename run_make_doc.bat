@echo off
chcp 65001 > nul
cd /d C:\Users\91618\WriteMon
echo Installing docx package...
call npm install docx --save > nul 2>&1
echo Running doc generator...
node make_doc.js
echo Done.
pause
