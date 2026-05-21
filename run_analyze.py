import subprocess

LOG = r"C:\Users\91618\WriteMon\analyze_log.txt"
PROJECT = r"C:\Users\91618\WriteMon"
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"

r = subprocess.run([FLUTTER, "analyze"], cwd=PROJECT, capture_output=True, text=True, timeout=120)
with open(LOG, "w", encoding="utf-8") as f:
    f.write("=== flutter analyze ===\n")
    f.write("STDOUT:\n" + r.stdout + "\n")
    f.write("STDERR:\n" + r.stderr + "\n")
    f.write(f"returncode: {r.returncode}\n")
print("Done")
