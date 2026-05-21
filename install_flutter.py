"""
Flutter SDK 다운로드 및 설치 스크립트
"""
import urllib.request, json, zipfile, os, sys, shutil

LOG = r"C:\Users\91618\WriteMon\flutter_install_log.txt"
INSTALL_DIR = r"C:\Users\91618\flutter"
ZIP_PATH = r"C:\Users\91618\WriteMon\flutter_sdk.zip"

def log(msg):
    print(msg)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(msg + "\n")

log("=== Flutter 설치 시작 ===")

# 1. 최신 stable 버전 URL 가져오기
log("최신 버전 정보 조회 중...")
try:
    releases_url = "https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json"
    with urllib.request.urlopen(releases_url, timeout=30) as resp:
        data = json.loads(resp.read())

    # stable 채널 최신 해시 찾기
    stable_hash = data["current_release"]["stable"]
    releases = {r["hash"]: r for r in data["releases"]}
    latest = releases[stable_hash]

    archive_url = "https://storage.googleapis.com/flutter_infra_release/releases/" + latest["archive"]
    version = latest["version"]
    log(f"최신 버전: {version}")
    log(f"다운로드 URL: {archive_url}")
except Exception as e:
    log(f"버전 조회 실패, 고정 URL 사용: {e}")
    archive_url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.2-stable.zip"
    log(f"URL: {archive_url}")

# 2. 다운로드
log(f"다운로드 시작... (300~500MB, 시간이 걸립니다)")

def progress(block, block_size, total):
    if total > 0:
        pct = block * block_size * 100 // total
        if pct % 10 == 0:
            mb = block * block_size // (1024*1024)
            total_mb = total // (1024*1024)
            log(f"  진행: {mb}MB / {total_mb}MB ({pct}%)")

try:
    urllib.request.urlretrieve(archive_url, ZIP_PATH, reporthook=progress)
    log("다운로드 완료!")
except Exception as e:
    log(f"다운로드 실패: {e}")
    sys.exit(1)

# 3. 압축 해제
log(f"압축 해제 중... -> {INSTALL_DIR}")
if os.path.exists(INSTALL_DIR):
    log("기존 폴더 삭제 중...")
    shutil.rmtree(INSTALL_DIR)

parent = os.path.dirname(INSTALL_DIR)
try:
    with zipfile.ZipFile(ZIP_PATH, 'r') as z:
        z.extractall(parent)
    # ZIP 안에 'flutter' 폴더로 풀림
    extracted = os.path.join(parent, "flutter")
    if extracted != INSTALL_DIR:
        os.rename(extracted, INSTALL_DIR)
    log("압축 해제 완료!")
except Exception as e:
    log(f"압축 해제 실패: {e}")
    sys.exit(1)

# 4. PATH 등록 (현재 사용자 환경변수)
log("PATH 등록 중...")
import winreg
flutter_bin = os.path.join(INSTALL_DIR, "bin")
try:
    key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, "Environment", 0, winreg.KEY_ALL_ACCESS)
    try:
        current_path, _ = winreg.QueryValueEx(key, "PATH")
    except FileNotFoundError:
        current_path = ""

    if flutter_bin.lower() not in current_path.lower():
        new_path = current_path + ";" + flutter_bin if current_path else flutter_bin
        winreg.SetValueEx(key, "PATH", 0, winreg.REG_EXPAND_SZ, new_path)
        log(f"PATH 등록 완료: {flutter_bin}")
    else:
        log("이미 PATH에 등록되어 있음")
    winreg.CloseKey(key)
except Exception as e:
    log(f"PATH 등록 실패 (수동으로 추가 필요): {e}")
    log(f"수동 추가: {flutter_bin}")

# 5. ZIP 파일 삭제
try:
    os.remove(ZIP_PATH)
    log("임시 ZIP 파일 삭제 완료")
except:
    pass

log(f"\n=== 설치 완료! ===")
log(f"Flutter 위치: {INSTALL_DIR}")
log(f"새 터미널에서 'flutter --version' 실행해보세요")
