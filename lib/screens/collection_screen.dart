import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/monster_data.dart';
import '../models/monster.dart';
import '../models/user_progress.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/monster_sprite_widget.dart';
import 'gacha_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final progress = provider.progress;
    final allSpecies = MonsterData.allSpecies;
    final activeId = progress.activeMonsterSpeciesId;

    final owned = allSpecies.where((s) => progress.monsters.containsKey(s.id)).toList();
    final notOwned = allSpecies.where((s) => !progress.monsters.containsKey(s.id)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더 ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(bottom: BorderSide(color: Color(0xFF2A2A5A), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '몬스터 도감',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${owned.length}',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              ' / ${allSpecies.length} 수집',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 진화 포인트 표시
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF7EC8E3).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          '${progress.evolutionPoints}pt',
                          style: const TextStyle(
                            color: Color(0xFF7EC8E3),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 가챠 버튼
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GachaScreen()),
                    ),
                    icon: const Text('🥚', style: TextStyle(fontSize: 14)),
                    label: const Text('뽑기', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ── 보유 몬스터 ────────────────────────────
                  if (owned.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Text(
                          '보유 몬스터',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.64,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final species = owned[i];
                            final mp = progress.monsters[species.id]!;
                            final isActive = species.id == activeId;
                            return _MonsterCard(
                              species: species,
                              monsterProgress: mp,
                              isActive: isActive,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EvolutionScreen(
                                    speciesId: species.id,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: Duration(milliseconds: i * 40));
                          },
                          childCount: owned.length,
                        ),
                      ),
                    ),
                  ],

                  // ── 미보유 몬스터 (실루엣) ─────────────────
                  if (notOwned.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text(
                          '미수집 몬스터',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.64,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final species = notOwned[i];
                            return _SilhouetteCard(species: species)
                                .animate()
                                .fadeIn(delay: Duration(milliseconds: i * 40));
                          },
                          childCount: notOwned.length,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 보유 몬스터 카드
// ─────────────────────────────────────────────────────────────

class _MonsterCard extends StatelessWidget {
  final MonsterSpecies species;
  final UserMonsterProgress monsterProgress;
  final bool isActive;
  final VoidCallback onTap;

  const _MonsterCard({
    required this.species,
    required this.monsterProgress,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stage = monsterProgress.evolutionStage;
    final isHidden = species.isHidden;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5B4FD4), Color(0xFF0F3460)],
                )
              : null,
          color: isActive ? null : AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: isHidden
              ? Border.all(color: Colors.amber, width: 2.5)
              : Border.all(
                  color: isActive ? AppTheme.primary : AppTheme.primary.withOpacity(0.2),
                  width: isActive ? 2 : 1,
                ),
          boxShadow: isHidden
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            // 히든 뱃지
            if (isHidden)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '✨ HIDDEN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // 활성 뱃지
            if (isActive)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ON',
                    style: TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MonsterSpriteWidget(
                    monsterId: species.id,
                    stage: stage,
                    size: 64,
                    fallbackEmoji: species.evolutionEmojis[stage],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    species.evolutionNames[stage],
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stage + 1}/6단계',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                  ),
                  const SizedBox(height: 3),
                  // 진화 단계 도트
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= stage
                              ? (isHidden ? Colors.amber : AppTheme.primary)
                              : Colors.white24,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 미보유 몬스터 실루엣 카드
// ─────────────────────────────────────────────────────────────

class _SilhouetteCard extends StatelessWidget {
  final MonsterSpecies species;
  const _SilhouetteCard({required this.species});

  @override
  Widget build(BuildContext context) {
    final isHidden = species.isHidden;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isHidden
            ? Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5)
            : Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          // 히든 뱃지 (미보유)
          if (isHidden)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: const Text(
                  '✨ HIDDEN',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 실루엣 스프라이트
                MonsterSpriteWidget(
                  monsterId: species.id,
                  stage: 0,
                  size: 64,
                  fallbackEmoji: species.evolutionEmojis[0],
                  isGrayscale: true,
                ),
                const SizedBox(height: 5),
                Text(
                  isHidden ? '???' : species.name,
                  style: TextStyle(
                    color: isHidden ? Colors.amber.withOpacity(0.5) : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isHidden
                        ? Colors.amber.withOpacity(0.1)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isHidden ? '뽑기 3%' : '뽑기로 획득',
                    style: TextStyle(
                      color: isHidden ? Colors.amber : AppTheme.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 진화 화면 (가로 스와이프)
// ─────────────────────────────────────────────────────────────

class EvolutionScreen extends StatefulWidget {
  final String speciesId;
  const EvolutionScreen({super.key, required this.speciesId});

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen> {
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final mp = provider.progress.monsters[widget.speciesId];
    final initStage = mp?.evolutionStage ?? 0;
    _pageCtrl = PageController(initialPage: initStage, viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final progress = provider.progress;
    final species = MonsterData.getSpecies(widget.speciesId);
    final mp = progress.monsters[widget.speciesId];

    if (species == null || mp == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('진화')),
        body: const Center(child: Text('데이터를 찾을 수 없습니다')),
      );
    }

    final stage = mp.evolutionStage;
    final evoPoints = progress.evolutionPoints;
    final canEvolve = provider.canEvolveMonster(widget.speciesId);
    final canEvolvePts = provider.canEvolveWithPoints(widget.speciesId);
    final isHidden = species.isHidden;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(species.name),
        backgroundColor: AppTheme.surface,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('💎', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$evoPoints',
                  style: const TextStyle(
                    color: Color(0xFF7EC8E3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 헤더 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    species.evolutionNames[stage],
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: MonsterData.elementColor(species.element).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      species.element,
                      style: TextStyle(
                        color: MonsterData.elementColor(species.element),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isHidden) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '✨ HIDDEN',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${stage + 1}/6 단계 · 진화 포인트 $evoPoints',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 12),

            // ── 가로 스와이프 진화 체인 (Expanded → 절반 화면 크기) ──
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: 6,
                itemBuilder: (context, i) {
                  final isOwned   = i <= stage;
                  final isCurrent = i == stage;

                  return AnimatedScale(
                    scale: isCurrent ? 1.0 : 0.82,
                    duration: const Duration(milliseconds: 200),
                    child: _EvolutionStageCard(
                      species:    species,
                      stageIndex: i,
                      isOwned:    isOwned,
                      isCurrent:  isCurrent,
                      isHidden:   isHidden,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 페이지 도트 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final isOwned = i <= stage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == stage ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isOwned
                        ? (isHidden ? Colors.amber : AppTheme.primary)
                        : Colors.white24,
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),

            // 설명 (2줄 이내)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                species.description,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // ── 진화 버튼 ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  if (stage >= 5)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.success.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          '🏆 최강 진화 완료!',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // 진화 비용 안내
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '진화 비용: ${AppProvider.evolutionCost}pt',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '보유: ${evoPoints}pt',
                            style: TextStyle(
                              color: canEvolve
                                  ? const Color(0xFF7EC8E3)
                                  : AppTheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canEvolve
                            ? () async {
                                final success =
                                    await provider.evolveMonster(widget.speciesId);
                                if (success && mounted) {
                                  final newStage = provider
                                      .progress.monsters[widget.speciesId]!
                                      .evolutionStage;
                                  _pageCtrl.animateToPage(
                                    newStage,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutBack,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✨ ${species.evolutionNames[newStage]}으로 진화했어요!',
                                      ),
                                      backgroundColor: AppTheme.success,
                                      behavior: SnackBarBehavior.fixed,
                                      duration: const Duration(seconds: 2),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isHidden ? Colors.amber : AppTheme.primary,
                          foregroundColor:
                              isHidden ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          canEvolve
                              ? '💎 진화하기 (${AppProvider.evolutionCost}pt)'
                              : '진화 포인트 부족 (${AppProvider.evolutionCost}pt 필요)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: canEvolvePts
                            ? () async {
                                final success = await provider
                                    .evolveMonsterWithPoints(widget.speciesId);
                                if (success && mounted) {
                                  final newStage = provider
                                      .progress.monsters[widget.speciesId]!
                                      .evolutionStage;
                                  _pageCtrl.animateToPage(
                                    newStage,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutBack,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✨ ${species.evolutionNames[newStage]}으로 진화했어요!',
                                      ),
                                      backgroundColor: AppTheme.success,
                                      behavior: SnackBarBehavior.fixed,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          side: BorderSide(
                              color: AppTheme.accent.withOpacity(0.6)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          canEvolvePts
                              ? '⭐ 일반 포인트로 진화 (${AppProvider.evolutionCostPoints}pt)'
                              : '⭐ 일반 포인트 부족 (${AppProvider.evolutionCostPoints}pt 필요)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 활성 몬스터 변경 버튼
                    _ActiveMonsterButton(speciesId: widget.speciesId),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 진화 단계 카드 (스와이프 아이템)
// ─────────────────────────────────────────────────────────────

class _EvolutionStageCard extends StatelessWidget {
  final MonsterSpecies species;
  final int stageIndex;
  final bool isOwned;
  final bool isCurrent;
  final bool isHidden;

  const _EvolutionStageCard({
    required this.species,
    required this.stageIndex,
    required this.isOwned,
    required this.isCurrent,
    required this.isHidden,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isHidden ? Colors.amber : AppTheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 카드 높이에서 배지 + 간격 + 이름 영역을 빼고 남은 공간이 스프라이트 크기
        const double overhead = 36 + 16 + 16 + 30 + 24 + 20; // badge+spacers+name+padding
        final double availH   = constraints.maxHeight - overhead;
        final double spriteSize = availH.clamp(60.0, 280.0);

        return Container(
          margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
            gradient: isCurrent
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accentColor.withOpacity(0.18),
                      AppTheme.card,
                    ],
                  )
                : null,
            color: isCurrent ? null : AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isCurrent ? accentColor : Colors.white10,
              width: isCurrent ? 2.5 : 1,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 단계 번호 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrent ? accentColor : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${stageIndex + 1}단계',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── 스프라이트 (카드 높이에 자동 맞춤) ──
              MonsterSpriteWidget(
                monsterId: species.id,
                stage: stageIndex,
                size: spriteSize,
                fallbackEmoji: species.evolutionEmojis[stageIndex],
                isGrayscale: !isOwned,
              ),

          const SizedBox(height: 16),

          // 이름 (미보유 → ???)
          Text(
            isOwned ? species.evolutionNames[stageIndex] : '???',
            style: TextStyle(
              color: isOwned
                  ? (isCurrent ? AppTheme.textPrimary : AppTheme.textSecondary)
                  : Colors.white30,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
              fontSize: isCurrent ? 18 : 15,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isOwned) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '진화하면 해금',
                style: TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
        );  // Container 닫기
      },    // builder 닫기
    );      // LayoutBuilder 닫기
  }
}

// ─────────────────────────────────────────────────────────────
// 활성 몬스터 변경 버튼
// ─────────────────────────────────────────────────────────────

class _ActiveMonsterButton extends StatelessWidget {
  final String speciesId;
  const _ActiveMonsterButton({required this.speciesId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isActive = provider.progress.activeMonsterSpeciesId == speciesId;

    if (isActive) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.success.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            '✅ 현재 활성 몬스터',
            style:
                TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          provider.setActiveMonster(speciesId);
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
          side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('이 몬스터로 변경'),
      ),
    );
  }
}
