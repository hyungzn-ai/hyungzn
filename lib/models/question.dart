class Question {
  final String korean;
  final List<String> answers; // 첫 번째가 가장 자연스러운 정답
  final String hint;
  final String explanation;
  final List<String> keywords; // 키워드 기반 채점용

  const Question({
    required this.korean,
    required this.answers,
    required this.hint,
    this.explanation = '',
    this.keywords = const [],
  });
}

class DayData {
  final int day;
  final String topic;
  final List<Question> questions;

  const DayData({
    required this.day,
    required this.topic,
    required this.questions,
  });
}
