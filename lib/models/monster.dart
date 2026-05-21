/// 가챠 레어도: common(일반) / hidden(히든)
enum MonsterRarity { common, hidden }

class MonsterSpecies {
  final String id;
  final String name;
  final String element; // 불, 물, 흙, 바람, 번개, 어둠, 빛, 얼음 …
  final List<String> evolutionNames; // 5단계 이름
  final List<String> evolutionEmojis; // 5단계 이모지
  final String description;
  final int unlockDay; // 잠금 해제 기준 (사용 안 함, 하위호환)
  final MonsterRarity rarity;

  const MonsterSpecies({
    required this.id,
    required this.name,
    required this.element,
    required this.evolutionNames,
    required this.evolutionEmojis,
    required this.description,
    required this.unlockDay,
    this.rarity = MonsterRarity.common,
  });

  /// 이름에 '환상', '무지개', '빛', '어둠' 포함 → 히든 몬스터
  bool get isHidden => rarity == MonsterRarity.hidden;
}

class UserMonster {
  final String speciesId;
  int points;
  int evolutionStage; // 0~4 (5단계)
  bool isDiscovered;

  UserMonster({
    required this.speciesId,
    this.points = 0,
    this.evolutionStage = 0,
    this.isDiscovered = false,
  });

  Map<String, dynamic> toJson() => {
        'speciesId': speciesId,
        'points': points,
        'evolutionStage': evolutionStage,
        'isDiscovered': isDiscovered,
      };

  factory UserMonster.fromJson(Map<String, dynamic> json) => UserMonster(
        speciesId: json['speciesId'],
        points: json['points'] ?? 0,
        evolutionStage: json['evolutionStage'] ?? 0,
        isDiscovered: json['isDiscovered'] ?? false,
      );

  // 진화 기준 포인트: 0, 50, 150, 300, 500
  static const List<int> thresholds = [0, 50, 150, 300, 500];

  bool canEvolve() => evolutionStage < 4 && points >= thresholds[evolutionStage + 1];

  int get nextThreshold => evolutionStage < 4 ? thresholds[evolutionStage + 1] : 500;
  int get currentThreshold => thresholds[evolutionStage];

  double get evolutionProgress {
    if (evolutionStage >= 4) return 1.0;
    final range = nextThreshold - currentThreshold;
    final current = points - currentThreshold;
    return (current / range).clamp(0.0, 1.0);
  }
}
