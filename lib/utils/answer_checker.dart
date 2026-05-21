class AnswerResult {
  final bool isCorrect;
  final bool isNatural;
  final String feedback;

  const AnswerResult({
    required this.isCorrect,
    required this.isNatural,
    required this.feedback,
  });
}

class AnswerChecker {
  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"""[.,!?;:'"]+"""), '')
        .replaceAll("i'm", 'i am')
        .replaceAll("she's", 'she is')
        .replaceAll("he's", 'he is')
        .replaceAll("it's", 'it is')
        .replaceAll("we're", 'we are')
        .replaceAll("they're", 'they are')
        .replaceAll("you're", 'you are')
        .replaceAll("don't", 'do not')
        .replaceAll("doesn't", 'does not')
        .replaceAll("didn't", 'did not')
        .replaceAll("can't", 'cannot')
        .replaceAll("won't", 'will not')
        .replaceAll("isn't", 'is not')
        .replaceAll("aren't", 'are not')
        .replaceAll("wasn't", 'was not')
        .replaceAll("weren't", 'were not')
        .replaceAll("i've", 'i have')
        .replaceAll("i'll", 'i will')
        .replaceAll("i'd", 'i would')
        .trim();
  }

  // 키워드 일치 검사 (핵심 단어들이 모두 포함되는지)
  static bool _containsKeywords(String userAnswer, List<String> keywords) {
    final normalized = _normalize(userAnswer);
    return keywords.every((kw) => normalized.contains(kw.toLowerCase()));
  }

  static AnswerResult check(String userAnswer, List<String> acceptedAnswers,
      {List<String> keywords = const [], String naturalForm = ''}) {
    if (userAnswer.trim().isEmpty) {
      return const AnswerResult(isCorrect: false, isNatural: false, feedback: '답을 입력해 주세요.');
    }

    final normalizedUser = _normalize(userAnswer);

    // 정확히 일치하는 답 검사
    for (int i = 0; i < acceptedAnswers.length; i++) {
      final normalizedAccepted = _normalize(acceptedAnswers[i]);
      if (normalizedUser == normalizedAccepted) {
        final isNatural = i == 0; // 첫 번째 답이 가장 자연스러운 표현
        final feedback = isNatural
            ? '완벽해요! 가장 자연스러운 표현이에요. 👍'
            : '맞아요! 참고로 더 자연스러운 표현은:\n"${acceptedAnswers[0]}"';
        return AnswerResult(isCorrect: true, isNatural: isNatural, feedback: feedback);
      }
    }

    // 키워드 기반 검사 (약간 어색해도 핵심은 맞는 경우)
    if (keywords.isNotEmpty && _containsKeywords(userAnswer, keywords)) {
      return AnswerResult(
        isCorrect: true,
        isNatural: false,
        feedback: '맞아요! 더 자연스러운 표현은:\n"${acceptedAnswers[0]}"',
      );
    }

    return AnswerResult(
      isCorrect: false,
      isNatural: false,
      feedback: naturalForm.isNotEmpty
          ? '아쉬워요. 정답: "${acceptedAnswers[0]}"\n\n💡 $naturalForm'
          : '아쉬워요. 정답: "${acceptedAnswers[0]}"',
    );
  }
}
