"""
Android SDK Command-line Tools 설치 스크립트
- Android Studio 없이 APK 빌드 가능하게 설정
"""
import urllib.request, zipfile, os, subprocess, winreg

LOG = r"C:\Users\91618\WriteMon\android_sdk_log.txt"
ANDROID_HOME = r"C:\Users\91618\Android\sdk"
CMDLINE_TOOLS_DIR = os.path.join(ANDROID_HOME, "cmdline-tools", "latest")
ZIP_PATH = r"C:\Users\91618\WriteMon\cmdline-tools.zip"

# cmdline-tools 최신 버전 URL (Windows)
DOWNLOAD_URL = "https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip"

def log(msg):
    print(msg)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(msg + "\n")

with open(LOG, "w", encoding="utf-8") as f:
    f.write("")

log("=== Android SDK 설치 시작 ===")

# 1. 다운로드
log(f"cmdline-tools 다운로드 중... (~150MB)")
def progress(block, block_size, total):
    if total > 0:
        pct = block * block_size * 100 // total
        mb = block * block_size // (1024*1024)
        total_mb = total // (1024*1024)
        if pct % 20 == 0:
            log(f"  {mb}MB / {total_mb}MB ({pct}%)")

try:
    urllib.request.urlretrieve(DOWNLOAD_URL, ZIP_PATH, reporthook=progress)
    log("다운로드 완료!")
except Exception as e:
    log(f"다운로드 실패: {e}")
    import sys; sys.exit(1)

# 2. 압축 해제
log(f"압축 해제 중...")
os.makedirs(os.path.join(ANDROID_HOME, "cmdline-tools"), exist_ok=True)

with zipfile.ZipFile(ZIP_PATH, 'r') as z:
    z.extractall(os.path.join(ANDROID_HOME, "cmdline-tools"))

# ZIP 안에 'cmdline-tools' 폴더가 있으므로 'latest'로 이름 변경
extracted = os.path.join(ANDROID_HOME, "cmdline-tools", "cmdline-tools")
if os.path.exists(extracted) and not os.path.exists(CMDLINE_TOOLS_DIR):
    os.rename(extracted, CMDLINE_TOOLS_DIR)

log("압축 해제 완료!")

# 3. SDK Manager로 필요 패키지 설치
SDKMANAGER = os.path.join(CMDLINE_TOOLS_DIR, "bin", "sdkmanager.bat")
log(f"\nSDK 패키지 설치 중...")

PACKAGES = [
    "platform-tools",
    "build-tools;35.0.0",
    "platforms;android-35",
]

for pkg in PACKAGES:
    log(f"  설치: {pkg}")
    r = subprocess.run(
        [SDKMANAGER, "--sdk_root=" + ANDROID_HOME, pkg],
        input="y\n" * 10,
        capture_output=True, text=True, timeout=300
    )
    log(f"  결과: {'OK' if r.returncode == 0 else 'FAIL'}")
    if r.returncode != 0:
        log(f"  오류: {r.stderr[:500]}")

# 4. 라이선스 수락
log("\nAndroid 라이선스 수락 중...")
r = subprocess.run(
    [SDKMANAGER, "--sdk_root=" + ANDROID_HOME, "--licenses"],
    input="y\n" * 20,
    capture_output=True, text=True, timeout=60
)
log(f"라이선스: {'수락 완료' if r.returncode == 0 else '일부 실패 (정상)'}")

# 5. 환경변수 등록
log("\n환경변수 설정 중...")
try:
    key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, "Environment", 0, winreg.KEY_ALL_ACCESS)

    # ANDROID_HOME
    winreg.SetValueEx(key, "ANDROID_HOME", 0, winreg.REG_SZ, ANDROID_HOME)
    winreg.SetValueEx(key, "ANDROID_SDK_ROOT", 0, winreg.REG_SZ, ANDROID_HOME)

    # PATH에 platform-tools 추가
    try:
        current_path, _ = winreg.QueryValueEx(key, "PATH")
    except FileNotFoundError:
        current_path = ""

    platform_tools = os.path.join(ANDROID_HOME, "platform-tools")
    if platform_tools.lower() not in current_path.lower():
        new_path = current_path + ";" + platform_tools if current_path else platform_tools
        winreg.SetValueEx(key, "PATH", 0, winreg.REG_EXPAND_SZ, new_path)

    winreg.CloseKey(key)
    log(f"ANDROID_HOME = {ANDROID_HOME}")
    log("PATH에 platform-tools 추가 완료")
except Exception as e:
    log(f"환경변수 설정 실패: {e}")

# 6. flutter doctor --android-licenses
FLUTTER = r"C:\Users\91618\flutter\bin\flutter.bat"
log("\nFlutter Android 라이선스 수락...")
r = subprocess.run(
    [FLUTTER, "doctor", "--android-licenses"],
    input="y\n" * 20,
    capture_output=True, text=True, timeout=60,
    env={**os.environ, "ANDROID_HOME": ANDROID_HOME, "ANDROID_SDK_ROOT": ANDROID_HOME}
)
log(r.stdout[:1000])

# ZIP 삭제
try:
    os.remove(ZIP_PATH)
    log("\n임시 ZIP 삭제 완료")
except:
    pass

log("\n=== 설치 완료! ===")
log(f"Android SDK: {ANDROID_HOME}")
log("이제 'flutter build apk' 실행 가능합니다!")
