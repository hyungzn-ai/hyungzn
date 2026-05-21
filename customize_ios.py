# -*- coding: utf-8 -*-
"""
flutter create --platforms=ios 실행 후, ios/Runner/Info.plist를 영작몬용으로 커스터마이징.
- CFBundleDisplayName: "영작몬" (홈 화면에 표시되는 이름)
- 지원 방향: 세로만 (회전 잠금)
- iOS 13 이상
"""
import os
import re
import sys

PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))
INFO_PLIST = os.path.join(PROJECT_DIR, "ios", "Runner", "Info.plist")

if not os.path.exists(INFO_PLIST):
    print(f"[ERROR] Info.plist를 찾을 수 없습니다: {INFO_PLIST}")
    print("       먼저 'flutter create --platforms=ios .'를 실행했는지 확인하세요.")
    sys.exit(1)

with open(INFO_PLIST, "r", encoding="utf-8") as f:
    content = f.read()

original = content

# 1) 앱 표시 이름 (홈 화면 아이콘 아래 텍스트)
if "<key>CFBundleDisplayName</key>" in content:
    content = re.sub(
        r"(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)",
        r"\1영작몬\2",
        content,
    )
else:
    # CFBundleName 뒤에 CFBundleDisplayName 추가
    content = re.sub(
        r"(<key>CFBundleName</key>\s*<string>[^<]*</string>)",
        r"\1\n\t<key>CFBundleDisplayName</key>\n\t<string>영작몬</string>",
        content,
        count=1,
    )

# 2) 화면 회전: 세로만 (아이폰 전용)
content = re.sub(
    r"(<key>UISupportedInterfaceOrientations</key>\s*<array>)([\s\S]*?)(</array>)",
    "\\1\n\t\t<string>UIInterfaceOrientationPortrait</string>\n\t\\3",
    content,
    count=1,
)

# 3) 아이패드용 회전 (있다면 동일하게 세로만)
content = re.sub(
    r"(<key>UISupportedInterfaceOrientations~ipad</key>\s*<array>)([\s\S]*?)(</array>)",
    "\\1\n\t\t<string>UIInterfaceOrientationPortrait</string>\n\t\t<string>UIInterfaceOrientationPortraitUpsideDown</string>\n\t\\3",
    content,
    count=1,
)

with open(INFO_PLIST, "w", encoding="utf-8") as f:
    f.write(content)

print(f"[OK] Info.plist 수정 완료: {INFO_PLIST}")
print(f"     - CFBundleDisplayName = 영작몬")
print(f"     - 회전: 세로 고정")

# 4) Podfile의 iOS deployment target을 13.0으로 (Flutter 권장)
PODFILE = os.path.join(PROJECT_DIR, "ios", "Podfile")
if os.path.exists(PODFILE):
    with open(PODFILE, "r", encoding="utf-8") as f:
        podfile = f.read()
    new_podfile = re.sub(
        r"#?\s*platform :ios,\s*'[\d\.]+'",
        "platform :ios, '13.0'",
        podfile,
    )
    if new_podfile != podfile:
        with open(PODFILE, "w", encoding="utf-8") as f:
            f.write(new_podfile)
        print(f"[OK] Podfile 수정 완료: iOS 13.0 deployment target")
    else:
        print(f"[INFO] Podfile은 이미 적절히 설정되어 있습니다.")
else:
    print(f"[WARN] Podfile이 아직 생성되지 않았습니다 (Codemagic에서 pod install 시 자동 생성).")

print("")
print("=== 완료 ===")
