import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// MonsterSpriteWidget
//
// 개별 PNG 파일 방식으로 몬스터 스프라이트를 표시합니다.
// assets/images/monsters_transparent/monster_{type}_stage{N}.png
//
// 파일이 없거나 로드 실패 시 fallbackEmoji로 대체합니다.
// ─────────────────────────────────────────────────────────────

class MonsterSpriteWidget extends StatelessWidget {
  final String monsterId;
  final int    stage;          // 0~4
  final double size;
  final String fallbackEmoji;
  final bool   isGrayscale;

  const MonsterSpriteWidget({
    super.key,
    required this.monsterId,
    required this.stage,
    required this.size,
    required this.fallbackEmoji,
    this.isGrayscale = false,
  });

  // ── 몬스터 ID → 스프라이트 타입명 매핑 ─────────────────────
  static const Map<String, String> _idToSpriteType = {
    'flameling':    'fire',
    'aqualing':     'water',
    'thunderling':  'lightning',
    'crystaling':   'metal',
    'naturaling':   'grass',
    'blossoling':   'grass',
    'shadowling':   'dark',
    'darkmaster':   'dark',
    'phoenixling':  'rainbow',
    'ghostling':    'normal',
    'lightling':    'light',
    'lightguard':   'light',
    'cloudling':    'cloud',
    'frostling':    'ice',
    'terraling':    'earth',
    'sandling':     'earth',
    'mushroomling': 'poison',
    'chaosling':    'chaos',
    'fairyling':    'fairy',
    'windling':     'wind',
    'stormling':    'wind',
  };

  // ── 개별 PNG 경로 계산 ──────────────────────────────────────
  String? get _assetPath {
    final type = _idToSpriteType[monsterId];
    if (type == null) return null;
    final s = stage.clamp(0, 4) + 1;   // 0-indexed → 1-indexed 파일명 (5단계)
    return 'assets/images/monsters_transparent/monster_${type}_stage$s.png';
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetPath;
    if (path == null) return _emojiWidget(fallbackEmoji);

    Widget img = Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _emojiWidget(fallbackEmoji),
    );

    if (isGrayscale) {
      img = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      0.7, 0,
        ]),
        child: img,
      );
    }
    return SizedBox(width: size, height: size, child: img);
  }

  Widget _emojiWidget(String emoji) {
    final fs = size * 0.7;
    Widget w = Text(emoji, style: TextStyle(fontSize: fs));
    if (isGrayscale) {
      w = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      0.7, 0,
        ]),
        child: w,
      );
    }
    return SizedBox(width: size, height: size, child: Center(child: w));
  }
}
