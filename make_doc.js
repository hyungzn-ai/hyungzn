const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  HeadingLevel, AlignmentType, BorderStyle, WidthType, ShadingType,
  LevelFormat, PageBreak, Header, Footer, PageNumber } = require('docx');
const fs = require('fs');

// ─── color palette ───────────────────────────────────────────
const C = {
  purple:   '6C63FF',
  darkBlue: '1C1C6A',
  slate:    '3A3A7A',
  accent:   'FF6B9D',
  gold:     'FFD166',
  teal:     '00D4A4',
  bg:       'F4F4FF',
  bg2:      'EAEAF8',
  white:    'FFFFFF',
  border:   'CCCCDD',
  text:     '1A1A3A',
};

const border = { style: BorderStyle.SINGLE, size: 1, color: C.border };
const borders = { top: border, bottom: border, left: border, right: border };
const noBorder = { style: BorderStyle.NONE, size: 0, color: 'FFFFFF' };
const noBorders = { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder };

// ─── helpers ─────────────────────────────────────────────────
function h1(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun(text)] });
}
function h2(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(text)] });
}
function h3(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun(text)] });
}
function body(text, opts = {}) {
  return new Paragraph({
    spacing: { before: 60, after: 60 },
    children: [new TextRun({ text, color: C.text, size: 22, ...opts })],
  });
}
function bodyRuns(...runs) {
  return new Paragraph({
    spacing: { before: 60, after: 60 },
    children: runs.map(r =>
      typeof r === 'string'
        ? new TextRun({ text: r, color: C.text, size: 22 })
        : new TextRun({ color: C.text, size: 22, ...r })
    ),
  });
}
function bullet(text, level = 0) {
  return new Paragraph({
    numbering: { reference: 'bullets', level },
    spacing: { before: 40, after: 40 },
    children: [new TextRun({ text, color: C.text, size: 22 })],
  });
}
function sp(n = 1) {
  return new Paragraph({ spacing: { before: n * 100, after: 0 }, children: [] });
}
function hr() {
  return new Paragraph({
    border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: C.purple } },
    spacing: { before: 80, after: 80 },
    children: [],
  });
}

// ─── colored section header ───────────────────────────────────
function sectionBanner(text, bgColor = C.purple) {
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [new TableRow({ children: [new TableCell({
      borders: noBorders,
      shading: { fill: bgColor, type: ShadingType.CLEAR },
      margins: { top: 120, bottom: 120, left: 200, right: 200 },
      width: { size: 9360, type: WidthType.DXA },
      children: [new Paragraph({
        children: [new TextRun({ text, bold: true, color: C.white, size: 26, font: 'Arial' })],
      })],
    })] })],
  });
}

// ─── two-column file table row ────────────────────────────────
function fileRow(filename, purpose, bgColor = C.white) {
  const c = { style: BorderStyle.SINGLE, size: 1, color: C.border };
  const b = { top: c, bottom: c, left: c, right: c };
  return new TableRow({ children: [
    new TableCell({
      borders: b, width: { size: 3200, type: WidthType.DXA },
      shading: { fill: bgColor, type: ShadingType.CLEAR },
      margins: { top: 80, bottom: 80, left: 120, right: 80 },
      children: [new Paragraph({ children: [
        new TextRun({ text: filename, font: 'Courier New', size: 18, color: C.slate, bold: true }),
      ]})],
    }),
    new TableCell({
      borders: b, width: { size: 6160, type: WidthType.DXA },
      shading: { fill: bgColor, type: ShadingType.CLEAR },
      margins: { top: 80, bottom: 80, left: 120, right: 80 },
      children: [new Paragraph({ children: [
        new TextRun({ text: purpose, size: 20, color: C.text }),
      ]})],
    }),
  ]});
}
function fileHeader(col1, col2) {
  const c = { style: BorderStyle.SINGLE, size: 2, color: C.purple };
  const b = { top: c, bottom: c, left: c, right: c };
  return new TableRow({ children: [
    new TableCell({
      borders: b, width: { size: 3200, type: WidthType.DXA },
      shading: { fill: C.purple, type: ShadingType.CLEAR },
      margins: { top: 80, bottom: 80, left: 120, right: 80 },
      children: [new Paragraph({ children: [
        new TextRun({ text: col1, bold: true, color: C.white, size: 20 }),
      ]})],
    }),
    new TableCell({
      borders: b, width: { size: 6160, type: WidthType.DXA },
      shading: { fill: C.purple, type: ShadingType.CLEAR },
      margins: { top: 80, bottom: 80, left: 120, right: 80 },
      children: [new Paragraph({ children: [
        new TextRun({ text: col2, bold: true, color: C.white, size: 20 }),
      ]})],
    }),
  ]});
}
function fileTable(rows) {
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [3200, 6160],
    rows,
  });
}

// ─────────────────────────────────────────────────────────────────
// DOCUMENT CONTENT
// ─────────────────────────────────────────────────────────────────
const doc = new Document({
  numbering: {
    config: [
      { reference: 'bullets', levels: [
        { level: 0, format: LevelFormat.BULLET, text: '▸', alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 520, hanging: 260 } } } },
        { level: 1, format: LevelFormat.BULLET, text: '–', alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 900, hanging: 260 } } } },
      ]},
    ],
  },
  styles: {
    default: { document: { run: { font: 'Arial', size: 22, color: C.text } } },
    paragraphStyles: [
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 40, bold: true, color: C.darkBlue, font: 'Arial' },
        paragraph: { spacing: { before: 360, after: 120 }, outlineLevel: 0,
          border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: C.purple } } } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 28, bold: true, color: C.purple, font: 'Arial' },
        paragraph: { spacing: { before: 280, after: 80 }, outlineLevel: 1 } },
      { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 24, bold: true, color: C.slate, font: 'Arial' },
        paragraph: { spacing: { before: 200, after: 60 }, outlineLevel: 2 } },
    ],
  },
  sections: [{
    properties: {
      page: {
        size: { width: 11906, height: 16838 }, // A4
        margin: { top: 1200, right: 1200, bottom: 1200, left: 1200 },
      },
    },
    headers: {
      default: new Header({ children: [
        new Paragraph({
          border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: C.purple } },
          children: [
            new TextRun({ text: '영작몬 (WriteMon) — 개발 문서', color: C.slate, size: 18, font: 'Arial' }),
          ],
        }),
      ]}),
    },
    footers: {
      default: new Footer({ children: [
        new Paragraph({
          alignment: AlignmentType.RIGHT,
          border: { top: { style: BorderStyle.SINGLE, size: 4, color: C.border } },
          children: [
            new TextRun({ text: '페이지 ', color: C.slate, size: 18 }),
            new TextRun({ children: [PageNumber.CURRENT], color: C.slate, size: 18 }),
          ],
        }),
      ]}),
    },
    children: [

      // ══════════════════════════════════════════════════════════════
      // COVER
      // ══════════════════════════════════════════════════════════════
      sp(2),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [new TextRun({ text: '영작몬', size: 72, bold: true, color: C.purple, font: 'Arial' })],
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 80, after: 80 },
        children: [new TextRun({ text: 'WriteMon — 영어 작문 학습 앱', size: 32, color: C.slate, font: 'Arial' })],
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 60, after: 60 },
        children: [new TextRun({ text: '개발 과정 & 파일 구조 문서', size: 24, color: C.slate, font: 'Arial' })],
      }),
      hr(),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 60, after: 0 },
        children: [new TextRun({ text: '2026년 5월  |  Flutter 3.x  |  Android APK', size: 20, color: C.slate, italics: true })],
      }),
      sp(2),
      new Paragraph({ children: [new PageBreak()] }),

      // ══════════════════════════════════════════════════════════════
      // 1. 프로젝트 개요
      // ══════════════════════════════════════════════════════════════
      h1('1. 프로젝트 개요'),
      body('영작몬(WriteMon)은 영어 작문 학습과 포켓몬 스타일의 몬스터 수집 게임을 결합한 모바일 앱입니다. 사용자가 영어 문장을 정확히 작성할수록 포인트를 얻고, 그 포인트로 몬스터를 진화시키거나 새 몬스터를 가챠(뽑기)로 획득할 수 있습니다.'),
      sp(),
      h2('핵심 아이디어'),
      bullet('영어 학습 → 보상(포인트) → 몬스터 성장의 선순환 구조'),
      bullet('학습이 게임처럼 느껴지도록 설계 (Gamification)'),
      bullet('25종 몬스터, 각 6단계 진화, 히든 몬스터 포함'),
      bullet('초급/중급/고급 3가지 레벨, 각 레벨별 Day 단위 학습'),
      sp(),
      h2('기술 스택'),
      bullet('프레임워크: Flutter 3.x (Dart) — 단일 코드베이스로 Android APK 생성'),
      bullet('상태관리: Provider (ChangeNotifier 패턴)'),
      bullet('데이터 저장: SharedPreferences (로컬 영속성)'),
      bullet('UI 테마: Material Design 3, Google Fonts (Noto Sans KR)'),
      bullet('애니메이션: flutter_animate, confetti 패키지'),
      bullet('이미지: 개별 PNG 파일 (몬스터 타입별 × 진화 6단계)'),
      sp(2),

      // ══════════════════════════════════════════════════════════════
      // 2. 파일 구조 (용도별)
      // ══════════════════════════════════════════════════════════════
      h1('2. 파일 구조 — 용도별 분류'),

      // ── 앱 진입점 ─────────────────────────────────────────────
      h2('2-1. 앱 진입점 & 설정'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('lib/main.dart', 'Flutter 앱 시작점. Provider 주입, 테마 적용, SplashScreen으로 라우팅.'),
        fileRow('pubspec.yaml', '패키지 의존성 선언 및 assets 등록 (이미지, 데이터 폴더).', C.bg),
        fileRow('android/', 'Android 네이티브 설정 (Gradle, AndroidManifest.xml, 키스토어 등).'),
      ]),
      sp(),

      // ── 테마 & 유틸리티 ───────────────────────────────────────
      h2('2-2. 유틸리티 (lib/utils/)'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('theme.dart', '전체 앱 색상 팔레트, 폰트, 버튼/카드/네비게이션 스타일 정의. AppTheme 클래스.'),
        fileRow('constants.dart', '포인트 배율, 가챠 확률 등 앱 전역 상수 정의. AppConstants 클래스.', C.bg),
        fileRow('answer_checker.dart', '영어 정답 판별 로직. 대소문자/공백/특수문자 허용 범위 처리.'),
      ]),
      sp(),

      // ── 데이터 모델 ───────────────────────────────────────────
      h2('2-3. 데이터 모델 (lib/models/)'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('monster.dart', 'MonsterSpecies (몬스터 종류 정의) + UserMonsterProgress (사용자별 진화 상태, 포인트).'),
        fileRow('user_progress.dart', '전체 게임 진행 상태: 포인트, 완료 Day, 몬스터 목록, 단어 기록 등.', C.bg),
        fileRow('question.dart', '퀴즈 문제 데이터 구조 (한국어 ↔ 영어 문장 쌍).'),
        fileRow('vocab_item.dart', '단어 암기 항목 구조 (단어, 뜻, 예문).', C.bg),
        fileRow('wrong_answer.dart', '오답 기록 (틀린 문제, 제출 답안, 날짜).'),
      ]),
      sp(),

      // ── 데이터 정의 ───────────────────────────────────────────
      h2('2-4. 데이터 정의 (lib/data/)'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('monster_data.dart', '25종 몬스터 전체 정의. ID, 이름, 속성, 6단계 진화명/이모지, 레어도, 설명.'),
        fileRow('sprite_coordinates.dart', '몬스터 ID → 이미지 타입명 매핑 (개별 PNG 방식으로 전환 후 레거시).', C.bg),
      ]),
      sp(),

      // ── 서비스 ────────────────────────────────────────────────
      h2('2-5. 서비스 레이어 (lib/services/)'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('storage_service.dart', 'SharedPreferences 기반 데이터 저장/불러오기. 모든 진행 상태 직렬화(JSON).'),
        fileRow('question_loader.dart', 'assets/data/ 폴더의 JSON 파일에서 퀴즈 문제 로드.', C.bg),
        fileRow('vocab_loader.dart', 'assets/data/ 폴더의 JSON 파일에서 단어 목록 로드.'),
      ]),
      sp(),

      // ── 상태관리 ──────────────────────────────────────────────
      h2('2-6. 상태관리 (lib/providers/)'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('app_provider.dart', '앱 전체 상태 관리 (ChangeNotifier). 게임 로직: 포인트 지급, 몬스터 진화, 가챠, Day 완료 처리.'),
      ]),
      sp(),

      // ── 화면 ──────────────────────────────────────────────────
      h2('2-7. 화면 (lib/screens/)'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('splash_screen.dart', '앱 시작 로딩 화면. 데이터 초기화 완료 후 HomeScreen으로 이동.'),
        fileRow('home_screen.dart', '메인 화면. 하단 내비게이션 (홈탭 / 단어암기 / 도감). 몬스터 공원 표시.', C.bg),
        fileRow('collection_screen.dart', '몬스터 도감. 3열 그리드, 보유/미보유 구분, 진화 화면 포함.'),
        fileRow('gacha_screen.dart', '몬스터 뽑기 화면. 확률 표시, 연속 뽑기, 신규 몬스터 축하 애니메이션.', C.bg),
        fileRow('level_select_screen.dart', '퀴즈 레벨 선택 (초급/중급/고급). Day 완료 상태 시각화.'),
        fileRow('quiz_screen.dart', '영작 퀴즈 진행. 텍스트 입력, 정답 판별, 포인트 적립.', C.bg),
        fileRow('day_complete_screen.dart', 'Day 완료 결과 화면. 획득 포인트, 정답률, 몬스터 반응.'),
        fileRow('vocab_screen.dart', '단어 암기 화면. 카드 플립, 알고/모름 분류, 복습 기능.', C.bg),
        fileRow('review_screen.dart', '오답 복습 화면. 틀린 문제 목록 및 재도전.'),
        fileRow('settings_screen.dart', '설정 화면. 개발자 모드, 데이터 초기화, 앱 정보.', C.bg),
      ]),
      sp(),

      // ── 위젯 ──────────────────────────────────────────────────
      h2('2-8. 커스텀 위젯 (lib/widgets/)'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('monster_sprite_widget.dart', '몬스터 이미지 표시 위젯. ID+단계 → PNG 경로 자동 매핑. 그레이스케일(실루엣) 지원.'),
      ]),
      sp(),

      // ── 에셋 ──────────────────────────────────────────────────
      h2('2-9. 에셋 (assets/)'),
      fileTable([
        fileHeader('경로', '내용'),
        fileRow('assets/images/', '몬스터 스프라이트 시트 원본 (monsters_sprite.png) 등.'),
        fileRow('assets/images/monsters_transparent/', '타입별 개별 PNG — fire/water/lightning/metal/grass/dark/rainbow/normal/light/cloud/wind/ice/earth/poison/chaos × 6단계. 총 90장.', C.bg),
        fileRow('assets/data/beginner/', '초급 퀴즈/단어 JSON 파일 (Day별).'),
        fileRow('assets/data/intermediate/', '중급 퀴즈/단어 JSON 파일.', C.bg),
        fileRow('assets/data/advanced/', '고급 퀴즈/단어 JSON 파일.'),
      ]),
      sp(),

      // ── 빌드 스크립트 ─────────────────────────────────────────
      h2('2-10. 빌드 & 유틸 스크립트 (프로젝트 루트)'),
      fileTable([
        fileHeader('파일', '역할'),
        fileRow('build_release.bat', '★ 현재 사용 중인 릴리즈 APK 빌드 스크립트. flutter build apk --release 실행 후 writemon_sprite.apk로 복사.'),
        fileRow('build_now.bat', '이전 버전 빌드 스크립트 (레거시).', C.bg),
        fileRow('build_apk.bat / build_apk2.bat', '초기 빌드 시도 스크립트 (레거시).'),
        fileRow('analyze_*.bat / analyze_*.py', '스프라이트 시트 좌표 분석용 스크립트 (레거시, 개별 PNG 전환 후 불필요).', C.bg),
        fileRow('copy_sprite_and_build.bat', '스프라이트 이미지 복사 + 빌드 통합 스크립트 (레거시).'),
      ]),
      sp(),

      new Paragraph({ children: [new PageBreak()] }),

      // ══════════════════════════════════════════════════════════════
      // 3. 개발 과정
      // ══════════════════════════════════════════════════════════════
      h1('3. 개발 과정'),
      body('이 앱은 "바이브 코딩" 방식으로 개발되었습니다. Claude AI가 코드를 작성하고, 사용자가 방향을 잡고 피드백을 주는 반복 사이클로 진행되었습니다.'),
      sp(),

      // Phase 1
      sectionBanner('Phase 1 — 프로젝트 기초 설계', C.darkBlue),
      sp(),
      h3('목표: Flutter 프로젝트 뼈대 + 핵심 학습 흐름 구축'),
      bullet('Flutter 프로젝트 초기화 및 폴더 구조 설계'),
      bullet('퀴즈 화면 (영작 입력 + 정답 판별) 구현'),
      bullet('초급/중급/고급 레벨 선택 → Day 선택 → 퀴즈 진행 흐름'),
      bullet('answer_checker.dart: 대소문자, 공백, 구두점 허용 범위 처리 로직'),
      bullet('SharedPreferences로 진행 상태 저장 (day 완료 여부, 점수)'),
      sp(),
      h3('핵심 결정사항'),
      bullet('상태관리: Provider 패턴 선택 (GetX, Riverpod 대비 보일러플레이트 적음)'),
      bullet('저장 방식: SQLite 대신 SharedPreferences 선택 (데이터 구조 단순, 설치 간단)'),
      sp(2),

      // Phase 2
      sectionBanner('Phase 2 — 몬스터 시스템 설계', C.slate),
      sp(),
      h3('목표: 게임화 요소 — 25종 몬스터 + 가챠 + 진화'),
      bullet('MonsterSpecies 모델 설계: ID, 이름, 속성, 6단계 진화명/이모지'),
      bullet('25종 몬스터 데이터 작성 (18 common + 7 hidden)'),
      bullet('히든 몬스터 조건: 이름에 환상/무지개/빛/어둠/혼돈/우주/요정 포함'),
      bullet('가챠 시스템: common 97%, hidden 3% 확률'),
      bullet('진화 포인트 시스템: 퀴즈 완료 → 포인트 적립 → 수동 진화'),
      bullet('진화 임계값: 0 / 50 / 150 / 300 / 500 포인트 (5단계 → 6단계)'),
      sp(),
      h3('앱 Provider 주요 기능'),
      bullet('completeDay(): 퀴즈 완료 시 포인트 지급, 중복 완료 방지'),
      bullet('canEvolveMonster(): 진화 가능 여부 확인 (stage < 5 && evolutionPoints >= 비용)'),
      bullet('evolveMonster(): 진화 실행, 진화 포인트 차감'),
      bullet('gachaMonster(): 가챠 실행, 히든 3% 확률, 중복 보호'),
      sp(2),

      // Phase 3
      sectionBanner('Phase 3 — 화면 UI 구축', C.purple),
      sp(),
      h3('목표: 완성도 있는 화면 설계 및 다크 테마'),
      bullet('SplashScreen → HomeScreen → 세 탭 (홈/단어암기/도감) 구조'),
      bullet('다크 테마 전용 색상 팔레트: 보라 계열 primary (#6C63FF), 딥 다크 배경 (#0D0D1A)'),
      bullet('NavigationBar: 하단 3탭 (홈, 단어 암기, 도감)'),
      bullet('CollectionScreen: 도감 그리드, 보유 몬스터 카드, 미보유 실루엣'),
      bullet('GachaScreen: 뽑기 애니메이션, confetti 라이브러리 활용'),
      bullet('DayCompleteScreen: 완료 축하 화면, 포인트 요약'),
      sp(2),

      // Phase 4
      sectionBanner('Phase 4 — 스프라이트 이미지 시스템', C.teal),
      sp(),
      h3('목표: 실제 몬스터 이미지로 앱 시각화'),
      bullet('1차 시도: 스프라이트 시트(sprite sheet) 방식 — 하나의 PNG에서 좌표로 잘라내기'),
      bullet('문제: Gemini 생성 이미지의 정확한 픽셀 좌표 파악이 어려움 (bash 환경 없음)'),
      bullet('해결: 개별 PNG 파일로 전환 — 15개 타입 × 6단계 = 90장 파일'),
      bullet('MonsterSpriteWidget: monsterId → 이미지 타입 매핑 → Image.asset() 로드'),
      bullet('그레이스케일 지원: ColorFilter.matrix()로 미보유 몬스터 실루엣 표시'),
      sp(2),

      // Phase 5
      sectionBanner('Phase 5 — UI 개선 및 상품화 다듬기', C.accent),
      sp(),
      h3('목표: 사용자 피드백 기반 UI 세부 조정'),
      bullet('도감 그리드: 2열 → 3열 (한 화면에 10개 이상 몬스터 표시)'),
      bullet('진화 스낵바: SnackBarBehavior.fixed로 변경 → 진화하기 버튼 가리지 않게'),
      bullet('홈 화면: 개별 몬스터 카드 제거 (MonsterCard 섹션 삭제)'),
      bullet('테마 고도화: 더 깊은 다크 (#0D0D1A), 생동감 있는 보라 (#6C63FF), 핑크 포인트 (#FF6B9D)'),
      bullet('NavigationBar: MaterialStateProperty 사용 (Flutter 3.0 호환성 확보)'),
      sp(2),

      new Paragraph({ children: [new PageBreak()] }),

      // ══════════════════════════════════════════════════════════════
      // 4. 핵심 기술 포인트
      // ══════════════════════════════════════════════════════════════
      h1('4. 핵심 기술 포인트'),

      h2('4-1. Provider 상태관리 패턴'),
      body('AppProvider가 ChangeNotifier를 상속해 앱 전체 상태를 관리합니다. 각 화면은 context.watch<AppProvider>()로 상태를 구독하고, 상태 변경 시 자동으로 리빌드됩니다.'),
      sp(),
      h2('4-2. 스프라이트 위젯 구조'),
      body('MonsterSpriteWidget은 monsterId와 stage(0~5)를 받아 해당 PNG 경로를 결정합니다. isGrayscale=true이면 ColorFilter.matrix()로 흑백 처리해 미보유 실루엣으로 표시합니다.'),
      sp(),
      h2('4-3. 정답 판별 로직'),
      body('영어 작문의 특성상 정확한 정답 판별이 중요합니다. answer_checker.dart는 대소문자 무시, 앞뒤 공백 제거, 축약형(it\'s = it is) 허용 등 실용적인 허용 범위를 적용합니다.'),
      sp(),
      h2('4-4. 빌드 환경'),
      body('bash 환경이 제공되지 않아 모든 자동화 작업은 Windows .bat 스크립트로 처리했습니다. flutter build apk --release 명령으로 릴리즈 APK를 생성하며, writemon_sprite.apk로 최종 파일명을 지정합니다.'),
      sp(2),

      // ══════════════════════════════════════════════════════════════
      // 5. 정리 제안
      // ══════════════════════════════════════════════════════════════
      h1('5. 폴더 정리 권장사항'),
      body('개발 과정에서 생성된 임시/레거시 파일들이 프로젝트 루트에 많이 쌓였습니다. 아래 파일들은 삭제하거나 별도 폴더로 정리를 권장합니다:'),
      sp(),
      h2('삭제 권장 (레거시 스크립트)'),
      bullet('build_apk.bat, build_apk2.bat, build_dev_apk.bat, build_now.bat, build_final.bat'),
      bullet('analyze_now.bat, do_analyze.bat, run_analyze_sprites.bat, run_simple_analyze.bat'),
      bullet('run_analyze_sprite2.bat, run_grid_check.bat, run_get_size.bat, run_copy_sprite.bat'),
      bullet('copy_sprite_and_build.bat, analyze_*.log (각종 로그 텍스트 파일)'),
      sp(),
      h2('유지 권장'),
      bullet('build_release.bat — 현재 사용 중인 공식 빌드 스크립트'),
      bullet('lib/ 전체 — 앱 소스 코드'),
      bullet('assets/ 전체 — 이미지, 데이터 파일'),
      bullet('android/ — Android 네이티브 설정'),
      bullet('pubspec.yaml — 패키지 의존성'),
      sp(2),
      hr(),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 120, after: 0 },
        children: [
          new TextRun({ text: '영작몬 개발 문서 | Claude AI × 김형진 | 2026.05', size: 18, color: C.slate, italics: true }),
        ],
      }),
    ],
  }],
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync('C:/Users/91618/WriteMon/WriteMon_개발문서.docx', buf);
  console.log('SUCCESS: WriteMon_개발문서.docx created');
}).catch(e => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
