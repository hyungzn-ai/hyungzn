import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/wrong_answer.dart';
import '../providers/app_provider.dart';
import '../utils/answer_checker.dart';
import '../utils/theme.dart';

// ═══════════════════════════════════════════════════════════════
// 틀린 문제 목록 화면
// ═══════════════════════════════════════════════════════════════

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  static const _levelOrder = ['beginner', 'intermediate', 'advanced'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final wrongs = provider.progress.wrongAnswers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('틀린 문제 복습'),
        actions: [
          if (wrongs.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, provider),
              child: const Text('전체 삭제', style: TextStyle(color: AppTheme.error)),
            ),
        ],
      ),
      body: wrongs.isEmpty ? _buildEmpty() : _buildList(context, wrongs),
      // 복습 시작 버튼
      bottomNavigationBar: wrongs.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewQuizScreen(
                        wrongAnswers: List.from(wrongs),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    '복습 퀴즈 시작 (${wrongs.length}문제) 🔥',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            '틀린 문제가 없어요!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '퀴즈를 풀면 틀린 문제가 여기 저장돼요.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
          ),
    );
  }

  Widget _buildList(BuildContext context, List<WrongAnswer> wrongs) {
    // 레벨별로 그룹핑
    final grouped = <String, List<WrongAnswer>>{};
    for (final level in _levelOrder) {
      final items = wrongs.where((w) => w.level == level).toList();
      if (items.isNotEmpty) grouped[level] = items;
    }

    int globalIndex = 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // 요약 헤더
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.secondary.withOpacity(0.3), AppTheme.primary.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 ${wrongs.length}개의 오답',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    '복습 퀴즈를 풀고 오답을 줄여보세요!',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),

        // 레벨별 섹션
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(
              children: [
                _levelBadge(entry.key),
                const SizedBox(width: 8),
                Text(
                  '${entry.value.length}개',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          for (final wrong in entry.value) ...[
            _WrongCard(
              wrong: wrong,
              index: globalIndex++,
              onDelete: (key) => context.read<AppProvider>().removeWrongAnswer(key),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _levelBadge(String level) {
    final map = {
      'beginner': ('초급', const Color(0xFF06D6A0)),
      'intermediate': ('중급', AppTheme.accent),
      'advanced': ('고급', AppTheme.secondary),
    };
    final (name, color) = map[level]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(name,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _confirmClear(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('전체 삭제',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text(
          '저장된 오답을 모두 삭제할까요?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.clearWrongAnswers();
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 오답 카드 위젯
// ─────────────────────────────────────────────────────────────

class _WrongCard extends StatefulWidget {
  final WrongAnswer wrong;
  final int index;
  final void Function(String key) onDelete;

  const _WrongCard({required this.wrong, required this.index, required this.onDelete});

  @override
  State<_WrongCard> createState() => _WrongCardState();
}

class _WrongCardState extends State<_WrongCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.error.withOpacity(_expanded ? 0.4 : 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Day ${widget.wrong.day}',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.wrong.korean,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              // 정답
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✅ 정답',
                        style: TextStyle(
                            color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      widget.wrong.answers[0],
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    ),
                    if (widget.wrong.answers.length > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        '또는: ${widget.wrong.answers.skip(1).join(' / ')}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.wrong.hint.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '💡 ${widget.wrong.hint}',
                    style: const TextStyle(color: AppTheme.accent, fontSize: 12),
                  ),
                ),
              ],
              if (widget.wrong.explanation.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.wrong.explanation,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => widget.onDelete(widget.wrong.key),
                  icon: const Icon(Icons.delete_outline_rounded, size: 14),
                  label: const Text('삭제', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.index * 40));
  }
}

// ═══════════════════════════════════════════════════════════════
// 복습 퀴즈 화면
// ═══════════════════════════════════════════════════════════════

class ReviewQuizScreen extends StatefulWidget {
  final List<WrongAnswer> wrongAnswers;

  const ReviewQuizScreen({super.key, required this.wrongAnswers});

  @override
  State<ReviewQuizScreen> createState() => _ReviewQuizScreenState();
}

class _ReviewQuizScreenState extends State<ReviewQuizScreen> {
  late List<WrongAnswer> _queue;
  int _index = 0;
  bool _answered = false;
  bool _showHint = false;
  bool _isCorrect = false;
  String _feedback = '';
  int _clearedCount = 0; // 이번 세션에 맞춘 수
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _queue = List.from(widget.wrongAnswers);
    Future.delayed(const Duration(milliseconds: 200), () => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  WrongAnswer get _current => _queue[_index];

  void _check() {
    if (_answered) return;
    final input = _ctrl.text.trim();
    if (input.isEmpty) return;

    final result = AnswerChecker.check(
      input,
      _current.answers,
      keywords: _current.keywords,
      naturalForm: _current.explanation,
    );

    setState(() {
      _answered = true;
      _isCorrect = result.isCorrect;
      _feedback = result.feedback;
    });
    _focusNode.unfocus();

    // 맞췄으면 오답 목록에서 제거
    if (result.isCorrect) {
      context.read<AppProvider>().removeWrongAnswer(_current.key);
      _clearedCount++;
    }
  }

  void _next() {
    if (_index < _queue.length - 1) {
      setState(() {
        _index++;
        _answered = false;
        _showHint = false;
        _isCorrect = false;
        _feedback = '';
        _ctrl.clear();
      });
      Future.delayed(const Duration(milliseconds: 100), () => _focusNode.requestFocus());
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _clearedCount == _queue.length ? '🏆' : _clearedCount > 0 ? '💪' : '📚',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 12),
            Text(
              '복습 완료!',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_clearedCount / ${_queue.length}문제 통과',
              style: const TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _clearedCount == _queue.length
                  ? '모든 오답을 완전히 정복했어요! 🎉'
                  : '통과한 문제는 오답에서 삭제됐어요.',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // quiz
              },
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _queue.length;
    final progressVal = (_index + (_answered ? 1 : 0)) / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('복습 퀴즈'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_index + 1} / $total',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행 바 (붉은 계열)
          LinearProgressIndicator(
            value: progressVal,
            backgroundColor: AppTheme.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 레벨 + Day 뱃지
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${_current.levelName} · Day ${_current.day}',
                          style: const TextStyle(color: AppTheme.secondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 한국어 문장
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        const Text('영어로 작성하세요',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(height: 10),
                        Text(
                          _current.korean,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0),

                  const SizedBox(height: 16),

                  // 힌트 버튼
                  if (_current.hint.isNotEmpty) ...[
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _showHint = !_showHint),
                      icon: const Icon(Icons.lightbulb_outline, size: 16),
                      label: Text(_showHint ? '힌트 숨기기' : '힌트 보기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                        side: const BorderSide(color: AppTheme.accent, width: 1),
                      ),
                    ),
                    if (_showHint) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                        ),
                        child: Text(
                          '💡 ${_current.hint}',
                          style: const TextStyle(color: AppTheme.accent, fontSize: 14),
                        ),
                      ).animate().fadeIn(duration: 200.ms),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // 입력창
                  TextField(
                    controller: _ctrl,
                    focusNode: _focusNode,
                    enabled: !_answered,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '영어로 입력하세요...',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _check(),
                  ),

                  const SizedBox(height: 12),

                  if (!_answered)
                    ElevatedButton(
                      onPressed: _check,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
                      child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),

                  // 피드백
                  if (_answered) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCorrect
                            ? AppTheme.success.withOpacity(0.15)
                            : AppTheme.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCorrect
                              ? AppTheme.success.withOpacity(0.5)
                              : AppTheme.error.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCorrect ? '✅ 통과! 오답에서 제거됐어요.' : '❌ 아직 더 연습이 필요해요.',
                            style: TextStyle(
                              color: _isCorrect ? AppTheme.success : AppTheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(_feedback,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary, fontSize: 14, height: 1.5)),
                        ],
                      ),
                    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0),

                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _index == total - 1
                            ? AppTheme.success
                            : _isCorrect
                                ? AppTheme.success
                                : AppTheme.secondary,
                      ),
                      child: Text(
                        _index == total - 1 ? '결과 보기 🎉' : '다음 →',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
