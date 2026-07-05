import 'package:shared_preferences/shared_preferences.dart';

class MissionDef {
  final String id;
  final String emoji;
  final String title;
  final int goal;
  final int reward;
  const MissionDef(this.id, this.emoji, this.title, this.goal, this.reward);
}

class DailyService {
  static const List<MissionDef> missions = [
    MissionDef('quiz5', '✍️', '영작 문제 5개 풀기', 5, 20),
    MissionDef('day1', '🎯', 'Day 1개 완료하기', 1, 30),
    MissionDef('review3', '🔁', '오답 복습 3개 통과하기', 3, 30),
  ];

  final SharedPreferences _prefs;
  int _streak;
  String _lastStudyDate;
  String _missionDate;
  final Map<String, int> _counts;
  Set<String> _claimed;

  DailyService._(this._prefs, this._streak, this._lastStudyDate,
      this._missionDate, this._counts, this._claimed);

  static String _dateStr(DateTime d) {
    final m = d.month < 10 ? '0' + d.month.toString() : d.month.toString();
    final day = d.day < 10 ? '0' + d.day.toString() : d.day.toString();
    return d.year.toString() + '-' + m + '-' + day;
  }

  static String _today() => _dateStr(DateTime.now());
  static String _yesterday() =>
      _dateStr(DateTime.now().subtract(const Duration(days: 1)));

  static Future<DailyService> load() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt('daily_streak') ?? 0;
    final lastStudy = prefs.getString('daily_last_study') ?? '';
    final missionDate = prefs.getString('daily_mission_date') ?? '';
    final counts = <String, int>{};
    for (final m in missions) {
      counts[m.id] = prefs.getInt('daily_count_' + m.id) ?? 0;
    }
    final claimed = (prefs.getStringList('daily_claimed') ?? []).toSet();
    final svc =
        DailyService._(prefs, streak, lastStudy, missionDate, counts, claimed);
    svc._rolloverIfNeeded();
    return svc;
  }

  void _rolloverIfNeeded() {
    final today = _today();
    if (_missionDate != today) {
      _missionDate = today;
      for (final m in missions) {
        _counts[m.id] = 0;
      }
      _claimed = {};
      _save();
    }
  }

  Future<void> _save() async {
    await _prefs.setInt('daily_streak', _streak);
    await _prefs.setString('daily_last_study', _lastStudyDate);
    await _prefs.setString('daily_mission_date', _missionDate);
    for (final m in missions) {
      await _prefs.setInt('daily_count_' + m.id, _counts[m.id] ?? 0);
    }
    await _prefs.setStringList('daily_claimed', _claimed.toList());
  }

  /// 현재 유효한 스트릭 (어제/오늘 학습 기록이 없으면 0)
  int get currentStreak {
    if (_lastStudyDate.isEmpty) return 0;
    if (_lastStudyDate == _today() || _lastStudyDate == _yesterday()) {
      return _streak;
    }
    return 0;
  }

  bool get studiedToday => _lastStudyDate == _today();

  /// Day 완료 시 호출 — 스트릭 갱신 + day1 미션 카운트. 갱신된 스트릭 반환
  int registerDayComplete() {
    _rolloverIfNeeded();
    final today = _today();
    if (_lastStudyDate != today) {
      _streak = (_lastStudyDate == _yesterday()) ? _streak + 1 : 1;
      _lastStudyDate = today;
    }
    _counts['day1'] = (_counts['day1'] ?? 0) + 1;
    _save();
    return _streak;
  }

  void addCount(String id) {
    _rolloverIfNeeded();
    _counts[id] = (_counts[id] ?? 0) + 1;
    _save();
  }

  int countOf(String id) {
    _rolloverIfNeeded();
    return _counts[id] ?? 0;
  }

  bool isClaimed(String id) => _claimed.contains(id);

  bool canClaim(String id) {
    final def = missions.firstWhere((m) => m.id == id);
    return countOf(id) >= def.goal && !isClaimed(id);
  }

  int claim(String id) {
    _rolloverIfNeeded();
    if (!canClaim(id)) return 0;
    final def = missions.firstWhere((m) => m.id == id);
    _claimed.add(id);
    _save();
    return def.reward;
  }
}
