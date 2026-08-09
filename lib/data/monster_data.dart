import 'package:flutter/material.dart';
import '../models/monster.dart';

class MonsterData {
  // ─────────────────────────────────────────────────────────────
  // 16종 몬스터 (11 common + 5 hidden)
  // hidden 조건: 이름에 '환상', '무지개', '빛', '어둠', '혼돈', '우주', '요정' 포함
  // ─────────────────────────────────────────────────────────────
  static const List<MonsterSpecies> allSpecies = [
    // ── Common (11종) ──────────────────────────────────────────
    MonsterSpecies(
      id: 'flameling',
      name: '플레임링',
      element: '불',
      evolutionNames: ['플레임링', '플레이머', '인페르노', '블레이즈론', '피닉스로드', '인페르노신'],
      evolutionEmojis: ['🐣', '🔥', '🦊', '🐉', '🦅', '🌋'],
      description: '불꽃에서 태어난 작은 생명체. 열정과 용기를 상징해.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'aqualing',
      name: '아쿠아링',
      element: '물',
      evolutionNames: ['아쿠아링', '워터픽', '타이달', '오션가드', '포세이돈', '해신왕'],
      evolutionEmojis: ['💧', '🐠', '🐟', '🐳', '🌊', '🔱'],
      description: '물에서 탄생한 신비로운 존재. 지혜와 적응력의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'terraling',
      name: '테라링',
      element: '흙',
      evolutionNames: ['테라링', '록키', '마운틴', '지오가드', '가이아', '대지신'],
      evolutionEmojis: ['🌱', '🪨', '⛰️', '🏔️', '🌍', '🗻'],
      description: '대지에서 솟아오른 강인한 존재. 인내와 안정의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'windling',
      name: '윈들링',
      element: '바람',
      evolutionNames: ['윈들링', '제피르', '사이클론', '스톰윙', '하늘의왕', '폭풍신'],
      evolutionEmojis: ['🌀', '💨', '🌪️', '⛅', '🌩️', '⚡'],
      description: '바람을 타고 나타나는 자유로운 존재. 자유와 속도의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'thunderling',
      name: '선더링',
      element: '번개',
      evolutionNames: ['선더링', '볼텍스', '라이트닝', '스톰볼트', '제우스', '뇌신황제'],
      evolutionEmojis: ['⚡', '🌩️', '💥', '🌟', '👑', '⚡'],
      description: '폭풍 속에서 탄생한 강렬한 존재. 힘과 결단의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'frostling',
      name: '프로스트링',
      element: '얼음',
      evolutionNames: ['프로스트링', '아이스픽', '블리자드', '크리스탈가드', '아이스로드', '빙하신'],
      evolutionEmojis: ['❄️', '🧊', '🌨️', '🏔️', '💎', '🫧'],
      description: '얼음 속에서 잠든 신비로운 존재. 냉정함과 지혜의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'naturaling',
      name: '네이처링',
      element: '자연',
      evolutionNames: ['네이처링', '그린픽', '포레스트', '그로브가드', '월드트리', '생명의신'],
      evolutionEmojis: ['🌿', '🍀', '🌳', '🌲', '🌏', '🌺'],
      description: '자연의 기운을 품은 생명체. 생명과 번영의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'mushroomling',
      name: '머쉬루밍',
      element: '독',
      evolutionNames: ['머쉬루밍', '독버섯', '스포어', '독왕', '마이코맹', '독신황제'],
      evolutionEmojis: ['🍄', '🌿', '💜', '🟣', '☠️', '💀'],
      description: '숲의 그늘에서 자라난 신비한 버섯 정령. 독과 치유를 동시에 품어.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'cloudling',
      name: '클라우딩',
      element: '구름',
      evolutionNames: ['클라우딩', '미스트', '시러스', '넴버스', '스카이킹', '천공지배자'],
      evolutionEmojis: ['☁️', '🌥️', '⛅', '🌦️', '🌈', '🌤️'],
      description: '하늘을 떠도는 구름에서 태어난 존재. 자유와 꿈의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'crystaling',
      name: '크리스탈링',
      element: '광물',
      evolutionNames: ['크리스탈링', '루비트', '다이아몬', '젬가드', '크리스탈로드', '보석의신'],
      evolutionEmojis: ['💎', '🔷', '🔮', '💠', '👑', '💫'],
      description: '지하 깊은 곳에서 자란 결정 생명체. 불굴의 의지와 순수함의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),
    MonsterSpecies(
      id: 'ghostling',
      name: '고스트링',
      element: '영혼',
      evolutionNames: ['고스트링', '스피릿', '렘넌트', '에테르', '소울로드', '영혼지배자'],
      evolutionEmojis: ['👻', '🌫️', '💨', '🔮', '🕯️', '💀'],
      description: '이세계에서 넘어온 신비한 영혼. 지식과 통찰의 상징.',
      unlockDay: 0,
      rarity: MonsterRarity.common,
    ),

    // ── Hidden (5종, 각 3%) ────────────────────────────────────
    // 이름에 '환상', '무지개', '빛', '어둠' 포함 → 히든 몬스터
    MonsterSpecies(
      id: 'phoenixling',
      name: '무지개피닉스',
      element: '전설',
      evolutionNames: ['무지개피닉스', '무지개파이어버드', '무지개선라이즈', '무지개리버스', '무지개불사조', '무지개신조'],
      evolutionEmojis: ['🐣', '🦜', '🦚', '🦩', '🦅', '🌈'],
      description: '✨ 히든 ✨ 무지개 깃털을 가진 불사조. 재생과 영원의 상징.',
      unlockDay: 999,
      rarity: MonsterRarity.hidden,
    ),
    MonsterSpecies(
      id: 'lightguard',
      name: '빛의가디언',
      element: '신성',
      evolutionNames: ['빛의가디언', '빛의기사', '빛의성자', '빛의천사', '빛의신', '빛의창조주'],
      evolutionEmojis: ['💡', '🌟', '⭐', '✨', '👼', '☀️'],
      description: '✨ 히든 ✨ 빛 그 자체로 태어난 신성한 존재. 모든 어둠을 몰아내는 수호자.',
      unlockDay: 999,
      rarity: MonsterRarity.hidden,
    ),
    MonsterSpecies(
      id: 'darkmaster',
      name: '어둠기사',
      element: '암흑',
      evolutionNames: ['어둠기사', '어둠군주', '어둠황제', '어둠신', '어둠지배자', '어둠의창조주'],
      evolutionEmojis: ['🌑', '⚔️', '🛡️', '👑', '🔮', '🖤'],
      description: '✨ 히든 ✨ 깊은 어둠에서 깨어난 절대자. 어둠의 힘으로 세계를 지배한다.',
      unlockDay: 999,
      rarity: MonsterRarity.hidden,
    ),
    MonsterSpecies(
      id: 'chaosling',
      name: '혼돈의신',
      element: '혼돈',
      evolutionNames: ['혼돈의씨앗', '혼돈의정령', '혼돈의마왕', '혼돈의지배자', '혼돈의신', '혼돈의창조자'],
      evolutionEmojis: ['🌀', '🌪️', '💢', '🔥', '💥', '🌀'],
      description: '✨ 히든 ✨ 혼돈 그 자체에서 탄생한 원초적 존재. 모든 질서를 무너뜨리는 파괴의 화신.',
      unlockDay: 999,
      rarity: MonsterRarity.hidden,
    ),
    MonsterSpecies(
      id: 'fairyling',
      name: '요정여왕',
      element: '요정',
      evolutionNames: ['요정의싹', '요정의정령', '요정의공주', '요정의대공주', '요정여왕', '요정의신'],
      evolutionEmojis: ['🌸', '🧚', '🌺', '🦋', '👸', '✨'],
      description: '✨ 히든 ✨ 마법의 숲 깊은 곳에서 탄생한 신비로운 요정. 모든 생명에게 축복을 내리는 자연의 여왕.',
      unlockDay: 999,
      rarity: MonsterRarity.hidden,
    ),
  ];

  // ─────────────────────────────────────────────────────────────
  // 풀 분리
  // ─────────────────────────────────────────────────────────────
  static List<MonsterSpecies> get gachaPool => allSpecies;

  static List<MonsterSpecies> get commonPool =>
      allSpecies.where((s) => s.rarity == MonsterRarity.common).toList();

  static List<MonsterSpecies> get hiddenPool =>
      allSpecies.where((s) => s.rarity == MonsterRarity.hidden).toList();

  static MonsterSpecies? getSpecies(String id) {
    try {
      return allSpecies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static bool isHiddenName(String name) {
    return name.contains('환상') ||
        name.contains('무지개') ||
        name.contains('빛') ||
        name.contains('어둠') ||
        name.contains('혼돈') ||
        name.contains('우주') ||
        name.contains('요정');
  }

  static Color elementColor(String element) {
    const Map<String, int> colors = {
      '불': 0xFFFF4500,
      '물': 0xFF1E90FF,
      '흙': 0xFF8B6914,
      '바람': 0xFF7EC8E3,
      '번개': 0xFFFFD700,
      '그림자': 0xFF6A0DAD,
      '광명': 0xFFFFD700,
      '어둠': 0xFF6A0DAD,
      '빛': 0xFFFFD700,
      '얼음': 0xFF87CEEB,
      '자연': 0xFF228B22,
      '우주': 0xFF191970,
      '꽃': 0xFFFF69B4,
      '독': 0xFF9B59B6,
      '구름': 0xFF87CEEB,
      '모래': 0xFFD4A843,
      '광물': 0xFF00BCD4,
      '영혼': 0xFF78909C,
      '폭풍': 0xFF546E7A,
      '마법': 0xFF7E57C2,
      '전설': 0xFFFF8C00,
      '신성': 0xFFFFF8DC,
      '암흑': 0xFF1A0033,
    };
    return Color(colors[element] ?? 0xFF888888);
  }
}
