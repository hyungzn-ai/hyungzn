"""
Java JDK 17 + Android SDK 설치 스크립트 (무설치 zip 방식)
"""
import urllib.request, zipfile, os, subprocess, winreg, glob, sys

LOG = r"C:\Users\91618\WriteMon\java_android_log.txt"
JAVA_HOME = r"C:\Users\91618\Java\jdk17"
ANDROID_HOME = r"C:\Users\91618\Android\sdk"
CMDLINE_TOOLS_DIR = os.path.join(ANDROID_HOME, "cmdline-tools", "latest")
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"

JAVA_URL = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%2B11/OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.zip"
JAVA_ZIP = r"C:\Users\91618\WriteMon\jdk17.zip"

def log(msg):
    print(msg)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(msg + "\n")

with open(LOG, "w", encoding="utf-8") as f:
    f.write("")

log("=== Java JDK 17 + Android SDK 설치 ===")

# ── 1. Java 이미 있는지 확인 ──────────────────────────
java_exe = os.path.join(JAVA_HOME, "bin", "java.exe")
if os.path.exists(java_exe):
    log(f"Java 이미 있음: {java_exe}")
else:
    # Flutter 내장 JDK 확인
    flutter_java = glob.glob(r"C:\Users\91618\flutter\bin\cache\artifacts\engine\windows-x64\*\bin\java.exe")
    if not flutter_java:
        flutter_java = glob.glob(r"C:\Users\91618\flutter\bin\cache\artifacts\**\java.exe", recursive=True)

    if flutter_java:
        java_exe = flutter_java[0]
        JAVA_HOME = os.path.dirname(os.path.dirname(java_exe))
        log(f"Flutter 내장 Java 발견: {java_exe}")
    else:
        # Java JDK 다운로드
        log(f"Java JDK 17 다운로드 중... (~180MB)")

        def progress(block, block_size, total):
            if total > 0:
                pct = block * block_size * 100 // total
                mb = block * block_size // (1024*1024)
                if pct % 20 == 0:
                    log(f"  {mb}MB / {total // (1024*1024)}MB ({pct}%)")

        try:
            urllib.request.urlretrieve(JAVA_URL, JAVA_ZIP, reporthook=progress)
            log("Java 다운로드 완료!")
        except Exception as e:
            log(f"Java 다운로드 실패: {e}")
            sys.exit(1)

        # 압축 해제
        log("Java 압축 해제 중...")
        os.makedirs(os.path.dirname(JAVA_HOME), exist_ok=True)
        with zipfile.ZipFile(JAVA_ZIP, 'r') as z:
            z.extractall(os.path.dirname(JAVA_HOME))
        # 폴더 이름 맞추기 (jdk-17.0.13+11 → jdk17)
        for d in os.listdir(os.path.dirname(JAVA_HOME)):
            full = os.path.join(os.path.dirname(JAVA_HOME), d)
            if os.path.isdir(full) and d.startswith("jdk-") and full != JAVA_HOME:
                os.rename(full, JAVA_HOME)
                break
        try:
            os.remove(JAVA_ZIP)
        except:
            pass
        log(f"Java 설치 완료: {JAVA_HOME}")

# ── 2. sdkmanager 패키지 설치 ────────────────────────
SDKMANAGER = os.path.join(CMDLINE_TOOLS_DIR, "bin", "sdkmanager.bat")
if not os.path.exists(SDKMANAGER):
    log(f"sdkmanager 없음: {SDKMANAGER}")
    sys.exit(1)

log(f"\nJAVA_HOME = {JAVA_HOME}")
log("SDK 패키지 설치 중...")

env = {
    **os.environ,
    "JAVA_HOME": JAVA_HOME,
    "ANDROID_HOME": ANDROID_HOME,
    "ANDROID_SDK_ROOT": ANDROID_HOME,
    "PATH": os.environ.get("PATH", "") + ";" + os.path.join(JAVA_HOME, "bin"),
}

PACKAGES = ["platform-tools", "build-tools;35.0.0", "platforms;android-35"]
for pkg in PACKAGES:
    log(f"  설치: {pkg}")
    r = subprocess.run(
        [SDKMANAGER, "--sdk_root=" + ANDROID_HOME, pkg],
        input="y\n" * 10,
        capture_output=True, text=True, timeout=300, env=env
    )
    if r.returncode == 0:
        log(f"  ✓ 성공")
    else:
        log(f"  ✗ 실패: {r.stderr[:300]}")

# ── 3. 라이선스 수락 ─────────────────────────────────
log("\nAndroid 라이선스 수락...")
r = subprocess.run(
    [SDKMANAGER, "--sdk_root=" + ANDROID_HOME, "--licenses"],
    input="y\n" * 20,
    capture_output=True, text=True, timeout=60, env=env
)
log(f"라이선스: {'완료' if r.returncode == 0 else '일부 수락됨'}")

# ── 4. Flutter android-licenses ──────────────────────
log("\nFlutter android-licenses...")
r = subprocess.run(
    [FLUTTER, "doctor", "--android-licenses"],
    input="y\n" * 20,
    capture_output=True, text=True, timeout=60,
    env={**env, "JAVA_HOME": JAVA_HOME}
)
log(r.stdout[:500])
if r.stderr:
    log(f"stderr: {r.stderr[:300]}")

# ── 5. 환경변수 등록 ─────────────────────────────────
log("\n환경변수 등록...")
try:
    key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, "Environment", 0, winreg.KEY_ALL_ACCESS)
    winreg.SetValueEx(key, "JAVA_HOME", 0, winreg.REG_SZ, JAVA_HOME)
    winreg.SetValueEx(key, "ANDROID_HOME", 0, winreg.REG_SZ, ANDROID_HOME)
    winreg.SetValueEx(key, "ANDROID_SDK_ROOT", 0, winreg.REG_SZ, ANDROID_HOME)
    try:
        cur_path, _ = winreg.QueryValueEx(key, "PATH")
    except:
        cur_path = ""
    extras = [
        os.path.join(JAVA_HOME, "bin"),
        os.path.join(ANDROID_HOME, "platform-tools"),
    ]
    for e in extras:
        if e.lower() not in cur_path.lower():
            cur_path = cur_path + ";" + e
    winreg.SetValueEx(key, "PATH", 0, winreg.REG_EXPAND_SZ, cur_path)
    winreg.CloseKey(key)
    log("환경변수 등록 완료!")
except Exception as e:
    log(f"환경변수 등록 실패: {e}")

log("\n=== 설치 완료! ===")
log("다음 단계: flutter build apk")
