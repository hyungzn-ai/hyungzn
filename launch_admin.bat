@echo off
REM 이 스크립트는 PowerShell을 관리자 권한으로 실행합니다
REM UAC 창이 뜨면 "예" 를 클릭해주세요

powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command ""winget install --id Google.Flutter --accept-source-agreements --accept-package-agreements; Write-Host DONE -ForegroundColor Green; Read-Host Press Enter""' -Verb RunAs"
