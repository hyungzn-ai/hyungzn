import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/vocab_item.dart';

class VocabLoader {
  static List<VocabSet>? _cached;

  static Future<List<VocabSet>> loadAll() async {
    if (_cached != null) return _cached!;
    final jsonStr = await rootBundle.loadString('assets/data/vocab.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    _cached = jsonList.map((e) => _parseVocabSet(e as Map<String, dynamic>)).toList();
    return _cached!;
  }

  static Future<List<VocabSet>> loadByLevel(String level) async {
    final all = await loadAll();
    return all.where((s) => s.level == level).toList();
  }

  static void clearCache() => _cached = null;

  static VocabSet _parseVocabSet(Map<String, dynamic> json) {
    final setNumber = json['setNumber'] as int;
    final items = (json['items'] as List).asMap().entries.map((entry) {
      final item = entry.value as Map<String, dynamic>;
      final english = item['english'] as String;
      // ID: setNumber_index 로 안정적 생성
      final id = '${setNumber}_${entry.key}';
      return VocabItem(
        id: id,
        english: english,
        korean: item['korean'] as String,
        example: item['example'] as String,
        exampleKorean: item['exampleKorean'] as String,
        type: item['type'] as String? ?? '표현',
      );
    }).toList();

    return VocabSet(
      setNumber: setNumber,
      title: json['title'] as String,
      level: json['level'] as String? ?? 'beginner',
      items: items,
    );
  }
}
