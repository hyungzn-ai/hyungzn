import subprocess, os, sys

LOG = r"C:\Users\91618\WriteMon\pubget_log.txt"
PROJECT = r"C:\Users\91618\WriteMon"
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"

with open(LOG, "w", encoding="utf-8") as f:
    f.write("=== 시작 ===\n")
    f.write(f"Python: {sys.version}\n")
    f.write(f"flutter exists: {os.path.exists(FLUTTER)}\n")
    f.write(f"project exists: {os.path.exists(PROJECT)}\n")

# flutter --version 먼저 테스트
r1 = subprocess.run([FLUTTER, "--version"], capture_output=True, text=True, timeout=30)
with open(LOG, "a", encoding="utf-8") as f:
    f.write(f"\n--- flutter --version ---\n{r1.stdout}\n{r1.stderr}\n")

# pub get
r2 = subprocess.run([FLUTTER, "pub", "get"], cwd=PROJECT, capture_output=True, text=True, timeout=300)
with open(LOG, "a", encoding="utf-8") as f:
    f.write(f"\n--- flutter pub get ---\nSTDOUT:\n{r2.stdout}\nSTDERR:\n{r2.stderr}\nreturncode: {r2.returncode}\n")
    f.write("=== 완료! ===\n" if r2.returncode == 0 else "=== 실패 ===\n")
