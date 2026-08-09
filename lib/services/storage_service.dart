import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/wrong_answer.dart';

class StorageService {
  static const _keyTotalPoints = 'total_points';
  static const _keyEvolutionPoints = 'evolution_points';
  static const _keyCompletedDays = 'completed_days';
  static const _keyDayScores = 'day_scores';
  static const _keyTotalCompletedDays = 'total_completed_days';
  static const _keyMonsters = 'monsters';
  static const _keyActiveMonster = 'active_monster';
  static const _keyCompletedVocabSets = 'completed_vocab_sets';
  static const _keyUnknownVocabIds = 'unknown_vocab_ids';
  static const _keyTotalGachaCount = 'total_gacha_count';
  static const _keyRareGachaCount = 'rare_gacha_count';
  static const _keyWrongAnswers = 'wrong_answers';
  static const _keyThemeIndex = 'theme_index';

  /// 진행 초기화 시 지울 키 (테마/알림/온보딩 설정은 보존)
  static const List<String> _progressKeys = [
    _keyTotalPoints,
    _keyEvolutionPoints,
    _keyCompletedDays,
    _keyDayScores,
    _keyTotalCompletedDays,
    _keyMonsters,
    _keyActiveMonster,
    _keyCompletedVocabSets,
    _keyUnknownVocabIds,
    _keyTotalGachaCount,
    _keyRareGachaCount,
    _keyWrongAnswers,
  ];

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ── 안전 파서 ──────────────────────────────────────────────
  static Map<String, Set<int>> _decodeCompletedDays(String? raw) {
    final result = <String, Set<int>>{
      'beginner': <int>{},
      'intermediate': <int>{},
      'advanced': <int>{},
    };
    if (raw == null) return result;
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      decoded.forEach((key, value) {
        result[key] = Set<int>.from((value as List).map((e) => e as int));
      });
    } catch (_) {
      // 손상된 데이터는 무시하고 기본값 유지 (앱이 죽지 않도록)
    }
    return result;
  }

  static Map<String, Map<int, int>> _decodeDayScores(String? raw) {
    final result = <String, Map<int, int>>{
      'beginner': <int, int>{},
      'intermediate': <int, int>{},
      'advanced': <int, int>{},
    };
    if (raw == null) return result;
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      decoded.forEach((levelKey, value) {
        final Map<String, dynamic> scoreMap = value as Map<String, dynamic>;
        result[levelKey] =
            scoreMap.map((k, v) => MapEntry(int.parse(k), v as int));
      });
    } catch (_) {}
    return result;
  }

  static Map<String, UserMonsterProgress> _decodeMonsters(String? raw) {
    final result = <String, UserMonsterProgress>{};
    if (raw == null) return result;
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      decoded.forEach((key, value) {
        result[key] =
            UserMonsterProgress.fromJson(value as Map<String, dynamic>);
      });
    } catch (_) {}
    return result;
  }

  static List<WrongAnswer> _decodeWrongAnswers(String? raw) {
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((e) => WrongAnswer.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Set<int> _decodeIntSet(List<String>? raw) {
    if (raw == null) return <int>{};
    final out = <int>{};
    for (final s in raw) {
      final v = int.tryParse(s);
      if (v != null) out.add(v);
    }
    return out;
  }

  Future<UserProgress> loadProgress() async {
    return UserProgress(
      totalPoints: _prefs.getInt(_keyTotalPoints) ?? 0,
      evolutionPoints: _prefs.getInt(_keyEvolutionPoints) ?? 0,
      completedDays: _decodeCompletedDays(_prefs.getString(_keyCompletedDays)),
      dayScores: _decodeDayScores(_prefs.getString(_keyDayScores)),
      totalCompletedDays: _prefs.getInt(_keyTotalCompletedDays) ?? 0,
      monsters: _decodeMonsters(_prefs.getString(_keyMonsters)),
      activeMonsterSpeciesId:
          _prefs.getString(_keyActiveMonster) ?? 'flameling',
      completedVocabSets:
          _decodeIntSet(_prefs.getStringList(_keyCompletedVocabSets)),
      unknownVocabIds:
          Set<String>.from(_prefs.getStringList(_keyUnknownVocabIds) ?? []),
      totalGachaCount: _prefs.getInt(_keyTotalGachaCount) ?? 0,
      rareGachaCount: _prefs.getInt(_keyRareGachaCount) ?? 0,
      wrongAnswers: _decodeWrongAnswers(_prefs.getString(_keyWrongAnswers)),
    );
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _prefs.setInt(_keyTotalPoints, progress.totalPoints);
    await _prefs.setInt(_keyEvolutionPoints, progress.evolutionPoints);
    await _prefs.setInt(_keyTotalCompletedDays, progress.totalCompletedDays);
    await _prefs.setString(_keyActiveMonster, progress.activeMonsterSpeciesId);

    final completedDaysMap = progress.completedDays.map(
      (key, value) => MapEntry(key, value.toList()),
    );
    await _prefs.setString(_keyCompletedDays, jsonEncode(completedDaysMap));

    final dayScoresMap = progress.dayScores.map(
      (levelKey, scoreMap) =>
          MapEntry(levelKey, scoreMap.map((k, v) => MapEntry(k.toString(), v))),
    );
    await _prefs.setString(_keyDayScores, jsonEncode(dayScoresMap));

    final monstersMap = progress.monsters.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _prefs.setString(_keyMonsters, jsonEncode(monstersMap));

    await _prefs.setStringList(
      _keyCompletedVocabSets,
      progress.completedVocabSets.map((e) => e.toString()).toList(),
    );
    await _prefs.setStringList(
      _keyUnknownVocabIds,
      progress.unknownVocabIds.toList(),
    );

    await _prefs.setInt(_keyTotalGachaCount, progress.totalGachaCount);
    await _prefs.setInt(_keyRareGachaCount, progress.rareGachaCount);

    final wrongList = progress.wrongAnswers.map((w) => w.toJson()).toList();
    await _prefs.setString(_keyWrongAnswers, jsonEncode(wrongList));
  }

  Future<int> loadThemeIndex() async => _prefs.getInt(_keyThemeIndex) ?? 0;
  Future<void> saveThemeIndex(int index) async =>
      await _prefs.setInt(_keyThemeIndex, index);

  /// 진행 데이터만 삭제 (테마·알림·온보딩 설정은 유지)
  Future<void> resetAll() async {
    for (final k in _progressKeys) {
      await _prefs.remove(k);
    }
    final dailyKeys =
        _prefs.getKeys().where((k) => k.startsWith('daily_')).toList();
    for (final k in dailyKeys) {
      await _prefs.remove(k);
    }
  }

  // ── 백업 / 복원 ────────────────────────────────────────────

  String exportJson(UserProgress p) {
    return jsonEncode({
      'app': 'writemon',
      'v': 1,
      'savedAt': DateTime.now().toIso8601String(),
      'totalPoints': p.totalPoints,
      'evolutionPoints': p.evolutionPoints,
      'totalCompletedDays': p.totalCompletedDays,
      'activeMonster': p.activeMonsterSpeciesId,
      'completedDays':
          p.completedDays.map((k, v) => MapEntry(k, v.toList())),
      'dayScores': p.dayScores.map((k, m) =>
          MapEntry(k, m.map((a, b) => MapEntry(a.toString(), b)))),
      'monsters': p.monsters.map((k, v) => MapEntry(k, v.toJson())),
      'completedVocabSets': p.completedVocabSets.toList(),
      'unknownVocabIds': p.unknownVocabIds.toList(),
      'totalGachaCount': p.totalGachaCount,
      'rareGachaCount': p.rareGachaCount,
      'wrongAnswers': p.wrongAnswers.map((w) => w.toJson()).toList(),
    });
  }

  Future<UserProgress?> importJson(String raw) async {
    try {
      final j = jsonDecode(raw.trim()) as Map<String, dynamic>;
      if (j['app'] != 'writemon') return null;

      final completedDays = <String, Set<int>>{
        'beginner': <int>{},
        'intermediate': <int>{},
        'advanced': <int>{},
      };
      (j['completedDays'] as Map<String, dynamic>).forEach((k, v) {
        completedDays[k] = Set<int>.from((v as List).map((e) => e as int));
      });

      final dayScores = <String, Map<int, int>>{
        'beginner': <int, int>{},
        'intermediate': <int, int>{},
        'advanced': <int, int>{},
      };
      (j['dayScores'] as Map<String, dynamic>).forEach((k, v) {
        dayScores[k] = (v as Map<String, dynamic>)
            .map((a, b) => MapEntry(int.parse(a), b as int));
      });

      final monsters = <String, UserMonsterProgress>{};
      (j['monsters'] as Map<String, dynamic>).forEach((k, v) {
        monsters[k] = UserMonsterProgress.fromJson(v as Map<String, dynamic>);
      });

      final progress = UserProgress(
        totalPoints: j['totalPoints'] as int? ?? 0,
        evolutionPoints: j['evolutionPoints'] as int? ?? 0,
        completedDays: completedDays,
        dayScores: dayScores,
        totalCompletedDays: j['totalCompletedDays'] as int? ?? 0,
        monsters: monsters,
        activeMonsterSpeciesId: j['activeMonster'] as String? ?? 'flameling',
        completedVocabSets:
            Set<int>.from((j['completedVocabSets'] as List? ?? []).map((e) => e as int)),
        unknownVocabIds: Set<String>.from(
            (j['unknownVocabIds'] as List? ?? []).map((e) => e as String)),
        totalGachaCount: j['totalGachaCount'] as int? ?? 0,
        rareGachaCount: j['rareGachaCount'] as int? ?? 0,
        wrongAnswers: (j['wrongAnswers'] as List? ?? [])
            .map((e) => WrongAnswer.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      await saveProgress(progress);
      return progress;
    } catch (_) {
      return null;
    }
  }
}
