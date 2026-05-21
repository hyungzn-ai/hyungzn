import subprocess, os, datetime

LOG = r"C:\Users\91618\WriteMon\analyze3_log.txt"
PROJECT = r"C:\Users\91618\WriteMon"
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"

with open(LOG, "w", encoding="utf-8") as f:
    f.write(f"=== flutter analyze at {datetime.datetime.now()} ===\n")

r = subprocess.run(
    [FLUTTER, "analyze"],
    capture_output=True, text=True, timeout=120, cwd=PROJECT
)

with open(LOG, "a", encoding="utf-8") as f:
    f.write(r.stdout)
    if r.stderr:
        f.write("\nSTDERR:\n" + r.stderr[:3000])
    f.write(f"\nreturncode: {r.returncode}\n")
    if r.returncode == 0:
        f.write("✅ No errors!\n")

print("Done!")
