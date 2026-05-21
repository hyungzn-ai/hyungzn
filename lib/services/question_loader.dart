import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionLoader {
  // 캐시: 한 번 로드한 파일은 메모리에 유지
  static final Map<String, List<DayData>> _cache = {};

  static String _levelKey(String level) {
    switch (level) {
      case 'beginner':
        return 'beginner';
      case 'intermediate':
        return 'intermediate';
      case 'advanced':
        return 'advanced';
      default:
        return 'beginner';
    }
  }

  static String _batchFileName(int day) {
    // 1~10 → days_01_10, 11~20 → days_11_20, ...
    final start = ((day - 1) ~/ 10) * 10 + 1;
    final end = start + 9;
    final s = start.toString().padLeft(2, '0');
    final e = end.toString().padLeft(2, '0');
    return 'days_${s}_$e';
  }

  static Future<DayData?> loadDay(String level, int day) async {
    final batchKey = '${level}_${_batchFileName(day)}';

    // 이미 캐시에 있으면 바로 반환
    if (_cache.containsKey(batchKey)) {
      return _cache[batchKey]!.firstWhere(
        (d) => d.day == day,
        orElse: () => DayData(day: day, topic: '', questions: []),
      );
    }

    // JSON 파일 로드
    try {
      final fileName = _batchFileName(day);
      final levelKey = _levelKey(level);
      final path = 'assets/data/$levelKey/$fileName.json';
      final jsonStr = await rootBundle.loadString(path);
      final List<dynamic> jsonList = jsonDecode(jsonStr);

      final days = jsonList.map((e) => _parseDayData(e)).toList();
      _cache[batchKey] = days;

      return days.firstWhere(
        (d) => d.day == day,
        orElse: () => DayData(day: day, topic: '', questions: []),
      );
    } catch (e) {
      return null;
    }
  }

  static DayData _parseDayData(Map<String, dynamic> json) {
    final questions = (json['questions'] as List).map((q) {
      return Question(
        korean: q['korean'] as String,
        answers: List<String>.from(q['answers']),
        hint: q['hint'] as String,
        explanation: q['explanation'] as String? ?? '',
        keywords: List<String>.from(q['keywords'] ?? []),
      );
    }).toList();

    return DayData(
      day: json['day'] as int,
      topic: json['topic'] as String,
      questions: questions,
    );
  }

  static void clearCache() => _cache.clear();
}
