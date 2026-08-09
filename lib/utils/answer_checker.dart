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
  // 단어 구성이 거의 같으면(어순만 다름) 키워드 검사 없이 정답
  static const double nearPrecision = 0.9;
  static const double nearRecall = 0.9;
  // 키워드를 모두 포함하면서 문장 구성도 충분히 맞으면 정답
  static const double minPrecision = 0.8;
  static const double minRecall = 0.8;

  static const Map<String, String> _contractions = {
    "i'm": 'i am',
    "she's": 'she is',
    "he's": 'he is',
    "it's": 'it is',
    "that's": 'that is',
    "there's": 'there is',
    "what's": 'what is',
    "who's": 'who is',
    "we're": 'we are',
    "they're": 'they are',
    "you're": 'you are',
    "don't": 'do not',
    "doesn't": 'does not',
    "didn't": 'did not',
    "can't": 'cannot',
    "won't": 'will not',
    "isn't": 'is not',
    "aren't": 'are not',
    "wasn't": 'was not',
    "weren't": 'were not',
    "hasn't": 'has not',
    "haven't": 'have not',
    "hadn't": 'had not',
    "couldn't": 'could not',
    "shouldn't": 'should not',
    "wouldn't": 'would not',
    "i've": 'i have',
    "we've": 'we have',
    "you've": 'you have',
    "they've": 'they have',
    "i'll": 'i will',
    "we'll": 'we will',
    "you'll": 'you will',
    "he'll": 'he will',
    "she'll": 'she will',
    "it'll": 'it will',
    "they'll": 'they will',
    "i'd": 'i would',
    "we'd": 'we would',
    "you'd": 'you would',
    "he'd": 'he would',
    "she'd": 'she would',
    "they'd": 'they would',
  };

  /// 축약형을 먼저 펼친 뒤 구두점을 제거한다.
  /// (구두점을 먼저 지우면 축약형 치환이 영영 동작하지 않는다)
  static String _normalize(String text) {
    var s = text.toLowerCase();
    _contractions.forEach((k, v) {
      s = s.replaceAll(k, v);
    });
    s = s.replaceAll(RegExp(r"""[.,!?;:'"]+"""), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  static List<String> _tokens(String text) {
    return _normalize(text).split(' ').where((w) => w.isNotEmpty).toList();
  }

  /// 사용자 답과 모범 답안의 단어 일치도.
  /// precision: 사용자가 쓴 단어 중 정답에 있는 비율 (군더더기 감지)
  /// recall:    정답 단어 중 사용자가 쓴 비율 (누락 감지)
  static List<double> _score(List<String> user, List<String> answer) {
    if (user.isEmpty || answer.isEmpty) return [0.0, 0.0];
    final pool = <String, int>{};
    for (final w in answer) {
      pool[w] = (pool[w] ?? 0) + 1;
    }
    int matched = 0;
    for (final w in user) {
      final c = pool[w] ?? 0;
      if (c > 0) {
        pool[w] = c - 1;
        matched++;
      }
    }
    return [matched / user.length, matched / answer.length];
  }

  /// 키워드(구 포함)를 단어 단위로 모두 포함하는지 — 어순은 보지 않는다
  static bool _containsKeywords(List<String> userTokens, List<String> keywords) {
    for (final kw in keywords) {
      for (final part in _tokens(kw)) {
        if (!userTokens.contains(part)) return false;
      }
    }
    return true;
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
      lines.add('🔍 빠진 단어: ' + missing.join(', '));
    }
    if (extra.isNotEmpty && extra.length <= 3) {
      lines.add('✂️ 불필요한 단어: ' + extra.join(', '));
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

    // 1) 완전 일치
    for (int i = 0; i < acceptedAnswers.length; i++) {
      if (normalizedUser == _normalize(acceptedAnswers[i])) {
        final isNatural = i == 0;
        final feedback = isNatural
            ? '완벽해요! 가장 자연스러운 표현이에요. 👍'
            : '맞아요! 참고로 더 자연스러운 표현은:\n"' + best + '"';
        return AnswerResult(
            isCorrect: true, isNatural: isNatural, feedback: feedback);
      }
    }

    // 2) 문장 단위 일치도 평가
    final userTokens = _tokens(userAnswer);
    double bp = 0.0;
    double br = 0.0;
    for (final a in acceptedAnswers) {
      final s = _score(userTokens, _tokens(a));
      if (s[0] + s[1] > bp + br) {
        bp = s[0];
        br = s[1];
      }
    }

    // 2-1) 단어 구성이 사실상 동일 → 어순 문제로 보고 정답 처리
    if (bp >= nearPrecision && br >= nearRecall) {
      return AnswerResult(
        isCorrect: true,
        isNatural: false,
        feedback: '거의 완벽해요! 어순만 다듬으면 돼요.\n모범 답안: "' + best + '"',
      );
    }

    // 2-2) 핵심 키워드를 모두 쓰고 문장 구성도 충분히 맞음
    final keywordsOk =
        keywords.isEmpty || _containsKeywords(userTokens, keywords);
    if (keywordsOk && bp >= minPrecision && br >= minRecall) {
      return AnswerResult(
        isCorrect: true,
        isNatural: false,
        feedback: '좋아요, 뜻은 통해요! 더 자연스러운 표현은:\n"' + best + '"',
      );
    }

    // 3) 오답 — 부분 정답 피드백 포함
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
