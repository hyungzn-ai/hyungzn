import shutil, os

src = r"C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release.apk"
dst = r"C:\Users\91618\WriteMon\writemon_dev.apk"

if os.path.exists(src):
    shutil.copy2(src, dst)
    size = os.path.getsize(dst) // 1024 // 1024
    print(f"복사 완료: writemon_dev.apk ({size}MB)")
else:
    print(f"파일 없음: {src}")
    # 확장자 없는 경우도 확인
    src2 = r"C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release"
    if os.path.exists(src2):
        shutil.copy2(src2, dst)
        size = os.path.getsize(dst) // 1024 // 1024
        print(f"복사 완료 (no ext): writemon_dev.apk ({size}MB)")
    else:
        print("APK 파일 없음")
