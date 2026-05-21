import 'wrong_answer.dart';

class UserProgress {
  int totalPoints;
  int evolutionPoints; // 진화 포인트 (중복 뽑기 시 50 획득, 진화 시 200 소비)
  Map<String, Set<int>> completedDays; // 'beginner'/'intermediate'/'advanced' -> Set of day numbers
  Map<String, Map<int, int>> dayScores; // levelKey -> {day -> score(0-5)}
  int totalCompletedDays;
  Map<String, UserMonsterProgress> monsters;
  String activeMonsterSpeciesId;
  Set<int> completedVocabSets;
  Set<String> unknownVocabIds; // 모르는 단어 ID 목록
  int totalGachaCount; // 전체 가챠 횟수
  int rareGachaCount; // 히든 획득 횟수
  DateTime? lastPlayedDate;
  List<WrongAnswer> wrongAnswers; // 틀린 문제 목록

  UserProgress({
    this.totalPoints = 0,
    this.evolutionPoints = 0,
    Map<String, Set<int>>? completedDays,
    Map<String, Map<int, int>>? dayScores,
    this.totalCompletedDays = 0,
    Map<String, UserMonsterProgress>? monsters,
    this.activeMonsterSpeciesId = 'flameling',
    Set<int>? completedVocabSets,
    Set<String>? unknownVocabIds,
    this.totalGachaCount = 0,
    this.rareGachaCount = 0,
    this.lastPlayedDate,
    List<WrongAnswer>? wrongAnswers,
  })  : completedDays = completedDays ??
            {
              'beginner': {},
              'intermediate': {},
              'advanced': {},
            },
        dayScores = dayScores ?? {'beginner': {}, 'intermediate': {}, 'advanced': {}},
        monsters = monsters ?? {},
        completedVocabSets = completedVocabSets ?? {},
        unknownVocabIds = unknownVocabIds ?? {},
        wrongAnswers = wrongAnswers ?? [];

  bool isDayCompleted(String level, int day) => completedDays[level]?.contains(day) ?? false;

  bool isDayUnlocked(String level, int day) {
    if (day == 1) return true;
    return completedDays[level]?.contains(day - 1) ?? false;
  }

  /// 난이도 잠금 완전 해제 — 초급/중급/고급 언제든지 자유롭게 선택 가능
  bool isLevelUnlocked(String level) => true;

  int getCompletedCount(String level) => completedDays[level]?.length ?? 0;
}

class UserMonsterProgress {
  int points;
  int evolutionStage;

  UserMonsterProgress({this.points = 0, this.evolutionStage = 0});

  Map<String, dynamic> toJson() => {'points': points, 'evolutionStage': evolutionStage};

  factory UserMonsterProgress.fromJson(Map<String, dynamic> json) =>
      UserMonsterProgress(points: json['points'] ?? 0, evolutionStage: json['evolutionStage'] ?? 0);
}
