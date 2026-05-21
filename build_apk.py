import subprocess, os

LOG = r"C:\Users\91618\WriteMon\build_apk_log.txt"
PROJECT = r"C:\Users\91618\WriteMon"
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"
JAVA_HOME = r"C:\Users\91618\Java\jdk17"
ANDROID_HOME = r"C:\Users\91618\Android\sdk"

env = {
    **os.environ,
    "JAVA_HOME": JAVA_HOME,
    "ANDROID_HOME": ANDROID_HOME,
    "ANDROID_SDK_ROOT": ANDROID_HOME,
    "PATH": os.environ.get("PATH", "") + ";" + os.path.join(JAVA_HOME, "bin") + ";" + os.path.join(ANDROID_HOME, "platform-tools"),
}

def log(msg):
    print(msg)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(msg + "\n")

with open(LOG, "w", encoding="utf-8") as f:
    f.write("")

log("=== flutter build apk 시작 ===")

# 라이선스 먼저 수락
log("Android 라이선스 수락 중...")
r0 = subprocess.run(
    [FLUTTER, "doctor", "--android-licenses"],
    input="y\n" * 20,
    capture_output=True, text=True, timeout=120, cwd=PROJECT, env=env
)
log(f"라이선스: {r0.stdout[-200:]}")

# APK 빌드
log("\nAPK 빌드 시작 (3~10분 소요)...")
r = subprocess.run(
    [FLUTTER, "build", "apk", "--release"],
    capture_output=True, text=True, timeout=600, cwd=PROJECT, env=env
)

with open(LOG, "a", encoding="utf-8") as f:
    f.write("STDOUT:\n" + r.stdout + "\n")
    f.write("STDERR:\n" + r.stderr[-2000:] + "\n")
    f.write(f"returncode: {r.returncode}\n")
    if r.returncode == 0:
        f.write("\n=== APK 빌드 성공! ===\n")
        f.write("위치: C:\\Users\\91618\\WriteMon\\build\\app\\outputs\\flutter-apk\\app-release.apk\n")
    else:
        f.write("\n=== APK 빌드 실패 ===\n")

print("Done!")
