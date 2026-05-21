@echo off
cd /d C:\Users\91618\WriteMon

echo === VS Code Extension Flutter paths === > flutter_log.txt
if exist "%APPDATA%\Code\User\globalStorage\dart-code.flutter" echo FOUND dart-code.flutter storage >> flutter_log.txt
dir /b "%APPDATA%\Code\User\globalStorage\dart-code.flutter" >> flutter_log.txt 2>&1

echo. >> flutter_log.txt
echo === .flutter in home === >> flutter_log.txt
if exist "%USERPROFILE%\.flutter" echo FOUND %USERPROFILE%\.flutter >> flutter_log.txt
dir /b "%USERPROFILE%\.flutter" >> flutter_log.txt 2>&1

echo. >> flutter_log.txt
echo === dart-code extension storage === >> flutter_log.txt
dir /b "%APPDATA%\Code\User\globalStorage\" >> flutter_log.txt 2>&1

echo. >> flutter_log.txt
echo === List all C:\Users\91618 top folders === >> flutter_log.txt
dir /b /ad "C:\Users\91618\" >> flutter_log.txt 2>&1

echo. >> flutter_log.txt
echo === DONE === >> flutter_log.txt
