import subprocess, os

LOG = r"C:\Users\91618\WriteMon\create_android_log.txt"
PROJECT = r"C:\Users\91618\WriteMon"
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"
JAVA_HOME = r"C:\Users\91618\Java\jdk17"
ANDROID_HOME = r"C:\Users\91618\Android\sdk"

env = {
    **os.environ,
    "JAVA_HOME": JAVA_HOME,
    "ANDROID_HOME": ANDROID_HOME,
    "ANDROID_SDK_ROOT": ANDROID_HOME,
    "PATH": os.environ.get("PATH", "") + ";" + os.path.join(JAVA_HOME, "bin"),
}

def log(msg):
    print(msg)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(msg + "\n")

with open(LOG, "w", encoding="utf-8") as f:
    f.write("")

log("=== Android 프로젝트 구조 생성 ===")

# flutter create --platforms android . 으로 android 폴더 생성
r = subprocess.run(
    [FLUTTER, "create", "--platforms", "android", "--project-name", "writemon", "."],
    capture_output=True, text=True, timeout=120, cwd=PROJECT, env=env
)

log("STDOUT:\n" + r.stdout)
if r.stderr:
    log("STDERR:\n" + r.stderr[:500])
log(f"returncode: {r.returncode}")

if r.returncode == 0:
    log("\nandroid 폴더 생성 완료!")
    # android/app/build.gradle의 minSdk 확인
    gradle_path = os.path.join(PROJECT, "android", "app", "build.gradle")
    if os.path.exists(gradle_path):
        log(f"build.gradle 존재: {gradle_path}")
    else:
        log("build.gradle 없음 - 다른 경로 확인 필요")
else:
    log("생성 실패!")
