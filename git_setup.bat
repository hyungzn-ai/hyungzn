@echo off
cd /d "C:\Users\91618\WriteMon"
set LOG=C:\Users\91618\WriteMon\git_setup.log
echo === git_setup START === > %LOG%
echo CWD: %CD% >> %LOG%
if exist .git (
    echo .git ^|^| existing - removing... >> %LOG%
    rmdir /s /q .git
)
echo --- git init -b main --- >> %LOG%
git init -b main >> %LOG% 2>&1
echo EXIT_INIT=%errorlevel% >> %LOG%
echo --- git config --- >> %LOG%
git config user.name "kimhyeongjin" >> %LOG% 2>&1
git config user.email "91618or@gmail.com" >> %LOG% 2>&1
echo --- git add . --- >> %LOG%
git add . >> %LOG% 2>&1
echo EXIT_ADD=%errorlevel% >> %LOG%
echo --- staged file count --- >> %LOG%
git status --short | find /c /v "" >> %LOG% 2>&1
echo --- git commit --- >> %LOG%
git commit -m "Initial commit: WriteMon iOS setup" >> %LOG% 2>&1
echo EXIT_COMMIT=%errorlevel% >> %LOG%
echo --- git log --oneline --- >> %LOG%
git log --oneline >> %LOG% 2>&1
echo === END === >> %LOG%
