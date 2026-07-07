import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import 'quiz_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  final String level;
  final String levelName;

  const LevelSelectScreen(
      {super.key, required this.level, required this.levelName});

  void _showModeSheet(BuildContext context, int day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Day $day · 학습 모드 선택',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _modeButton(context, day, 'write', '✍️', '직접 작문',
                  '키보드로 문장 전체를 직접 써요'),
              const SizedBox(height: 10),
              _modeButton(context, day, 'arrange', '🧩', '순서 맞추기',
                  '섞인 단어를 순서대로 탭해서 문장을 완성해요'),
              const SizedBox(height: 10),
              _modeButton(context, day, 'mixed', '🎲', '랜덤 믹스',
                  '직접 작문과 순서 맞추기가 랜덤으로 나와요'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(BuildContext context, int day, String mode, String emoji,
      String title, String desc) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(level: level, day: day, mode: mode),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text(desc,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<AppProvider>().progress;

    return Scaffold(
      appBar: AppBar(
        title: Text('$levelName - Day 선택'),
        backgroundColor: AppTheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 50,
          itemBuilder: (context, index) {
            final day = index + 1;
            final isCompleted = progress.isDayCompleted(level, day);
            final isUnlocked = progress.isDayUnlocked(level, day);
            final score = progress.dayScores[level]?[day];

            return GestureDetector(
              onTap: isUnlocked ? () => _showModeSheet(context, day) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.success.withOpacity(0.2)
                      : isUnlocked
                          ? AppTheme.card
                          : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.success.withOpacity(0.6)
                        : isUnlocked
                            ? AppTheme.primary.withOpacity(0.4)
                            : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCompleted && score != null)
                      Text(_starEmoji(score), style: const TextStyle(fontSize: 12))
                    else if (!isUnlocked)
                      const Text('🔒', style: TextStyle(fontSize: 14))
                    else
                      const SizedBox(height: 14),
                    Text(
                      '$day',
                      style: TextStyle(
                        color: isUnlocked
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _starEmoji(int score) {
    if (score >= 5) return '⭐⭐';
    if (score >= 3) return '⭐';
    return '✓';
  }
}
