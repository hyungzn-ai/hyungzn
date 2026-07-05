class WrongAnswer {
  final String level; // 'beginner' | 'intermediate' | 'advanced'
  final int day;
  final String korean;
  final List<String> answers;
  final String hint;
  final String explanation;
  final List<String> keywords;
  final int addedAt; // milliseconds since epoch
  final int box; // 복습 단계 (0~2). 3단계 통과 시 졸업(삭제)
  final int nextReviewAt; // 다음 복습 시각 (ms). 0이면 즉시 복습 대상

  const WrongAnswer({
    required this.level,
    required this.day,
    required this.korean,
    required this.answers,
    required this.hint,
    required this.explanation,
    required this.keywords,
    required this.addedAt,
    this.box = 0,
    this.nextReviewAt = 0,
  });

  /// 중복 제거를 위한 고유 키 (level + korean)
  String get key => level + '_' + korean;

  /// 오늘 복습 대상인지
  bool get isDue => nextReviewAt <= DateTime.now().millisecondsSinceEpoch;

  WrongAnswer copyWith({int? box, int? nextReviewAt}) => WrongAnswer(
        level: level,
        day: day,
        korean: korean,
        answers: answers,
        hint: hint,
        explanation: explanation,
        keywords: keywords,
        addedAt: addedAt,
        box: box ?? this.box,
        nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      );

  Map<String, dynamic> toJson() => {
        'level': level,
        'day': day,
        'korean': korean,
        'answers': answers,
        'hint': hint,
        'explanation': explanation,
        'keywords': keywords,
        'addedAt': addedAt,
        'box': box,
        'nextReviewAt': nextReviewAt,
      };

  factory WrongAnswer.fromJson(Map<String, dynamic> json) => WrongAnswer(
        level: json['level'] as String,
        day: json['day'] as int,
        korean: json['korean'] as String,
        answers: List<String>.from(json['answers'] as List),
        hint: json['hint'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        keywords: List<String>.from(json['keywords'] as List? ?? []),
        addedAt: json['addedAt'] as int,
        box: json['box'] as int? ?? 0,
        nextReviewAt: json['nextReviewAt'] as int? ?? 0,
      );

  String get levelName {
    switch (level) {
      case 'beginner':
        return '초급';
      case 'intermediate':
        return '중급';
      case 'advanced':
        return '고급';
      default:
        return level;
    }
  }
}
