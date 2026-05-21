import subprocess, os

LOG = r"C:\Users\91618\WriteMon\java_check.txt"
SDKMANAGER = r"C:\Users\91618\Android\sdk\cmdline-tools\latest\bin\sdkmanager.bat"
ANDROID_HOME = r"C:\Users\91618\Android\sdk"

lines = []

# java 버전 확인
r = subprocess.run(["java", "-version"], capture_output=True, text=True, timeout=10)
lines.append(f"java stdout: {r.stdout}")
lines.append(f"java stderr: {r.stderr}")
lines.append(f"java returncode: {r.returncode}")

# sdkmanager 직접 실행 (더 많은 에러 출력)
if os.path.exists(SDKMANAGER):
    env = {**os.environ, "ANDROID_HOME": ANDROID_HOME}
    r2 = subprocess.run(
        [SDKMANAGER, "--sdk_root=" + ANDROID_HOME, "--list"],
        capture_output=True, text=True, timeout=30, env=env
    )
    lines.append(f"\nsdkmanager --list stdout: {r2.stdout[:500]}")
    lines.append(f"sdkmanager --list stderr: {r2.stderr[:500]}")
    lines.append(f"sdkmanager returncode: {r2.returncode}")
else:
    lines.append(f"sdkmanager not found: {SDKMANAGER}")

with open(LOG, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print("Done")
