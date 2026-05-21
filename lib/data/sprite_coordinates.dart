// ─────────────────────────────────────────────────────────────
// 스프라이트 시트 좌표 설정
//
// 이미지: assets/images/monsters_sprite.png
// 구조: 2열 (왼쪽/오른쪽), 각 열에 여러 행
//       각 행 = 1종 몬스터의 6단계 진화 스프라이트
//       (왼쪽 열 8행, 오른쪽 열 9행)
//       라벨 열 없음 — 가장 작은 아이콘이 stage 0 스프라이트
//
// ⚠️ 실제 이미지 크기가 다르면 imageWidth / imageHeight 만 수정
// ─────────────────────────────────────────────────────────────

class SpriteConfig {
  // ──────────────── 이미지 전체 크기 ──────────────────────────
  // Gemini 생성 이미지 기준. 실제 크기와 다르면 여기만 수정.
  static const double imageWidth  = 1024;
  static const double imageHeight = 1024;

  // ──────────────── 그리드 레이아웃 ───────────────────────────
  static const int    totalRowsRight = 9;   // 오른쪽 열 행 수 (기준)
  static const double rowHeight = imageHeight / totalRowsRight; // ~113px

  static const double colWidth   = imageWidth / 2;  // 512px
  static const double labelWidth = 0;               // 라벨 없음: stage 0이 가장 작은 아이콘
  static const int    stagesCount = 6;

  // 각 스프라이트 셀 너비 (열 너비를 6등분)
  static const double cellWidth = (colWidth - labelWidth) / stagesCount; // ~85px

  // ──────────────── 몬스터 ID → (열, 행) 매핑 ─────────────────
  // 열: 0 = 왼쪽, 1 = 오른쪽 / 행: 0부터 시작
  static const Map<String, List<int>> _monsterGridPos = {
    // ── 왼쪽 열 (8행) ──────────────────────────────────────────
    'flameling':    [0, 0], // 불
    'aqualing':     [0, 1], // 물
    'thunderling':  [0, 2], // 번개
    'crystaling':   [0, 3], // 금속
    'naturaling':   [0, 4], // 풀
    'darkmaster':   [0, 5], // 어둠 (히든)
    'phoenixling':  [0, 6], // 무지개 (히든)
    'ghostling':    [0, 7], // 무속성

    // ── 오른쪽 열 (9행) ─────────────────────────────────────────
    'lightguard':   [1, 0], // 빛 (히든)
    'cloudling':    [1, 1], // 구름
    'windling':     [1, 2], // 바람
    'frostling':    [1, 3], // 얼음
    'terraling':    [1, 4], // 땅
    'mushroomling': [1, 5], // 독
    'chaosling':    [1, 6], // 혼돈 (히든)
    'cosmosling':   [1, 7], // 우주 (히든)
    'fairyling':    [1, 8], // 요정 (히든)
  };

  /// 특정 몬스터의 특정 진화 단계 스프라이트의 소스 Rect 반환.
  /// 매핑이 없으면 null 반환 (→ 이모지 폴백).
  static SpriteRect? getRect(String monsterId, int stage) {
    final pos = _monsterGridPos[monsterId];
    if (pos == null) return null;
    if (stage < 0 || stage >= stagesCount) return null;

    final col = pos[0];
    final row = pos[1];

    final x = col * colWidth + labelWidth + stage * cellWidth;
    final y = row * rowHeight;

    return SpriteRect(x: x, y: y, w: cellWidth, h: rowHeight);
  }
}

class SpriteRect {
  final double x, y, w, h;
  const SpriteRect({required this.x, required this.y, required this.w, required this.h});
}
