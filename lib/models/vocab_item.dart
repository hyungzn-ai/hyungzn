class VocabSet {
  final int setNumber;
  final String title;
  final String level; // 'beginner' | 'intermediate' | 'advanced'
  final List<VocabItem> items;

  const VocabSet({
    required this.setNumber,
    required this.title,
    required this.level,
    required this.items,
  });
}

class VocabItem {
  final String id; // '{setNumber}_{english}' 형태의 고유 ID
  final String english;
  final String korean;
  final String example; // 예문 (영어)
  final String exampleKorean; // 예문 (한국어)
  final String type; // 단어/구문/표현/이디엄 등

  const VocabItem({
    required this.id,
    required this.english,
    required this.korean,
    required this.example,
    required this.exampleKorean,
    this.type = '표현',
  });
}
