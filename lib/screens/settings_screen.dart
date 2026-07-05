import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
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
                  'v1.0.0',
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

          // ── 진행 관리 ────────────────────────────────────────
          _SectionHeader(label: '진행 관리'),

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
          _InfoRow(icon: '📱', label: '버전', value: '1.0.0'),
          _InfoRow(icon: '🛠️', label: '개발', value: '영작몬 팀'),
          _InfoRow(icon: '📚', label: '총 학습 문제', value: '750문제 (3레벨 × 50일 × 5문제)'),
          _InfoRow(icon: '🐾', label: '총 몬스터', value: '12종'),
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
          '이 작업은 되돌릴 수 없습니다. 정말 초기화하시겠어요?',
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
