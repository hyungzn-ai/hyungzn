import zipfile, os

PROJECT = r"C:\Users\91618\WriteMon"
OUTPUT = r"C:\Users\91618\WriteMon\writemon_source.zip"

# 제외할 폴더/파일
EXCLUDE_DIRS = {
    'build', '.dart_tool', '.idea', '.gradle', '.git',
    '__pycache__', 'node_modules', '.pub-cache',
}
EXCLUDE_EXTS = {'.pyc', '.lock'}
EXCLUDE_FILES = {
    'writemon_source.zip', 'analyze_log.txt', 'analyze2_log.txt',
    'analyze3_log.txt', 'build_apk_log.txt', 'create_android_log.txt',
    'pubget_log.txt', 'doctor_log.txt', 'android_sdk_log.txt',
    'java_android_log.txt', 'flutter_install_log.txt', 'split_log.txt',
    'flutter.log', 'flutter_log.txt',
}

count = 0
with zipfile.ZipFile(OUTPUT, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(PROJECT):
        # 제외 폴더 필터
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS and not d.startswith('.')]

        for file in files:
            # 제외 파일 필터
            if file in EXCLUDE_FILES:
                continue
            if any(file.endswith(ext) for ext in EXCLUDE_EXTS):
                continue
            # 카카오톡 이미지 등 큰 파일 제외
            filepath = os.path.join(root, file)
            try:
                size = os.path.getsize(filepath)
                if size > 30 * 1024 * 1024:  # 30MB 초과 제외
                    print(f"SKIP (too large): {filepath}")
                    continue
            except:
                continue

            arcname = os.path.relpath(filepath, PROJECT)
            try:
                zf.write(filepath, arcname)
                count += 1
            except Exception as e:
                print(f"ERROR: {filepath}: {e}")

size_mb = os.path.getsize(OUTPUT) / 1024 / 1024
print(f"\n완료! {count}개 파일, {size_mb:.1f}MB")
print(f"저장: {OUTPUT}")
