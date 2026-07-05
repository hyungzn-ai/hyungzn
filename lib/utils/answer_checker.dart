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

  static List<String> _tokens(String text) {
    return _normalize(text).split(' ').where((w) => w.isNotEmpty).toList();
  }

  /// 오답일 때 부분 정답 피드백 생성 (어디까지 맞았는지 알려주기)
  static String partialFeedback(String userAnswer, String bestAnswer) {
    final u = _tokens(userAnswer);
    final b = _tokens(bestAnswer);
    if (u.isEmpty || b.isEmpty) return '';

    final uSet = u.toSet();
    final bSet = b.toSet();
    final missing = bSet.difference(uSet).toList();
    final extra = uSet.difference(bSet).toList();

    if (missing.isEmpty && extra.isEmpty) {
      return '🧩 단어는 전부 맞았어요! 어순만 다시 확인해보세요.';
    }

    final matched = bSet.length - missing.length;
    final lines = <String>[];
    if (matched > 0 && matched * 2 >= bSet.length) {
      lines.add('👍 절반 이상 맞았어요! 조금만 더!');
    }
    if (missing.isNotEmpty && missing.length <= 3) {
      final joined = missing.join(', ');
      lines.add('🔍 빠진 단어: ' + joined);
    }
    if (extra.isNotEmpty && extra.length <= 3) {
      final joined = extra.join(', ');
      lines.add('✂️ 불필요한 단어: ' + joined);
    }
    return lines.join('\n');
  }

  static AnswerResult check(String userAnswer, List<String> acceptedAnswers,
      {List<String> keywords = const [], String naturalForm = ''}) {
    if (userAnswer.trim().isEmpty) {
      return const AnswerResult(
          isCorrect: false, isNatural: false, feedback: '답을 입력해 주세요.');
    }

    final normalizedUser = _normalize(userAnswer);
    final best = acceptedAnswers[0];

    // 정확히 일치하는 답 검사
    for (int i = 0; i < acceptedAnswers.length; i++) {
      final normalizedAccepted = _normalize(acceptedAnswers[i]);
      if (normalizedUser == normalizedAccepted) {
        final isNatural = i == 0; // 첫 번째 답이 가장 자연스러운 표현
        final feedback = isNatural
            ? '완벽해요! 가장 자연스러운 표현이에요. 👍'
            : '맞아요! 참고로 더 자연스러운 표현은:\n"' + best + '"';
        return AnswerResult(
            isCorrect: true, isNatural: isNatural, feedback: feedback);
      }
    }

    // 키워드 기반 검사 (약간 어색해도 핵심은 맞는 경우)
    if (keywords.isNotEmpty && _containsKeywords(userAnswer, keywords)) {
      return AnswerResult(
        isCorrect: true,
        isNatural: false,
        feedback: '맞아요! 더 자연스러운 표현은:\n"' + best + '"',
      );
    }

    // 오답 — 부분 정답 피드백 포함
    final partial = partialFeedback(userAnswer, best);
    var feedback = '아쉬워요. 정답: "' + best + '"';
    if (partial.isNotEmpty) {
      feedback = partial + '\n\n' + feedback;
    }
    if (naturalForm.isNotEmpty) {
      feedback = feedback + '\n\n💡 ' + naturalForm;
    }
    return AnswerResult(isCorrect: false, isNatural: false, feedback: feedback);
  }
}
