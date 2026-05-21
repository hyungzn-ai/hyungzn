@echo off
chcp 65001 > nul
echo === 몬스터 스프라이트 분할 ===
echo.

where py >nul 2>&1 && (
    echo [py launcher 발견]
    py -m pip install Pillow --user -q
    py "%~dp0split_monsters.py"
) || (
    where python >nul 2>&1 && (
        echo [python 발견]
        python -m pip install Pillow --user -q
        python "%~dp0split_monsters.py"
    ) || (
        echo Python을 찾지 못했습니다.
        echo C:\Users\91618\AppData\Local\Programs\Python\Python313\python.exe 시도...
        "C:\Users\91618\AppData\Local\Programs\Python\Python313\python.exe" -m pip install Pillow --user -q
        "C:\Users\91618\AppData\Local\Programs\Python\Python313\python.exe" "%~dp0split_monsters.py"
    )
)

echo.
pause
