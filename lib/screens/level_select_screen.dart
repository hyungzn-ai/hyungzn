import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import 'quiz_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  final String level;
  final String levelName;

  const LevelSelectScreen({super.key, required this.level, required this.levelName});

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
              onTap: isUnlocked
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => QuizScreen(level: level, day: day)))
                  : null,
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
                        color: isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
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
