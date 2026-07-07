import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';

class DayCompleteScreen extends StatefulWidget {
  final String level;
  final int day;
  final int correctCount;
  final int totalCount;
  final DayCompleteResult result;
  final String mode;

  const DayCompleteScreen({
    super.key,
    required this.level,
    required this.day,
    required this.correctCount,
    required this.totalCount,
    required this.result,
    this.mode = 'write',
  });

  @override
  State<DayCompleteScreen> createState() => _DayCompleteScreenState();
}

class _DayCompleteScreenState extends State<DayCompleteScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (widget.correctCount >= widget.totalCount * 0.6) {
        _confetti.play();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _gradeEmoji {
    final ratio = widget.correctCount / widget.totalCount;
    if (ratio >= 1.0) return '🏆';
    if (ratio >= 0.8) return '🌟';
    if (ratio >= 0.6) return '👍';
    if (ratio >= 0.4) return '💪';
    return '📚';
  }

  String get _gradeMessage {
    final ratio = widget.correctCount / widget.totalCount;
    if (ratio >= 1.0) return '완벽해요!';
    if (ratio >= 0.8) return '훌륭해요!';
    if (ratio >= 0.6) return '잘했어요!';
    if (ratio >= 0.4) return '조금 더 연습해요!';
    return '다시 도전해봐요!';
  }

  String _levelName(String level) {
    switch (level) {
      case 'beginner': return '초급';
      case 'intermediate': return '중급';
      case 'advanced': return '고급';
      default: return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.correctCount / widget.totalCount;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 그라디언트
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.surface, AppTheme.background],
              ),
            ),
          ),

          // 컨페티
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: [
                AppTheme.primary,
                AppTheme.accent,
                AppTheme.success,
                Colors.pink,
                Colors.cyan,
              ],
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 완료 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
                    ),
                    child: Text(
                      '${_levelName(widget.level)} · Day ${widget.day} 완료!',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 32),

                  // 큰 이모지
                  Text(
                    _gradeEmoji,
                    style: const TextStyle(fontSize: 80),
                  ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 16),

                  // 메시지
                  Text(
                    _gradeMessage,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  // 점수 카드
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // 정답률 원형
                        _CircleScore(ratio: ratio, correct: widget.correctCount, total: widget.totalCount),
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 16),
                        // 포인트 획득
                        if (widget.result.pointsEarned > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                '+${widget.result.pointsEarned} 포인트 획득!',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '총 ${widget.result.totalPoints} 포인트',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                          if (widget.result.streakAfter > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.secondary.withOpacity(0.4)),
                              ),
                              child: Text(
                                '🔥 ' +
                                    widget.result.streakAfter.toString() +
                                    '일 연속 학습 중!' +
                                    (widget.result.streakBonus > 0
                                        ? ' (보너스 +' +
                                            widget.result.streakBonus.toString() +
                                            'pt)'
                                        : ''),
                                style: TextStyle(
                                  color: AppTheme.secondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ] else
                          Text(
                            '이미 완료한 Day입니다',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),

                  // 몬스터 진화 이벤트
                  if (widget.result.evolved && widget.result.evolvedMonsterName != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B4FD4), Color(0xFFFF6B6B)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '몬스터가 진화했어요!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${widget.result.evolvedMonsterName}(으)로 진화!',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                    ),

                  // 새 몬스터 해금
                  if (widget.result.unlockedMonster != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF06D6A0), Color(0xFF1E90FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text('🎁', style: TextStyle(fontSize: 32)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '새 몬스터 해금!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '도감에서 확인해보세요!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],

                  const SizedBox(height: 40),

                  // 버튼들
                  if (widget.day < 50) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                level: widget.level,
                                day: widget.day + 1,
                                mode: widget.mode,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          '➡️ 다음 Day ' + (widget.day + 1).toString() + ' 바로 시작!',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('홈으로 돌아가기', style: TextStyle(fontSize: 17)),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: BorderSide(color: AppTheme.textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Day 목록으로', style: TextStyle(fontSize: 16)),
                    ),
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleScore extends StatelessWidget {
  final double ratio;
  final int correct;
  final int total;

  const _CircleScore({required this.ratio, required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio >= 0.8 ? AppTheme.success : ratio >= 0.5 ? AppTheme.accent : AppTheme.error,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$correct / $total',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '정답',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
