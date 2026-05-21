import shutil, os, sys

src = r'C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release.apk'
dst = r'C:\Users\91618\WriteMon\writemon_sprite.apk'

if os.path.exists(src):
    shutil.copy2(src, dst)
    size_mb = os.path.getsize(dst) / 1024 / 1024
    print(f'SUCCESS: writemon_sprite.apk ({size_mb:.1f} MB)')
else:
    print('ERROR: source APK not found')
    sys.exit(1)
