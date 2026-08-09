import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/word_service.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final progress = provider.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── 앱 헤더 ────────────────────────────────────────
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text('🏆', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                Text(
                  '영작몬',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'v1.2.0',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // ── 현재 진행 요약 ──────────────────────────────────
          _SectionHeader(label: '내 현황'),
          _InfoRow(
            icon: '🎯',
            label: '완료한 Day',
            value: '${progress.totalCompletedDays}일',
          ),
          _InfoRow(
            icon: '⭐',
            label: '총 포인트',
            value: '${progress.totalPoints} pt',
          ),
          _InfoRow(
            icon: '🐾',
            label: '보유 몬스터',
            value: '${progress.monsters.length}마리',
          ),
          _InfoRow(
            icon: '❌',
            label: '틀린 문제',
            value: '${progress.wrongAnswers.length}개',
          ),
          const SizedBox(height: 24),

          // ── 테마 선택 ────────────────────────────────────────
          _SectionHeader(label: '테마'),
          _ThemePicker(
            currentIndex: provider.themeIndex,
            onChanged: (index) => provider.setThemeIndex(index),
          ),
          const SizedBox(height: 24),

          // ── 학습 설정 ────────────────────────────────────────
          _SectionHeader(label: '학습 설정'),
          _QuizModePicker(
            current: provider.quizMode,
            onChanged: (m) => provider.setQuizMode(m),
          ),
          const SizedBox(height: 24),

          // ── 오늘의 단어 ──────────────────────────────────────
          _SectionHeader(label: '오늘의 단어'),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: provider.wordAlarmOn
                    ? AppTheme.primary.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: provider.wordAlarmOn,
              onChanged: (v) => provider.setWordAlarm(on: v),
              activeColor: AppTheme.primary,
              title: Text(
                '📚 매일 단어 알림',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              subtitle: Text(
                '빈도순 ' + provider.wordTotal.toString() + '개 단어를 매일 조금씩',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
          ),
          _ActionTile(
            icon: Icons.schedule_rounded,
            iconColor: AppTheme.accent,
            title: '받을 시간',
            subtitle: _timeLabel(provider.wordAlarmHour, provider.wordAlarmMinute),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                    hour: provider.wordAlarmHour,
                    minute: provider.wordAlarmMinute),
              );
              if (picked != null) {
                await provider.setWordAlarm(
                    hour: picked.hour, minute: picked.minute);
              }
            },
          ),
          _ActionTile(
            icon: Icons.numbers_rounded,
            iconColor: AppTheme.primary,
            title: '하루 단어 개수',
            subtitle: '현재 ' + provider.wordsPerDay.toString() + '개씩',
            onTap: () => _pickCount(context, provider),
          ),
          _ActionTile(
            icon: Icons.menu_book_rounded,
            iconColor: AppTheme.success,
            title: '오늘의 단어 미리보기',
            subtitle: '지금 순서의 단어를 확인합니다',
            onTap: () => _showTodayWords(context, provider),
          ),
          const SizedBox(height: 24),

          // ── 개발자 모드 ──────────────────────────────────────
          _SectionHeader(label: '개발자'),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: provider.devMode
                    ? Colors.orange.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: provider.devMode,
              onChanged: (v) => provider.setDevMode(v),
              activeColor: Colors.orange,
              title: Text(
                '🔧 개발자 모드',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              subtitle: Text(
                '포인트 무한 사용 + 모든 Day 오픈',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── 진행 관리 ────────────────────────────────────────
          _SectionHeader(label: '진행 관리'),

          // 학습 기록 백업
          _ActionTile(
            icon: Icons.backup_rounded,
            iconColor: AppTheme.primary,
            title: '학습 기록 백업',
            subtitle: '기록을 클립보드에 복사합니다. 메모장 등에 붙여넣어 보관하세요',
            onTap: () async {
              final data = provider.exportProgress();
              await Clipboard.setData(ClipboardData(text: data));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('📋 백업 데이터를 클립보드에 복사했어요!'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),

          // 학습 기록 복원
          _ActionTile(
            icon: Icons.settings_backup_restore_rounded,
            iconColor: AppTheme.accent,
            title: '학습 기록 복원',
            subtitle: '클립보드에 복사해 둔 백업 데이터로 되돌립니다',
            onTap: () => _confirmRestore(context, provider),
          ),

          // 틀린 문제 초기화
          _ActionTile(
            icon: Icons.delete_sweep_rounded,
            iconColor: AppTheme.accent,
            title: '틀린 문제 목록 초기화',
            subtitle: '저장된 오답 ${progress.wrongAnswers.length}개를 모두 삭제합니다',
            onTap: progress.wrongAnswers.isEmpty
                ? null
                : () => _confirmClearWrong(context, provider),
          ),

          // 전체 진행 초기화
          _ActionTile(
            icon: Icons.restore_rounded,
            iconColor: AppTheme.error,
            title: '전체 진행 초기화',
            subtitle: '포인트, 완료 Day, 몬스터 등 모든 데이터가 삭제됩니다',
            onTap: () => _confirmReset(context, provider),
          ),
          const SizedBox(height: 24),

          // ── 앱 정보 ──────────────────────────────────────────
          _SectionHeader(label: '앱 정보'),
          _InfoRow(icon: '📱', label: '버전', value: '1.2.0'),
          _InfoRow(icon: '🛠️', label: '개발', value: '영작몬 팀'),
          _InfoRow(icon: '📚', label: '총 학습 문제', value: '750문제 (3레벨 × 50일 × 5문제)'),
          _InfoRow(icon: '🐾', label: '총 몬스터', value: '16종 (히든 5종)'),
          const SizedBox(height: 24),

          // ── 문의 ─────────────────────────────────────────────
          _SectionHeader(label: '문의 및 피드백'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('📧', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Text(
                      '91618or@gmail.com',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '버그 제보, 기능 제안, 오답 신고 등 언제든지 연락주세요!',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static String _timeLabel(int h, int m) {
    final ampm = h < 12 ? '오전' : '오후';
    var hh = h % 12;
    if (hh == 0) hh = 12;
    final mm = m < 10 ? '0' + m.toString() : m.toString();
    return '매일 ' + ampm + ' ' + hh.toString() + ':' + mm;
  }

  void _pickCount(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Text('하루에 받을 단어 개수',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final n in [5, 10, 20, 30])
              ListTile(
                title: Text(n.toString() + '개',
                    style: TextStyle(
                      color: provider.wordsPerDay == n
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                      fontWeight: provider.wordsPerDay == n
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
                trailing: provider.wordsPerDay == n
                    ? Icon(Icons.check_rounded, color: AppTheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  provider.setWordAlarm(perDay: n);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTodayWords(BuildContext context, AppProvider provider) async {
    final words = await provider.todaysWords();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('오늘의 단어',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final WordEntry e in words)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.display,
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Text(e.ko.isEmpty ? '(뜻 준비 중)' : e.ko,
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.advanceWordCursor();
            },
            child: const Text('다 외웠어요 →'),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('학습 기록 복원',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          '클립보드의 백업 데이터로 현재 기록을 덮어씁니다.\n지금 진행상황은 사라져요. 계속할까요?',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final clip = await Clipboard.getData(Clipboard.kTextPlain);
              final ok = await provider.importProgress(clip?.text ?? '');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? '✅ 학습 기록을 복원했어요!'
                        : '❌ 클립보드에서 올바른 백업 데이터를 찾지 못했어요.'),
                    backgroundColor: ok ? AppTheme.success : AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('복원'),
          ),
        ],
      ),
    );
  }

  void _confirmClearWrong(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '틀린 문제 초기화',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '저장된 오답 ${provider.progress.wrongAnswers.length}개를 모두 삭제할까요?\n이 작업은 되돌릴 수 없습니다.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.clearWrongAnswers();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('오답 목록이 초기화됐습니다.'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('삭제', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text('⚠️', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              '전체 초기화',
              style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '모든 학습 진행상황이 초기화됩니다.\n\n'
          '• 완료한 Day 기록\n'
          '• 획득한 포인트\n'
          '• 해금된 몬스터\n'
          '• 틀린 문제 목록\n\n'
          '테마·알림 설정은 그대로 유지됩니다.\n이 작업은 되돌릴 수 없어요. 정말 초기화할까요?',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.resetProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('진행상황이 초기화됐습니다. 처음부터 시작해요! 💪'),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 공통 위젯
// ─────────────────────────────────────────────────────────────

class _ThemePicker extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  const _ThemePicker({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(AppTheme.allThemes.length, (i) {
        final t = AppTheme.allThemes[i];
        final isSelected = i == currentIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? t.primary.withOpacity(0.18) : AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? t.primary : AppTheme.card,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(t.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    t.name,
                    style: TextStyle(
                      color: isSelected ? t.primary : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 색상 미리보기 도트
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(color: t.primary),
                      const SizedBox(width: 4),
                      _Dot(color: t.secondary),
                      const SizedBox(width: 4),
                      _Dot(color: t.accent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon, label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
          ),
          Text(value,
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onTap != null ? iconColor.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: onTap != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios_rounded,
                    color: iconColor.withOpacity(0.6), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// 퀴즈 모드 선택
// ─────────────────────────────────────────────────────────────

class _QuizModePicker extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _QuizModePicker({required this.current, required this.onChanged});

  static const List<List<String>> _modes = [
    ['write', '✍️', '직접 작문'],
    ['arrange', '🧩', '순서 맞추기'],
    ['mixed', '🎲', '랜덤 믹스'],
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final m in _modes)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m[0]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: current == m[0]
                      ? AppTheme.primary.withOpacity(0.18)
                      : AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: current == m[0] ? AppTheme.primary : AppTheme.card,
                    width: current == m[0] ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(m[1], style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      m[2],
                      style: TextStyle(
                        color: current == m[0]
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: current == m[0]
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
