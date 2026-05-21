import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../models/monster.dart';
import '../models/wrong_answer.dart';
import '../services/storage_service.dart';
import '../data/monster_data.dart';
import '../utils/constants.dart';

class AppProvider extends ChangeNotifier {
  late StorageService _storage;
  late UserProgress _progress;
  bool _isLoaded = false;
  bool _devMode = false;

  UserProgress get progress => _progress;
  bool get isLoaded => _isLoaded;
  bool get devMode => _devMode;

  void toggleDevMode() {
    _devMode = !_devMode;
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

    final dayPoints = (correctCount * AppConstants.pointsCorrectFirst) +
        AppConstants.pointsDayComplete;

    _progress.completedDays[level]!.add(day);
    if (!alreadyCompleted) {
      _progress.totalCompletedDays++;
      _progress.totalPoints += dayPoints;
      _progress.dayScores[level]![day] = correctCount;

      // 활성 몬스터 포인트 누적 (참고용, 진화는 진화 포인트로 수동 실행)
      final activeId = _progress.activeMonsterSpeciesId;
      _progress.monsters[activeId] ??= UserMonsterProgress();
      _progress.monsters[activeId]!.points += dayPoints;
    }

    await _storage.saveProgress(_progress);
    notifyListeners();

    return DayCompleteResult(
      pointsEarned: alreadyCompleted ? 0 : dayPoints,
      evolved: false,
      evolvedMonsterName: null,
      unlockedMonster: null,
      totalPoints: _progress.totalPoints,
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
  //   히든 몬스터 (환상/무지개/빛/어둠/혼돈/우주/요정) 7종 × 각 3% = 총 21%
  //   일반 몬스터 18종이 나머지 79% 균등 배분 (~4.4%씩)
  // 중복 획득: +50 진화 포인트 지급
  // ─────────────────────────────────────────────────────────────
  static const int gachaCostSingle = 100;
  static const int gachaCost10x = 900;
  static const int gachaDuplicateEvolutionPoints = 50; // 중복 시 진화 포인트 지급
  static const double _hiddenProbability = 0.03; // 히든 몬스터 각 3%

  GachaResult? performGacha({required int count}) {
    final cost = count == 1 ? gachaCostSingle : gachaCost10x;
    if (_progress.totalPoints < cost) return null;

    _progress.totalPoints -= cost;

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
  static const int evolutionCost = 200;

  bool canEvolveMonster(String speciesId) {
    final mp = _progress.monsters[speciesId];
    if (mp == null) return false;
    return mp.evolutionStage < 5 && _progress.evolutionPoints >= evolutionCost;
  }

  Future<bool> evolveMonster(String speciesId) async {
    final mp = _progress.monsters[speciesId];
    if (mp == null) return false;
    if (mp.evolutionStage >= 5) return false;
    if (_progress.evolutionPoints < evolutionCost) return false;

    _progress.evolutionPoints -= evolutionCost;
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

  const DayCompleteResult({
    required this.pointsEarned,
    required this.evolved,
    this.evolvedMonsterName,
    this.unlockedMonster,
    required this.totalPoints,
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
