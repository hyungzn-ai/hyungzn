import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/monster_sprite_widget.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen>
    with TickerProviderStateMixin {
  GachaResult? _lastResult;
  bool _isRolling = false;
  bool _showResult = false;

  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _doGacha(int count) async {
    final provider = context.read<AppProvider>();
    final result = provider.performGacha(count: count);
    if (result == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('포인트가 부족해요!'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isRolling = true;
      _showResult = false;
    });

    await _shakeCtrl.forward();
    _shakeCtrl.reset();
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _lastResult = result;
      _isRolling = false;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pts = provider.progress.totalPoints;
    final evoPts = provider.progress.evolutionPoints;
    final can1 = pts >= AppProvider.gachaCostSingle;
    final can10 = pts >= AppProvider.gachaCost10x;

    return Scaffold(
      appBar: AppBar(title: const Text('몬스터 뽑기')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── 포인트 표시 ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(
                            '$pts pt',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(
                            '$evoPts 진화pt',
                            style: const TextStyle(
                              color: Color(0xFF7EC8E3),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── 가챠 알 이미지 ───────────────────────────────
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  final shake = _isRolling
                      ? (math.sin(_shakeCtrl.value * 6 * math.pi) * 12)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.8),
                        AppTheme.surface,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isRolling ? '✨' : '🥚',
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                '뽑기를 통해 새로운 몬스터를 만나세요!',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // 확률 정보
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '✨ 히든 4종(환상·무지개·빛·어둠) 각 3%\n'
                  '일반 18종 균등 확률 (~4.9%씩)\n'
                  '중복 획득 시 💎 진화 포인트 50 지급',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // ── 뽑기 버튼 ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (!_isRolling && can1) ? () => _doGacha(1) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Column(
                        children: [
                          Text('1회 뽑기',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('100 pt',
                              style: TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (!_isRolling && can10) ? () => _doGacha(10) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Column(
                        children: [
                          Text('10회 뽑기',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('900 pt (100 절약)',
                              style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── 뽑기 결과 ──────────────────────────────────
              if (_showResult && _lastResult != null)
                _GachaResultPanel(result: _lastResult!),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 결과 패널
// ─────────────────────────────────────────────────────────────

class _GachaResultPanel extends StatelessWidget {
  final GachaResult result;
  const _GachaResultPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              result.hasHidden ? '✨ 히든 획득!' : '뽑기 결과',
              style: TextStyle(
                color: result.hasHidden ? AppTheme.accent : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (result.evolutionPointsEarned > 0) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7EC8E3).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '💎 +${result.evolutionPointsEarned} 진화pt',
                  style: const TextStyle(color: Color(0xFF7EC8E3), fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: result.rolls.length,
          itemBuilder: (context, i) {
            final roll = result.rolls[i];
            return _RollCard(roll: roll, delay: i * 60);
          },
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _RollCard extends StatelessWidget {
  final GachaRollResult roll;
  final int delay;
  const _RollCard({required this.roll, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isHidden = roll.species.isHidden;
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: isHidden
                ? AppTheme.accent.withOpacity(0.2)
                : AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHidden
                  ? AppTheme.accent.withOpacity(0.8)
                  : roll.isDuplicate
                      ? AppTheme.textSecondary.withOpacity(0.3)
                      : AppTheme.primary.withOpacity(0.5),
              width: isHidden ? 2 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              MonsterSpriteWidget(
                monsterId:     roll.species.id,
                stage:         0,
                size:          52,
                fallbackEmoji: roll.species.evolutionEmojis[0],
              ),
              if (roll.isDuplicate)
                Positioned(
                  bottom: 2,
                  right:  2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DUP',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          roll.species.name,
          style: TextStyle(
            color: isHidden ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: isHidden ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    )
        .animate(delay: Duration(milliseconds: delay))
        .scale(begin: const Offset(0.3, 0.3), curve: Curves.elasticOut)
        .fadeIn();
  }
}
