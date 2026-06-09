import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/wrong_answer.dart';

class StorageService {
  static const _keyTotalPoints = 'total_points';
  static const _keyEvolutionPoints = 'evolution_points'; // 진화 포인트
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

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<UserProgress> loadProgress() async {
    final totalPoints = _prefs.getInt(_keyTotalPoints) ?? 0;
    final evolutionPoints = _prefs.getInt(_keyEvolutionPoints) ?? 0;
    final totalCompletedDays = _prefs.getInt(_keyTotalCompletedDays) ?? 0;
    final activeMonster = _prefs.getString(_keyActiveMonster) ?? 'flameling';

    // 완료된 days
    final completedDaysJson = _prefs.getString(_keyCompletedDays);
    Map<String, Set<int>> completedDays = {
      'beginner': {},
      'intermediate': {},
      'advanced': {},
    };
    if (completedDaysJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(completedDaysJson);
      decoded.forEach((key, value) {
        completedDays[key] = Set<int>.from((value as List).map((e) => e as int));
      });
    }

    // day 점수
    final dayScoresJson = _prefs.getString(_keyDayScores);
    Map<String, Map<int, int>> dayScores = {'beginner': {}, 'intermediate': {}, 'advanced': {}};
    if (dayScoresJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(dayScoresJson);
      decoded.forEach((levelKey, value) {
        final Map<String, dynamic> scoreMap = value as Map<String, dynamic>;
        dayScores[levelKey] = scoreMap.map((k, v) => MapEntry(int.parse(k), v as int));
      });
    }

    // 몬스터
    final monstersJson = _prefs.getString(_keyMonsters);
    Map<String, UserMonsterProgress> monsters = {};
    if (monstersJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(monstersJson);
      decoded.forEach((key, value) {
        monsters[key] = UserMonsterProgress.fromJson(value as Map<String, dynamic>);
      });
    }

    // 완료된 단어 세트
    final vocabList = _prefs.getStringList(_keyCompletedVocabSets) ?? [];
    final completedVocabSets = Set<int>.from(vocabList.map(int.parse));

    // 모르는 단어 ID 목록
    final unknownList = _prefs.getStringList(_keyUnknownVocabIds) ?? [];
    final unknownVocabIds = Set<String>.from(unknownList);

    // 가챠 통계
    final totalGachaCount = _prefs.getInt(_keyTotalGachaCount) ?? 0;
    final rareGachaCount = _prefs.getInt(_keyRareGachaCount) ?? 0;

    // 틀린 문제 목록
    final wrongAnswersJson = _prefs.getString(_keyWrongAnswers);
    List<WrongAnswer> wrongAnswers = [];
    if (wrongAnswersJson != null) {
      final List<dynamic> decoded = jsonDecode(wrongAnswersJson);
      wrongAnswers = decoded
          .map((e) => WrongAnswer.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return UserProgress(
      totalPoints: totalPoints,
      evolutionPoints: evolutionPoints,
      completedDays: completedDays,
      dayScores: dayScores,
      totalCompletedDays: totalCompletedDays,
      monsters: monsters,
      activeMonsterSpeciesId: activeMonster,
      completedVocabSets: completedVocabSets,
      unknownVocabIds: unknownVocabIds,
      totalGachaCount: totalGachaCount,
      rareGachaCount: rareGachaCount,
      wrongAnswers: wrongAnswers,
    );
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _prefs.setInt(_keyTotalPoints, progress.totalPoints);
    await _prefs.setInt(_keyEvolutionPoints, progress.evolutionPoints);
    await _prefs.setInt(_keyTotalCompletedDays, progress.totalCompletedDays);
    await _prefs.setString(_keyActiveMonster, progress.activeMonsterSpeciesId);

    // 완료된 days 저장
    final completedDaysMap = progress.completedDays.map(
      (key, value) => MapEntry(key, value.toList()),
    );
    await _prefs.setString(_keyCompletedDays, jsonEncode(completedDaysMap));

    // day 점수 저장
    final dayScoresMap = progress.dayScores.map(
      (levelKey, scoreMap) =>
          MapEntry(levelKey, scoreMap.map((k, v) => MapEntry(k.toString(), v))),
    );
    await _prefs.setString(_keyDayScores, jsonEncode(dayScoresMap));

    // 몬스터 저장
    final monstersMap = progress.monsters.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _prefs.setString(_keyMonsters, jsonEncode(monstersMap));

    // 완료된 단어 세트 저장
    await _prefs.setStringList(
      _keyCompletedVocabSets,
      progress.completedVocabSets.map((e) => e.toString()).toList(),
    );

    // 모르는 단어 ID 저장
    await _prefs.setStringList(
      _keyUnknownVocabIds,
      progress.unknownVocabIds.toList(),
    );

    // 가챠 통계 저장
    await _prefs.setInt(_keyTotalGachaCount, progress.totalGachaCount);
    await _prefs.setInt(_keyRareGachaCount, progress.rareGachaCount);

    // 틀린 문제 저장
    final wrongList = progress.wrongAnswers.map((w) => w.toJson()).toList();
    await _prefs.setString(_keyWrongAnswers, jsonEncode(wrongList));
  }

  Future<int> loadThemeIndex() async => _prefs.getInt(_keyThemeIndex) ?? 0;
  Future<void> saveThemeIndex(int index) async => await _prefs.setInt(_keyThemeIndex, index);

  Future<void> resetAll() async => await _prefs.clear();
}
