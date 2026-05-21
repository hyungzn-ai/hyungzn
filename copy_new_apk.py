import shutil, os

src = r"C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release.apk"
dst = r"C:\Users\91618\WriteMon\writemon_new.apk"

if os.path.exists(src):
    shutil.copy2(src, dst)
    size = os.path.getsize(dst) // 1024 // 1024
    print(f"복사 완료: writemon_new.apk ({size}MB)")
else:
    print(f"파일 없음: {src}")
