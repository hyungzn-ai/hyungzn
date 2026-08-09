import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordEntry {
  final String word;
  final String ko;
  final String pos;
  final String example;

  const WordEntry({
    required this.word,
    required this.ko,
    this.pos = '',
    this.example = '',
  });

  String get display => pos.isEmpty ? word : word + ' (' + pos + ')';
}

/// 빈도순 영단어 풀과 뜻 사전을 관리한다.
class WordService {
  WordService._();
  static final WordService instance = WordService._();

  List<String> _words = [];
  Map<String, dynamic> _meanings = {};
  bool _loaded = false;

  int get total => _words.length;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final wordsRaw = await rootBundle.loadString('assets/data/words.json');
      final wordsJson = jsonDecode(wordsRaw) as Map<String, dynamic>;
      _words = List<String>.from(wordsJson['words'] as List);
    } catch (_) {
      _words = [];
    }
    try {
      final mRaw = await rootBundle.loadString('assets/data/word_meanings.json');
      _meanings = jsonDecode(mRaw) as Map<String, dynamic>;
    } catch (_) {
      _meanings = {};
    }
    _loaded = true;
  }

  WordEntry entryFor(String word) {
    final m = _meanings[word];
    if (m is Map) {
      return WordEntry(
        word: word,
        ko: (m['ko'] ?? '') as String,
        pos: (m['pos'] ?? '') as String,
        example: (m['ex'] ?? '') as String,
      );
    }
    return WordEntry(word: word, ko: '');
  }

  /// 지정한 위치부터 count개를 가져온다 (끝에 도달하면 처음으로 순환)
  List<WordEntry> batchAt(int cursor, int count) {
    if (_words.isEmpty) return [];
    final out = <WordEntry>[];
    for (int i = 0; i < count; i++) {
      final idx = (cursor + i) % _words.length;
      out.add(entryFor(_words[idx]));
    }
    return out;
  }

  // ── 진행 위치 ──────────────────────────────────────────────
  static const _kCursor = 'word_cursor';

  Future<int> loadCursor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kCursor) ?? 0;
  }

  Future<void> saveCursor(int cursor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCursor, cursor);
  }
}
