import subprocess, os

LOG = r"C:\Users\91618\WriteMon\analyze2_log.txt"
PROJECT = r"C:\Users\91618\WriteMon"
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"

with open(LOG, "w", encoding="utf-8") as f:
    f.write("=== flutter analyze ===\n")

r = subprocess.run(
    [FLUTTER, "analyze"],
    capture_output=True, text=True, timeout=120, cwd=PROJECT
)

with open(LOG, "a", encoding="utf-8") as f:
    f.write(r.stdout)
    if r.stderr:
        f.write("\nSTDERR:\n" + r.stderr[:3000])
    f.write(f"\nreturncode: {r.returncode}\n")

print("Done! 로그: analyze2_log.txt")
