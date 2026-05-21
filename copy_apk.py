import shutil, os

src = r"C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release.apk"
# BlueStacks가 확장자 없이 연결할 수도 있으니 두 경로 모두 시도
src2 = r"C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release"
dst = r"C:\Users\91618\WriteMon\writemon.apk"

if os.path.exists(src):
    shutil.copy2(src, dst)
    print(f"복사 완료: {dst} ({os.path.getsize(dst)//1024//1024}MB)")
elif os.path.exists(src2):
    shutil.copy2(src2, dst)
    print(f"복사 완료: {dst} ({os.path.getsize(dst)//1024//1024}MB)")
else:
    print("APK 파일을 찾을 수 없습니다")
