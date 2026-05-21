class AppConstants {
  static const int daysPerLevel = 50;
  static const int questionsPerDay = 5;

  // 포인트 설정
  static const int pointsCorrectFirst = 10;
  static const int pointsCorrectWithHint = 7;
  static const int pointsShowAnswer = 3;
  static const int pointsDayComplete = 20;

  // 몬스터 진화 포인트 임계값
  static const List<int> evolutionThresholds = [0, 50, 150, 300, 500];

  // 새 몬스터 해금 조건 (완료한 day 수)
  static const List<int> monsterUnlockDays = [1, 5, 10, 20, 30, 50, 70, 100, 150, 200, 250, 300];

  // 레벨 이름
  static const List<String> levelNames = ['초급', '중급', '고급'];
  static const List<String> levelDescriptions = [
    '기초 문법과 일상 표현',
    '중급 문법과 자연스러운 표현',
    '고급 표현과 원어민 스타일',
  ];

  // 속성 색상
  static const Map<String, int> elementColors = {
    '불': 0xFFFF4500,
    '물': 0xFF1E90FF,
    '흙': 0xFF8B6914,
    '바람': 0xFF90EE90,
    '번개': 0xFFFFD700,
    '어둠': 0xFF6A0DAD,
    '빛': 0xFFFFFACD,
    '얼음': 0xFF87CEEB,
  };
}
