import subprocess

LOG = r"C:\Users\91618\WriteMon\doctor_log.txt"
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"

r = subprocess.run([FLUTTER, "doctor", "-v"], capture_output=True, text=True, timeout=120)
with open(LOG, "w", encoding="utf-8") as f:
    f.write(r.stdout + "\n" + r.stderr)
print("Done")
