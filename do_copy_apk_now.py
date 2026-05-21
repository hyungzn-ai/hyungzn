import shutil, os

src = r"C:\Users\91618\WriteMon\build\app\outputs\flutter-apk\app-release.apk"
dst = r"C:\Users\91618\WriteMon\writemon_new_sprites.apk"

if os.path.exists(src):
    shutil.copy2(src, dst)
    size = os.path.getsize(dst) / 1024 / 1024
    print(f"SUCCESS: Copied {size:.1f}MB to {dst}")
else:
    print(f"ERROR: Source not found: {src}")
