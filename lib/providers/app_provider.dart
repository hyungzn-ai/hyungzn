import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/monster.dart';
import '../models/wrong_answer.dart';
import '../services/storage_service.dart';
import '../services/daily_service.dart';
import '../services/github_sync_service.dart';
import '../services/notification_service.dart';
import '../services/word_service.dart';
import '../data/monster_data.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class AppProvider extends ChangeNotifier {
  late StorageService _storage;
  late UserProgress _progress;
  bool _isLoaded = false;
  bool _devMode = false;
  String _quizMode = 'write'; // 'write' | 'arrange' | 'mixed'
  bool _wordAlarmOn = false;
  int _wordAlarmHour = 8;
  int _wordAlarmMinute = 0;
  int _wordsPerDay = 10;
  Set<String> _wordLevels = {'B1', 'B2', 'C1'};
  String _syncStatus = '';
  int _themeIndex = 0;
  late DailyService daily;

  UserProgress get progress => _progress;
  bool get isLoaded => _isLoaded;
  bool get devMode => _devMode;
  String get quizMode => _quizMode;
  bool get wordAlarmOn => _wordAlarmOn;
  int get wordAlarmHour => _wordAlarmHour;
  int get wordAlarmMinute => _wordAlarmMinute;
  int get wordsPerDay => _wordsPerDay;
  Set<String> get wordLevels => _wordLevels;
  String get syncStatus => _syncStatus;
  bool get kakaoLinked => GithubSyncService.instance.hasToken;
  String get lastSync => GithubSyncService.instance.lastSync;
  int get wordTotal => WordService.instance.countForLevels(_wordLevels);

  /// Day 통과 기준 (5문제 중 정답 수)
  static const int dayPassCorrect = 2;
  /// 이미 완료한 Day 재도전 시 보상 비율
  static const double replayRewardRate = 0.3;
  /// Day 완료 시 지급되는 진화 포인트
  static const int evolutionPointsPerDay = 15;
  static const int evolutionPointsPerReplay = 5;
  int get themeIndex => _themeIndex;
  ThemeData get currentTheme => AppTheme.buildTheme(AppTheme.allThemes[_themeIndex]);

  Future<void> setThemeIndex(int index) async {
    _themeIndex = index.clamp(0, AppTheme.allThemes.length - 1);
    AppTheme.setTheme(_themeIndex);
    await _storage.saveThemeIndex(_themeIndex);
    notifyListeners();
  }

  void toggleDevMode() => setDevMode(!_devMode);

  /// 개발자 모드: 포인트 무한 사용 + 모든 Day 오픈
  Future<void> setDevMode(bool on) async {
    _devMode = on;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dev_mode', on);
    notifyListeners();
  }

  /// 퀴즈 학습 모드 설정
  Future<void> setQuizMode(String mode) async {
    _quizMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quiz_mode', mode);
    notifyListeners();
  }

  void devAddPoints() {
    _progress.totalPoints += 99999;
    _storage.saveProgress(_progress);
    notifyListeners();
  }

  void devAddEvolutionPoints() {
    _progress.evolutionPoints += 99999;
    _storage.saveProgress(_progress);
    notifyListeners();
  }

  Future<void> devUnlockAllMonsters() async {
    for (final species in MonsterData.allSpecies) {
      if (!_progress.monsters.containsKey(species.id)) {
        _progress.monsters[species.id] = UserMonsterProgress();
      }
    }
    await _storage.saveProgress(_progress);
    notifyListeners();
  }

  Future<void> init() async {
    _storage = await StorageService.create();
    _progress = await _storage.loadProgress();
    _themeIndex = await _storage.loadThemeIndex();
    daily = await DailyService.load();
    final prefs = await SharedPreferences.getInstance();
    _devMode = prefs.getBool('dev_mode') ?? false;
    _quizMode = prefs.getString('quiz_mode') ?? 'write';
    _wordAlarmOn = prefs.getBool('word_alarm_on') ?? false;
    _wordAlarmHour = prefs.getInt('word_alarm_hour') ?? 8;
    _wordAlarmMinute = prefs.getInt('word_alarm_minute') ?? 0;
    _wordsPerDay = prefs.getInt('words_per_day') ?? 10;
    final savedLevels = prefs.getStringList('word_levels');
    if (savedLevels != null && savedLevels.isNotEmpty) {
      _wordLevels = savedLevels.toSet();
    }
    await WordService.instance.load();
    await GithubSyncService.instance.load();
    if (_wordAlarmOn) {
      // 앱을 열 때마다 앞으로 14일치 알림을 다시 채워둔다
      unawaited(rescheduleWordAlarms());
    }
    AppTheme.setTheme(_themeIndex);

    // 첫 실행 시 기본 몬스터 지급
    if (_progress.monsters.isEmpty) {
      _progress.monsters['flameling'] = UserMonsterProgress(points: 0, evolutionStage: 0);
      await _storage.saveProgress(_progress);
    }

    _isLoaded = true;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Day 완료 처리 (진화 자동처리 제거 — 진화 포인트 방식으로 전환)
  // ─────────────────────────────────────────────────────────────
  Future<DayCompleteResult> completeDay({
    required String level,
    required int day,
    required int correctCount,
  }) async {
    final alreadyCompleted = _progress.isDayCompleted(level, day);
    final passed = correctCount >= dayPassCorrect;

    // 기본 포인트 (통과해야 완료 보너스 지급)
    int dayPoints = (correctCount * AppConstants.pointsCorrectFirst) +
        (passed ? AppConstants.pointsDayComplete : 0);

    // 스트릭·미션은 재도전에도 반영 (완주 후에도 스트릭이 끊기지 않도록)
    final streakAfter = daily.registerDayComplete();
    int streakBonus = (streakAfter > 10 ? 10 : streakAfter) * 2;

    // 이미 완료한 Day는 복습 보상(30%)
    if (alreadyCompleted) {
      dayPoints = (dayPoints * replayRewardRate).round();
      streakBonus = (streakBonus * replayRewardRate).round();
    }
    dayPoints += streakBonus;

    if (passed) {
      _progress.completedDays[level]!.add(day);
      if (!alreadyCompleted) _progress.totalCompletedDays++;
      // 최고 점수만 갱신 (재도전으로 별 등급 개선 가능)
      final prev = _progress.dayScores[level]![day] ?? 0;
      if (correctCount > prev) {
        _progress.dayScores[level]![day] = correctCount;
      }
    }

    final evoGain = alreadyCompleted
        ? evolutionPointsPerReplay
        : evolutionPointsPerDay;
    _progress.evolutionPoints += evoGain;
    _progress.totalPoints += dayPoints;

    final activeId = _progress.activeMonsterSpeciesId;
    _progress.monsters[activeId] ??= UserMonsterProgress();
    _progress.monsters[activeId]!.points += dayPoints;

    await _storage.saveProgress(_progress);
    notifyListeners();

    return DayCompleteResult(
      pointsEarned: dayPoints,
      evolved: false,
      evolvedMonsterName: null,
      unlockedMonster: null,
      totalPoints: _progress.totalPoints,
      streakAfter: streakAfter,
      streakBonus: streakBonus,
      passed: passed,
      evolutionPointsEarned: evoGain,
      alreadyCompleted: alreadyCompleted,
    );
  }

  void setActiveMonster(String speciesId) {
    if (_progress.monsters.containsKey(speciesId)) {
      _progress.activeMonsterSpeciesId = speciesId;
      _storage.saveProgress(_progress);
      notifyListeners();
    }
  }

  Future<void> completeVocabSet(int setNumber) async {
    _progress.completedVocabSets.add(setNumber);
    _progress.totalPoints += 15;
    await _storage.saveProgress(_progress);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // 단어 알아요 / 몰라요 관리
  // ─────────────────────────────────────────────────────────────
  Future<void> markVocab(String vocabId, {required bool isUnknown}) async {
    if (isUnknown) {
      _progress.unknownVocabIds.add(vocabId);
    } else {
      _progress.unknownVocabIds.remove(vocabId);
    }
    await _storage.saveProgress(_progress);
    notifyListeners();
  }

  bool isVocabUnknown(String vocabId) =>
      _progress.unknownVocabIds.contains(vocabId);

  // ─────────────────────────────────────────────────────────────
  // 가챠 시스템
  //
  // 비용: 1회 100pt, 10회 900pt
  // 확률:
  //   히든 몬스터 (무지개/빛/어둠/혼돈/요정) 5종 × 각 3% = 총 15%
  //   일반 몬스터 11종이 나머지 85% 균등 배분 (~7.7%씩)
  // 중복 획득: +50 진화 포인트 지급
  // ─────────────────────────────────────────────────────────────
  static const int gachaCostSingle = 100;
  static const int gachaCost10x = 900;
  static const int gachaDuplicateEvolutionPoints = 100; // 중복 시 진화 포인트 지급
  static const double _hiddenProbability = 0.03; // 히든 몬스터 각 3%

  GachaResult? performGacha({required int count}) {
    final cost = count == 1 ? gachaCostSingle : gachaCost10x;
    if (!_devMode) {
      if (_progress.totalPoints < cost) return null;
      _progress.totalPoints -= cost;
    }

    final rng = Random();
    final commons = MonsterData.commonPool;
    final hiddens = MonsterData.hiddenPool;

    final results = <GachaRollResult>[];
    int evolutionPointsEarned = 0;

    for (int i = 0; i < count; i++) {
      final roll = rng.nextDouble();

      // 히든 판정: 0.00~0.03 → 첫 번째 히든, 0.03~0.06 → 두 번째, …
      MonsterSpecies? hiddenResult;
      double cumulative = 0.0;
      for (final h in hiddens) {
        cumulative += _hiddenProbability;
        if (roll < cumulative) {
          hiddenResult = h;
          _progress.rareGachaCount++;
          break;
        }
      }

      // 최종 결과: 히든 또는 커먼 랜덤
      final pulled = hiddenResult ?? commons[rng.nextInt(commons.length)];

      final isDuplicate = _progress.monsters.containsKey(pulled.id);
      if (isDuplicate) {
        // 중복 → 진화 포인트 지급
        evolutionPointsEarned += gachaDuplicateEvolutionPoints;
      } else {
        _progress.monsters[pulled.id] = UserMonsterProgress();
      }

      results.add(GachaRollResult(species: pulled, isDuplicate: isDuplicate));
    }

    _progress.evolutionPoints += evolutionPointsEarned;
    _progress.totalGachaCount += count;

    _storage.saveProgress(_progress);
    notifyListeners();

    return GachaResult(
      rolls: results,
      evolutionPointsEarned: evolutionPointsEarned,
      costPaid: cost,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 진화 시스템 — 진화 포인트 200 소비
  // ─────────────────────────────────────────────────────────────
  static const int evolutionCost = 150;
  static const int evolutionCostPoints = 250; // 일반 포인트 진화 비용

  bool canEvolveMonster(String speciesId) {
    final mp = _progress.monsters[speciesId];
    if (mp == null) return false;
    return mp.evolutionStage < 5 &&
        (_devMode || _progress.evolutionPoints >= evolutionCost);
  }

  bool canEvolveWithPoints(String speciesId) {
    final mp = _progress.monsters[speciesId];
    if (mp == null) return false;
    return mp.evolutionStage < 5 &&
        (_devMode || _progress.totalPoints >= evolutionCostPoints);
  }

  /// 일반 포인트로 진화
  Future<bool> evolveMonsterWithPoints(String speciesId) async {
    final mp = _progress.monsters[speciesId];
    if (mp == null) return false;
    if (mp.evolutionStage >= 5) return false;
    if (!_devMode) {
      if (_progress.totalPoints < evolutionCostPoints) return false;
      _progress.totalPoints -= evolutionCostPoints;
    }
    mp.evolutionStage++;
    await _storage.saveProgress(_progress);
    notifyListeners();
    return true;
  }

  Future<bool> evolveMonster(String speciesId) async {
    final mp = _progress.monsters[speciesId];
    if (mp == null) return false;
    if (mp.evolutionStage >= 5) return false;
    if (!_devMode) {
      if (_progress.evolutionPoints < evolutionCost) return false;
      _progress.evolutionPoints -= evolutionCost;
    }
    mp.evolutionStage++;

    await _storage.saveProgress(_progress);
    notifyListeners();
    return true;
  }

  UserMonsterProgress? getActiveMonsterProgress() {
    return _progress.monsters[_progress.activeMonsterSpeciesId];
  }

  MonsterSpecies? getActiveMonsterSpecies() {
    return MonsterData.getSpecies(_progress.activeMonsterSpeciesId);
  }

  // ─────────────────────────────────────────────────────────────
  // 틀린 문제 관리
  // ─────────────────────────────────────────────────────────────

  Future<void> addWrongAnswer(WrongAnswer wrong) async {
    final alreadyExists = _progress.wrongAnswers.any((w) => w.key == wrong.key);
    if (!alreadyExists) {
      _progress.wrongAnswers.add(wrong);
      await _storage.saveProgress(_progress);
      notifyListeners();
    }
  }

  Future<void> removeWrongAnswer(String key) async {
    _progress.wrongAnswers.removeWhere((w) => w.key == key);
    await _storage.saveProgress(_progress);
    notifyListeners();
  }

  Future<void> clearWrongAnswers() async {
    _progress.wrongAnswers.clear();
    await _storage.saveProgress(_progress);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // 일일 미션 / 스트릭 훅
  // ─────────────────────────────────────────────────────────────

  Future<void> recordQuizAnswered() async {
    daily.addCount('quiz5');
    notifyListeners();
  }

  Future<void> recordReviewCleared() async {
    daily.addCount('review3');
    notifyListeners();
  }

  Future<int> claimMission(String id) async {
    final reward = daily.claim(id);
    if (reward > 0) {
      _progress.totalPoints += reward;
      await _storage.saveProgress(_progress);
    }
    notifyListeners();
    return reward;
  }

  // ─────────────────────────────────────────────────────────────
  // 오답 간격 반복 (SRS)
  // ─────────────────────────────────────────────────────────────

  /// 오늘 복습 대상 오답 목록
  List<WrongAnswer> get dueWrongAnswers {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _progress.wrongAnswers.where((w) => w.nextReviewAt <= now).toList();
  }

  /// 복습 통과: 단계 승급. 3단계 통과 시 졸업(삭제). 반환값: 졸업 여부
  Future<bool> promoteWrongAnswer(String key) async {
    final idx = _progress.wrongAnswers.indexWhere((w) => w.key == key);
    if (idx < 0) return false;
    final w = _progress.wrongAnswers[idx];
    final newBox = w.box + 1;
    if (newBox >= 3) {
      _progress.wrongAnswers.removeAt(idx);
      await _storage.saveProgress(_progress);
      notifyListeners();
      return true;
    }
    final days = newBox == 1 ? 1 : 3;
    _progress.wrongAnswers[idx] = w.copyWith(
      box: newBox,
      nextReviewAt:
          DateTime.now().add(Duration(days: days)).millisecondsSinceEpoch,
    );
    await _storage.saveProgress(_progress);
    notifyListeners();
    return false;
  }

  /// 복습 실패: 단계 리셋, 내일 다시
  Future<void> demoteWrongAnswer(String key) async {
    final idx = _progress.wrongAnswers.indexWhere((w) => w.key == key);
    if (idx < 0) return;
    final w = _progress.wrongAnswers[idx];
    _progress.wrongAnswers[idx] = w.copyWith(
      box: 0,
      nextReviewAt:
          DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    );
    await _storage.saveProgress(_progress);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // 오늘의 단어 알림
  // ─────────────────────────────────────────────────────────────

  /// 난이도 토글 (최소 하나는 남긴다)
  Future<void> toggleWordLevel(String level) async {
    final next = Set<String>.from(_wordLevels);
    if (next.contains(level)) {
      if (next.length == 1) return; // 전부 끄는 건 막는다
      next.remove(level);
    } else {
      next.add(level);
    }
    _wordLevels = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('word_levels', next.toList());
    // 난이도가 바뀌면 진도를 처음부터
    await WordService.instance.saveCursor(0);
    notifyListeners();
    if (_wordAlarmOn) await rescheduleWordAlarms();
    unawaited(syncKakaoConfig());
  }

  /// GitHub 토큰 저장 후 즉시 한 번 동기화
  Future<String?> linkKakaoConfig(String token) async {
    await GithubSyncService.instance.saveToken(token);
    notifyListeners();
    return syncKakaoConfig();
  }

  Future<void> unlinkKakaoConfig() async {
    await GithubSyncService.instance.clearToken();
    _syncStatus = '';
    notifyListeners();
  }

  /// 현재 난이도·개수를 카톡 발송 설정에 반영
  Future<String?> syncKakaoConfig() async {
    if (!GithubSyncService.instance.hasToken) return null;
    _syncStatus = '동기화 중...';
    notifyListeners();
    final err = await GithubSyncService.instance.pushConfig(
      levels: _wordLevels,
      perDay: _wordsPerDay,
    );
    _syncStatus = err ?? ('카톡 설정 반영됨 · ' + GithubSyncService.instance.lastSync);
    notifyListeners();
    return err;
  }

  Future<void> setWordAlarm({
    bool? on,
    int? hour,
    int? minute,
    int? perDay,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (on != null) {
      _wordAlarmOn = on;
      await prefs.setBool('word_alarm_on', on);
    }
    if (hour != null) {
      _wordAlarmHour = hour;
      await prefs.setInt('word_alarm_hour', hour);
    }
    if (minute != null) {
      _wordAlarmMinute = minute;
      await prefs.setInt('word_alarm_minute', minute);
    }
    if (perDay != null) {
      _wordsPerDay = perDay;
      await prefs.setInt('words_per_day', perDay);
    }
    notifyListeners();

    if (_wordAlarmOn) {
      final granted = await NotificationService.instance.requestPermission();
      if (granted) {
        await rescheduleWordAlarms();
      }
    } else {
      await NotificationService.instance.cancelWordAlarms();
    }

    if (perDay != null) unawaited(syncKakaoConfig());
  }

  /// 현재 위치부터 14일치 단어 묶음을 만들어 알림으로 예약
  Future<void> rescheduleWordAlarms() async {
    final ws = WordService.instance;
    await ws.load();
    if (ws.countForLevels(_wordLevels) == 0) return;

    final cursor = await ws.loadCursor();
    final batches = <String>[];
    for (int d = 0; d < NotificationService.wordDaysAhead; d++) {
      final entries = ws.batchAt(cursor + d * _wordsPerDay, _wordsPerDay,
          levels: _wordLevels);
      final lines = <String>[];
      for (final e in entries) {
        final ko = e.ko.isEmpty ? '(뜻 준비 중)' : e.ko;
        lines.add('• ' + e.display + ' — ' + ko);
      }
      batches.add(lines.join('\n'));
    }

    await NotificationService.instance.scheduleWordAlarms(
      hour: _wordAlarmHour,
      minute: _wordAlarmMinute,
      batches: batches,
    );
  }

  /// 오늘 분량을 확인했으면 다음 단어로 진도를 넘긴다
  Future<void> advanceWordCursor() async {
    final ws = WordService.instance;
    final cursor = await ws.loadCursor();
    await ws.saveCursor(cursor + _wordsPerDay);
    await rescheduleWordAlarms();
    notifyListeners();
  }

  Future<List<WordEntry>> todaysWords() async {
    final ws = WordService.instance;
    await ws.load();
    final cursor = await ws.loadCursor();
    return ws.batchAt(cursor, _wordsPerDay, levels: _wordLevels);
  }

  // ─────────────────────────────────────────────────────────────
  // 백업 / 복원
  // ─────────────────────────────────────────────────────────────

  String exportProgress() => _storage.exportJson(_progress);

  Future<bool> importProgress(String raw) async {
    final restored = await _storage.importJson(raw);
    if (restored == null) return false;
    _progress = restored;
    notifyListeners();
    return true;
  }

  // ─────────────────────────────────────────────────────────────
  // 진행 초기화
  // ─────────────────────────────────────────────────────────────
  Future<void> resetProgress() async {
    await _storage.resetAll();
    _progress = UserProgress();
    _progress.monsters['flameling'] = UserMonsterProgress();
    await _storage.saveProgress(_progress);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────
// 결과 클래스들
// ─────────────────────────────────────────────────────────────

class DayCompleteResult {
  final int pointsEarned;
  final bool evolved;
  final String? evolvedMonsterName;
  final String? unlockedMonster;
  final int totalPoints;
  final int streakAfter; // 완료 후 연속 학습 일수
  final int streakBonus; // 스트릭 보너스 포인트
  final bool passed; // 통과 여부 (다음 Day 해금 기준)
  final int evolutionPointsEarned; // 획득한 진화 포인트
  final bool alreadyCompleted; // 재도전 여부

  const DayCompleteResult({
    required this.pointsEarned,
    required this.evolved,
    this.evolvedMonsterName,
    this.unlockedMonster,
    required this.totalPoints,
    this.streakAfter = 0,
    this.streakBonus = 0,
    this.passed = true,
    this.evolutionPointsEarned = 0,
    this.alreadyCompleted = false,
  });
}

class GachaRollResult {
  final MonsterSpecies species;
  final bool isDuplicate;
  const GachaRollResult({required this.species, required this.isDuplicate});
}

class GachaResult {
  final List<GachaRollResult> rolls;
  final int evolutionPointsEarned; // 중복으로 획득한 진화 포인트
  final int costPaid;

  const GachaResult({
    required this.rolls,
    required this.evolutionPointsEarned,
    required this.costPaid,
  });

  bool get hasHidden => rolls.any((r) => r.species.rarity == MonsterRarity.hidden);
  List<GachaRollResult> get newMonsters => rolls.where((r) => !r.isDuplicate).toList();
}
