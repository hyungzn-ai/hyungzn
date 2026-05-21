@echo off
chcp 65001 > nul
cd /d "C:\Users\91618\WriteMon"

( echo === git_init START %DATE% %TIME% ===
  echo CWD: %CD%
  echo --- git --version ---
  git --version
  echo --- git config user.name ---
  git config --global user.name
  echo --- git config user.email ---
  git config --global user.email
  echo --- 현재 폴더 git status ---
  git status
  echo === END %TIME% ===
) > C:\Users\91618\WriteMon\git_init.log 2>&1
