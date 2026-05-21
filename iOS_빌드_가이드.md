# 영작몬 iOS 빌드 가이드 (Windows → 아이폰)

> 본인이 쓰려고 만드는 개인용 빌드 기준. App Store 출시 X.

## 전체 흐름

```
Windows에서 코드 작성
        ↓
[setup_ios.bat 1회 실행 → ios/ 폴더 생성]
        ↓
GitHub에 코드 푸시
        ↓
Codemagic이 macOS에서 자동으로 IPA 빌드
        ↓
IPA를 PC로 다운로드
        ↓
AltStore / Sideloadly로 아이폰에 설치 (무료 Apple ID 사용)
        ↓
7일마다 재서명 (AltStore가 WiFi로 자동 처리)
```

---

## 1단계. iOS 폴더 생성 (Windows에서 1회만)

PC에서 `WriteMon` 폴더로 가서 **`setup_ios.bat`** 를 더블클릭합니다.

내부적으로 실행되는 것:
- `flutter create --platforms=ios .` → `ios/` 폴더(Xcode 프로젝트) 자동 생성
- `customize_ios.py` → 앱 이름 "영작몬"으로 변경, 화면 세로 고정
- `flutter pub get` → 패키지 동기화

성공하면 `ios/Runner/Info.plist` 파일이 생기고, `CFBundleDisplayName`이 "영작몬"으로 설정됩니다.

### 막힐 때
- "flutter는 인식되지 않는 명령" → Flutter PATH가 등록 안 됨. `flutter doctor` 실행되는지 cmd에서 확인.
- "py는 인식되지 않는 명령" → Python 미설치. python.org에서 설치 후 재시도.

---

## 2단계. GitHub에 코드 올리기

Codemagic이 GitHub 저장소를 읽어서 빌드하기 때문에, 먼저 GitHub에 코드를 올려야 합니다.

### 2-1. GitHub 저장소 만들기
1. https://github.com/new 접속
2. Repository name: `writemon` (또는 원하는 이름)
3. **Private** 선택 (개인용이니까)
4. "Create repository" 클릭

### 2-2. 로컬에서 git 초기화 & 푸시
Windows cmd에서 `WriteMon` 폴더로 이동 후:

```bash
cd C:\Users\91618\WriteMon
git init
git add .
git commit -m "Initial: WriteMon iOS setup"
git branch -M main
git remote add origin https://github.com/<your-username>/writemon.git
git push -u origin main
```

> Git이 없다면 https://git-scm.com/download/win 에서 설치.
> GitHub 비번 대신 Personal Access Token이 필요할 수 있음 (Settings → Developer settings → PAT).

---

## 3단계. Codemagic 연결 & 빌드

### 3-1. 계정 생성
1. https://codemagic.io 접속
2. "Sign up with GitHub" 클릭 → GitHub 권한 허용

### 3-2. 프로젝트 연결
1. 좌측 "Applications" → "Add application"
2. GitHub 선택 → `writemon` 저장소 선택
3. "Flutter App" 선택

### 3-3. 빌드 실행
`codemagic.yaml`을 자동 인식합니다.
1. 워크플로 선택: `WriteMon iOS Unsigned Build (Personal Use)`
2. Branch: `main`
3. "Start new build" 클릭

빌드는 보통 **10~15분** 정도 걸립니다. 무료 한도는 월 500분.

### 3-4. IPA 다운로드
빌드 성공하면:
- 등록한 이메일로 결과 알림 도착
- Codemagic 빌드 페이지의 "Artifacts" 섹션에서 **`WriteMon-unsigned.ipa`** 다운로드

---

## 4단계. 아이폰에 설치 (AltStore 방식 추천)

무료 Apple ID로 자기 아이폰에 설치하는 가장 안정적인 방법.

### 4-1. AltStore 설치 (1회만)
1. https://altstore.io 접속 → Windows용 **AltServer** 다운로드 & 설치
2. 아이폰을 USB로 PC 연결
3. iTunes (Microsoft Store 버전 비추, Apple 사이트 다운로드 버전 권장) 설치 → "WiFi 동기화" 켜기
4. PC 트레이의 AltServer 아이콘 우클릭 → "Install AltStore" → 본인 아이폰 선택
5. Apple ID 입력 (앱별 비밀번호 권장: https://appleid.apple.com → 보안 → 앱 비밀번호)
6. 아이폰 [설정] → [일반] → [VPN 및 기기 관리] → 본인 Apple ID → "신뢰" 누름
7. 아이폰에 **AltStore** 앱 아이콘 생김

### 4-2. WriteMon 설치
1. 다운로드한 `WriteMon-unsigned.ipa`를 **iCloud Drive**나 PC 공유 폴더에 넣기
2. 아이폰 AltStore 앱 열기 → "My Apps" 탭 → "+" 버튼 → IPA 파일 선택
3. AltStore가 자동으로 본인 Apple ID로 서명 후 설치
4. 홈 화면에 "영작몬" 아이콘 등장!

### 4-3. 7일 재서명
무료 Apple ID로 사이드로드한 앱은 **7일 후 만료**됩니다.
- AltStore가 백그라운드에서 자동 갱신 (PC + 아이폰 같은 WiFi에 있을 때)
- 또는 수동: AltStore 앱 → "My Apps" → WriteMon 새로고침 버튼

---

## 대안: Sideloadly (AltStore 안 되면)

AltStore 설정이 까다로우면 https://sideloadly.io 가 더 간단합니다.
- PC에 Sideloadly 설치
- 아이폰 USB 연결
- IPA 드래그 → Apple ID 입력 → Install
- 7일 후 다시 같은 작업 (자동 갱신 없음)

---

## 자주 막히는 부분

| 증상 | 해결 |
|---|---|
| Codemagic 빌드 실패: "no provisioning profiles" | `codemagic.yaml`의 `--no-codesign` 플래그가 있는지 확인 |
| Codemagic 빌드 실패: "pod install" 오류 | macOS 인스턴스 재시작 후 재빌드, 또는 Podfile.lock 삭제 후 푸시 |
| AltStore 설치 시 "Could not find Mail plug-in" | iCloud (Apple 공식) 클라이언트 설치 필요 |
| 앱 실행 시 "신뢰되지 않은 개발자" | [설정] → [일반] → [VPN 및 기기 관리]에서 본인 ID 신뢰 |
| 7일 후 앱 안 열림 | AltStore에서 새로고침 (PC와 같은 WiFi 필요) |

---

## 다음에 코드 수정하면?

```bash
git add .
git commit -m "fix: 어떤 변경"
git push
```

푸시만 하면 Codemagic이 자동으로 새 IPA를 빌드합니다.

---

## 한계 인정

- **7일 재설치**가 귀찮으면 Apple Developer 유료 등록($99/년)으로 1년 유지 가능
- **Push 알림, In-App Purchase** 등 일부 기능은 유료 등록 필요
- **Mac 없이는 Xcode로 직접 디버깅 불가** → 로그는 Codemagic 빌드 로그로만 확인
