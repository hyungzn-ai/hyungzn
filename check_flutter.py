import os, subprocess

log = []

# winget Flutter 설치 경로들 확인
paths = [
    r"C:\flutter",
    r"C:\src\flutter",
    r"C:\Users\91618\flutter",
    r"C:\Users\91618\AppData\Local\Programs\flutter",
    r"C:\Users\91618\AppData\Local\flutter",
    r"C:\Program Files\flutter",
    r"C:\Program Files (x86)\flutter",
]

for p in paths:
    exists = os.path.exists(p)
    log.append(f"{'EXISTS' if exists else 'NONE  '}: {p}")

# flutter 명령어 직접 실행
try:
    r = subprocess.run(["flutter", "--version"], capture_output=True, text=True, timeout=10)
    log.append(f"\nflutter command: {r.stdout.strip() or r.stderr.strip()}")
except FileNotFoundError:
    log.append("\nflutter: 명령어 없음 (PATH에 없음)")
except Exception as e:
    log.append(f"\nflutter error: {e}")

# winget list 확인
try:
    r = subprocess.run(["winget", "list", "Google.Flutter"], capture_output=True, text=True, timeout=15)
    log.append(f"\nwinget list: {r.stdout}")
except Exception as e:
    log.append(f"\nwinget error: {e}")

result = "\n".join(log)
print(result)
with open(r"C:\Users\91618\WriteMon\flutter_check.txt", "w", encoding="utf-8") as f:
    f.write(result)
