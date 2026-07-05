import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/vocab_item.dart';
import '../providers/app_provider.dart';
import '../services/vocab_loader.dart';
import '../utils/theme.dart';

// ─────────────────────────────────────────────────────────────
// 단어 암기 메인 화면 (레벨 탭 + 세트 목록)
// ─────────────────────────────────────────────────────────────

class VocabScreen extends StatefulWidget {
  const VocabScreen({super.key});

  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VocabSet> _allSets = [];
  bool _isLoading = true;

  static const _levels = ['beginner', 'intermediate', 'advanced'];
  static const _levelNames = ['초급', '중급', '고급'];
  static const _levelIcons = ['🌱', '🌿', '🌳'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sets = await VocabLoader.loadAll();
    if (mounted) {
      setState(() {
        _allSets = sets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final provider = context.watch<AppProvider>();
    final completedSets = provider.progress.completedVocabSets;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더 ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '단어 암기',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${completedSets.length} / ${_allSets.length} 세트 완료',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ── 레벨 탭 ───────────────────────────────────────
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.textPrimary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: List.generate(3, (i) => Tab(
                    child: Text(
                      '${_levelIcons[i]} ${_levelNames[i]}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── 세트 목록 ──────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(3, (tabIndex) {
                  final levelKey = _levels[tabIndex];
                  final levelSets = _allSets.where((s) => s.level == levelKey).toList();
                  return _SetListView(
                    sets: levelSets,
                    completedSets: completedSets,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetListView extends StatelessWidget {
  final List<VocabSet> sets;
  final Set<int> completedSets;

  const _SetListView({required this.sets, required this.completedSets});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: sets.length,
      itemBuilder: (context, i) {
        final set = sets[i];
        final isDone = completedSets.contains(set.setNumber);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabStudyScreen(vocabSet: set),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDone
                      ? AppTheme.success.withOpacity(0.5)
                      : AppTheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppTheme.success.withOpacity(0.2)
                          : AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isDone ? '✅' : '📖',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          set.title,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${set.items.length}개 표현',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isDone ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                    color: isDone ? AppTheme.success : AppTheme.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 40));
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 플래시카드 학습 화면
// ─────────────────────────────────────────────────────────────

class VocabStudyScreen extends StatefulWidget {
  final VocabSet vocabSet;
  final bool unknownOnly; // 모르는 것만 보기 모드

  const VocabStudyScreen({
    super.key,
    required this.vocabSet,
    this.unknownOnly = false,
  });

  @override
  State<VocabStudyScreen> createState() => _VocabStudyScreenState();
}

class _VocabStudyScreenState extends State<VocabStudyScreen>
    with SingleTickerProviderStateMixin {
  late List<VocabItem> _items;
  int _index = 0;
  bool _flipped = false;
  bool _showExample = false;
  bool _unknownOnly = false;

  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _unknownOnly = widget.unknownOnly;
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
    _rebuildItems();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _rebuildItems() {
    final provider = context.read<AppProvider>();
    if (_unknownOnly) {
      _items = widget.vocabSet.items
          .where((item) => provider.isVocabUnknown(item.id))
          .toList();
      if (_items.isEmpty) _items = widget.vocabSet.items;
    } else {
      _items = List.from(widget.vocabSet.items);
    }
    if (_index >= _items.length) _index = 0;
  }

  VocabItem get _current => _items[_index];

  void _flip() {
    if (_flipped) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    setState(() => _flipped = !_flipped);
  }

  void _goTo(int newIndex) {
    setState(() {
      _index = newIndex;
      _flipped = false;
      _showExample = false;
    });
    _flipCtrl.reset();
  }

  void _next() {
    if (_index < _items.length - 1) {
      _goTo(_index + 1);
    } else {
      _complete();
    }
  }

  void _prev() {
    if (_index > 0) {
      _goTo(_index - 1);
    }
  }

  // 스와이프 왼쪽 → 몰라요
  void _onSwipeLeft() {
    final provider = context.read<AppProvider>();
    provider.markVocab(_current.id, isUnknown: true);
    _showFeedback('몰라요 📌', AppTheme.secondary);
    _next();
  }

  // 스와이프 오른쪽 → 알아요
  void _onSwipeRight() {
    final provider = context.read<AppProvider>();
    provider.markVocab(_current.id, isUnknown: false);
    _showFeedback('알아요 ✅', AppTheme.success);
    _next();
  }

  void _showFeedback(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(milliseconds: 600),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _complete() async {
    final provider = context.read<AppProvider>();
    if (!provider.progress.completedVocabSets.contains(widget.vocabSet.setNumber)) {
      await provider.completeVocabSet(widget.vocabSet.setNumber);
    }
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                widget.vocabSet.title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '세트 완료! +15 포인트',
                style: TextStyle(
                    color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // study screen
              },
              child: Text('확인', style: TextStyle(color: AppTheme.primary)),
            ),
          ],
        ),
      );
    }
  }

  void _toggleUnknownOnly() {
    setState(() {
      _unknownOnly = !_unknownOnly;
      _rebuildItems();
      _index = 0;
      _flipped = false;
      _showExample = false;
      _flipCtrl.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final total = _items.length;
    final isUnknown = provider.isVocabUnknown(_current.id);
    final unknownCount = widget.vocabSet.items
        .where((item) => provider.isVocabUnknown(item.id))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vocabSet.title),
        actions: [
          // 모르는 것만 보기 토글
          if (unknownCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                onPressed: _toggleUnknownOnly,
                icon: Icon(
                  _unknownOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
                  size: 16,
                  color: _unknownOnly ? AppTheme.accent : AppTheme.textSecondary,
                ),
                label: Text(
                  '모르는것만',
                  style: TextStyle(
                    fontSize: 11,
                    color: _unknownOnly ? AppTheme.accent : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_index + 1} / $total',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행 바
          LinearProgressIndicator(
            value: (_index + 1) / total,
            backgroundColor: AppTheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 4,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // 타입 뱃지 + 모르는 단어 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                        ),
                        child: Text(
                          _current.type,
                          style: TextStyle(color: AppTheme.accent, fontSize: 12),
                        ),
                      ),
                      if (isUnknown) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
                          ),
                          child: Text(
                            '📌 모름',
                            style: TextStyle(color: AppTheme.secondary, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 플래시카드 (스와이프 가능)
                  Expanded(
                    child: GestureDetector(
                      onTap: _flip,
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity == null) return;
                        if (details.primaryVelocity! < -300) {
                          _onSwipeLeft(); // ← 몰라요
                        } else if (details.primaryVelocity! > 300) {
                          _onSwipeRight(); // → 알아요
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _flipAnim,
                        builder: (context, child) {
                          final angle = _flipAnim.value * 3.14159;
                          final isFront = _flipAnim.value < 0.5;
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: isFront
                                ? _buildFront()
                                : Transform(
                                    transform: Matrix4.identity()..rotateY(3.14159),
                                    alignment: Alignment.center,
                                    child: _buildBack(),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 스와이프 힌트
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('← 몰라요', style: TextStyle(color: AppTheme.secondary, fontSize: 11)),
                      SizedBox(width: 20),
                      Text('탭하면 뒤집혀요', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      SizedBox(width: 20),
                      Text('알아요 →', style: TextStyle(color: AppTheme.success, fontSize: 11)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 예문 버튼
                  AnimatedCrossFade(
                    firstChild: OutlinedButton.icon(
                      onPressed: () => setState(() => _showExample = true),
                      icon: const Icon(Icons.chat_bubble_outline, size: 15),
                      label: const Text('예문 보기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: BorderSide(color: AppTheme.textSecondary),
                      ),
                    ),
                    secondChild: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _current.example,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _current.exampleKorean,
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _showExample
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),

                  const SizedBox(height: 14),

                  // 알아요 / 몰라요 / 이전 / 다음 버튼
                  Row(
                    children: [
                      // 이전
                      OutlinedButton(
                        onPressed: _index > 0 ? _prev : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: BorderSide(color: AppTheme.textSecondary),
                          minimumSize: const Size(56, 44),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('←'),
                      ),
                      const SizedBox(width: 8),

                      // 몰라요
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _onSwipeLeft,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.secondary,
                            side: BorderSide(color: AppTheme.secondary.withOpacity(0.6)),
                            backgroundColor: AppTheme.secondary.withOpacity(0.08),
                          ),
                          child: const Text('📌 몰라요'),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 알아요 / 완료
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _index == total - 1 ? _complete : _onSwipeRight,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _index == total - 1
                                ? AppTheme.success
                                : AppTheme.primary,
                          ),
                          child: Text(
                            _index == total - 1 ? '완료! 🎉' : '✅ 알아요',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B4FD4), Color(0xFF0F3460)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '영어',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _current.english,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '탭해서 뜻 확인 →',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06D6A0), Color(0xFF1E8C5A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '뜻',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _current.korean,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _current.english,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
