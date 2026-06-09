import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/monster_data.dart';
import '../models/monster.dart';
import '../widgets/element_icon.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/monster_sprite_widget.dart';
import 'level_select_screen.dart';
import 'vocab_screen.dart';
import 'collection_screen.dart';
import 'review_screen.dart';
import 'settings_screen.dart';
import 'gacha_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const VocabScreen(),
    const CollectionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withOpacity(0.25),
        selectedIndex: _currentIndex,
        height: 62,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '홈'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: '단어 암기'),
          NavigationDestination(icon: Icon(Icons.catching_pokemon), label: '도감'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 홈 탭
// ─────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  int _devTapCount = 0;

  void _onTitleTap(BuildContext context) {
    _devTapCount++;
    if (_devTapCount >= 7) {
      _devTapCount = 0;
      final provider = context.read<AppProvider>();
      provider.toggleDevMode();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.devMode ? '🔧 개발자 모드 활성화!' : '🔧 개발자 모드 비활성화',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: provider.devMode ? Colors.orange : Colors.grey,
        ),
      );
    }
  }

  void _showDevMenu(BuildContext context) {
    final provider = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🔧 개발자 메뉴',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                provider.devAddPoints();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⭐ 포인트 +99999 지급!'), backgroundColor: Colors.amber),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text('포인트 +99999'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                provider.devAddEvolutionPoints();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('💎 진화포인트 +99999 지급!'), backgroundColor: Color(0xFF7EC8E3)),
                );
              },
              icon: const Icon(Icons.diamond),
              label: const Text('진화포인트 +99999'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7EC8E3), foregroundColor: Colors.black),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                await provider.devUnlockAllMonsters();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎉 모든 몬스터 획득!'), backgroundColor: Colors.green),
                  );
                }
              },
              icon: const Icon(Icons.catching_pokemon),
              label: const Text('모든 몬스터 획득'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                provider.toggleDevMode();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('개발자 모드 종료', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final progress = provider.progress;
    final wrongCount = progress.wrongAnswers.length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── 앱바 ───────────────────────────────────────────
          SliverAppBar(
            pinned: false,
            floating: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            titleSpacing: 20,
            title: GestureDetector(
              onTap: () => _onTitleTap(context),
              child: const Text(
                '영작몬',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            actions: [
              if (provider.devMode)
                IconButton(
                  onPressed: () => _showDevMenu(context),
                  icon: const Icon(Icons.build_rounded, color: Colors.orange),
                  tooltip: '개발자 메뉴',
                ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                icon: const Icon(Icons.settings_rounded, color: AppTheme.textSecondary),
                tooltip: '설정',
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── 포인트 / 진화 포인트 칩 ──────────────────
                Row(
                  children: [
                    _PointChip(
                      icon: '⭐',
                      label: '${progress.totalPoints} pt',
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 10),
                    _PointChip(
                      icon: '💎',
                      label: '${progress.evolutionPoints} 진화pt',
                      color: const Color(0xFF7EC8E3),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── 몬스터 파크 ───────────────────────────────
                _MonsterPark(progress: progress),
                const SizedBox(height: 20),

                // ── 오답 복습 배너 ────────────────────────────
                if (wrongCount > 0)
                  _ReviewBanner(wrongCount: wrongCount).animate().fadeIn(duration: 400.ms),

                if (wrongCount > 0) const SizedBox(height: 20),

                // ── 학습 현황 ─────────────────────────────────
                _StatsRow(progress: progress),
                const SizedBox(height: 24),

                // ── 레벨 선택 ─────────────────────────────────
                const Text(
                  '학습 시작',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...['beginner', 'intermediate', 'advanced'].asMap().entries.map((e) {
                  final levelKeys = ['초급', '중급', '고급'];
                  final icons = ['🌱', '🌿', '🌳'];
                  final descs = ['기초 문법과 일상 표현', '중급 문법과 자연스러운 표현', '고급 표현과 원어민 스타일'];
                  final completed = progress.getCompletedCount(e.value);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LevelCard(
                      levelKey: e.value,
                      title: levelKeys[e.key],
                      icon: icons[e.key],
                      description: descs[e.key],
                      completed: completed,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelSelectScreen(
                            level: e.value,
                            levelName: levelKeys[e.key],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 포인트 칩
// ─────────────────────────────────────────────────────────────

class _PointChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  const _PointChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 몬스터 파크
// ─────────────────────────────────────────────────────────────

class _MonsterPark extends StatelessWidget {
  final dynamic progress;
  const _MonsterPark({required this.progress});

  @override
  Widget build(BuildContext context) {
    final allSpecies = MonsterData.allSpecies;
    final ownedSpecies = allSpecies
        .where((s) => (progress.monsters as Map).containsKey(s.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🌿 몬스터 파크',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GachaScreen()),
              ),
              icon: const Text('🥚', style: TextStyle(fontSize: 13)),
              label: const Text(
                '뽑기',
                style: TextStyle(color: AppTheme.accent, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 110,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF40916C), width: 1.5),
          ),
          child: Stack(
            children: [
              // 잔디 느낌 패턴
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: CustomPaint(
                    painter: _GrassPainter(),
                  ),
                ),
              ),
              // 몬스터들
              if (ownedSpecies.isEmpty)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🌱', style: TextStyle(fontSize: 30)),
                      SizedBox(height: 4),
                      Text(
                        '몬스터를 뽑아보세요!',
                        style: TextStyle(
                          color: Color(0xFFB7E4C7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '뽑기 → 100pt',
                        style: TextStyle(color: Color(0xFF74C69D), fontSize: 11),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ownedSpecies.map((species) {
                        final mp = (progress.monsters as Map)[species.id];
                        final stage = (mp?.evolutionStage ?? 0) as int;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _ParkMonsterIcon(
                            species: species,
                            stage: stage,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              // 보유 수 뱃지
              if (ownedSpecies.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${ownedSpecies.length}/${MonsterData.allSpecies.length}',
                      style: const TextStyle(
                        color: Color(0xFFB7E4C7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF52B788).withOpacity(0.25);
    // 간단한 잔디 줄기 효과
    for (double x = 8; x < size.width; x += 18) {
      final path = Path()
        ..moveTo(x, size.height)
        ..quadraticBezierTo(x - 4, size.height - 18, x, size.height - 28)
        ..quadraticBezierTo(x + 4, size.height - 18, x + 2, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ParkMonsterIcon extends StatelessWidget {
  final MonsterSpecies species;
  final int stage;
  const _ParkMonsterIcon({required this.species, required this.stage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 몬스터 스프라이트 원형 프레임
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
              border: species.isHidden
                  ? Border.all(color: Colors.amber, width: 2)
                  : Border.all(color: Colors.white24, width: 1),
            ),
            child: Center(
              child: MonsterSpriteWidget(
                monsterId: species.id,
                stage: stage,
                size: 42,
                fallbackEmoji: species.evolutionEmojis[stage],
              ),
            ),
          ),
          // 속성 아이콘 뱃지 (오른쪽 하단)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              padding: const EdgeInsets.all(1),
              child: ElementIcon(element: species.element, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 오답 복습 배너
// ─────────────────────────────────────────────────────────────

class _ReviewBanner extends StatelessWidget {
  final int wrongCount;
  const _ReviewBanner({required this.wrongCount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReviewScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.secondary.withOpacity(0.25),
              AppTheme.primary.withOpacity(0.25),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('❌', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '틀린 문제 $wrongCount개 복습하기',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    '오답 복습으로 완벽하게 마스터해요!',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.secondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────
// 통계 행
// ─────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final dynamic progress;
  const _StatsRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard('🎯', '총 완료 Day', '${progress.totalCompletedDays}')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard('🌱', '초급 완료', '${progress.getCompletedCount("beginner")}/50')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard('🌿', '중급 완료', '${progress.getCompletedCount("intermediate")}/50')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  const _StatCard(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 레벨 카드 (잠금 없음)
// ─────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final String levelKey, title, icon, description;
  final int completed;
  final VoidCallback onTap;

  const _LevelCard({
    required this.levelKey,
    required this.title,
    required this.icon,
    required this.description,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(description,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completed / 50,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('$completed / 50 day 완료',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
