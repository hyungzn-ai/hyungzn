import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/wrong_answer.dart';
import '../providers/app_provider.dart';
import '../services/question_loader.dart';
import '../services/tts_service.dart';
import '../utils/answer_checker.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'day_complete_screen.dart';

class QuizScreen extends StatefulWidget {
  final String level;
  final int day;
  final String mode; // 'write' | 'arrange' | 'mixed'

  const QuizScreen(
      {super.key, required this.level, required this.day, this.mode = 'write'});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  DayData? _dayData;
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _answered = false;
  bool _showHint = false;
  bool _hintUsed = false;    // 이번 문제에서 힌트 사용 여부
  bool _isCorrect = false;
  String _feedback = '';
  int _correctCount = 0;
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<bool> _arrangeFlags = []; // 문제별 순서맞추기 여부
  List<String> _pool = [];   // 남은 단어 칩
  List<String> _picked = []; // 선택한 단어 칩

  @override
  void initState() {
    super.initState();
    _loadDay();
  }

  Future<void> _loadDay() async {
    final data = await QuestionLoader.loadDay(widget.level, widget.day);
    if (mounted) {
      final rng = Random();
      final n = data?.questions.length ?? 0;
      final mode = context.read<AppProvider>().quizMode;
      _arrangeFlags = List.generate(n, (_) {
        if (mode == 'arrange') return true;
        if (mode == 'mixed') return rng.nextBool();
        return false;
      });
      setState(() {
        _dayData = data;
        _isLoading = false;
      });
      _setupArrange();
      if (!_isArrange) {
        Future.delayed(const Duration(milliseconds: 200), () => _focusNode.requestFocus());
      }
    }
  }

  Question get _current => _dayData!.questions[_currentIndex];

  bool get _isArrange =>
      _arrangeFlags.isNotEmpty &&
      _currentIndex < _arrangeFlags.length &&
      _arrangeFlags[_currentIndex];

  void _setupArrange() {
    if (!_isArrange || _dayData == null) return;
    // 문장부호를 떼어낸다 — 마지막 단어에만 마침표가 붙어 정답 위치가 노출되는 걸 방지
    final words = _current.answers[0]
        .split(' ')
        .map((w) => w.replaceAll(RegExp(r'''[.,!?;:"]'''), '').trim())
        .where((w) => w.isNotEmpty)
        .toList();
    final original = List<String>.from(words);
    words.shuffle(Random());
    // 섞은 결과가 원문 그대로면 한 번 더 섞는다
    if (words.length > 1 && words.join(' ') == original.join(' ')) {
      words.shuffle(Random());
    }
    setState(() {
      _pool = words;
      _picked = [];
    });
  }

  void _pickWord(int i) {
    if (_answered) return;
    setState(() {
      _picked.add(_pool.removeAt(i));
    });
  }

  void _unpickWord(int i) {
    if (_answered) return;
    setState(() {
      _pool.add(_picked.removeAt(i));
    });
  }

  void _showModeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final current = context.read<AppProvider>().quizMode;
        Widget option(String mode, String emoji, String title) {
          final selected = current == mode;
          return ListTile(
            leading: Text(emoji, style: const TextStyle(fontSize: 22)),
            title: Text(title,
                style: TextStyle(
                    color:
                        selected ? AppTheme.primary : AppTheme.textPrimary,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
            trailing: selected
                ? Icon(Icons.check_rounded, color: AppTheme.primary)
                : null,
            onTap: () {
              Navigator.pop(sheetCtx);
              _applyMode(mode);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Text('학습 모드 변경',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('남은 문제부터 바로 적용돼요',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              option('write', '✍️', '직접 작문'),
              option('arrange', '🧩', '순서 맞추기'),
              option('mixed', '🎲', '랜덤 믹스'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _applyMode(String mode) {
    context.read<AppProvider>().setQuizMode(mode);
    if (_arrangeFlags.isEmpty) return;
    final rng = Random();
    final start = _answered ? _currentIndex + 1 : _currentIndex;
    for (int i = start; i < _arrangeFlags.length; i++) {
      _arrangeFlags[i] = mode == 'arrange'
          ? true
          : mode == 'mixed'
              ? rng.nextBool()
              : false;
    }
    if (!_answered) {
      setState(() {
        _pool = [];
        _picked = [];
        _inputCtrl.clear();
      });
      _setupArrange();
      if (!_isArrange) {
        Future.delayed(const Duration(milliseconds: 100),
            () => _focusNode.requestFocus());
      } else {
        setState(() {});
      }
    } else {
      setState(() {});
    }
  }

  void _checkAnswer() {
    if (_answered) return;
    final input = _isArrange ? _picked.join(' ') : _inputCtrl.text.trim();
    if (input.isEmpty) return;

    final result = AnswerChecker.check(
      input,
      _current.answers,
      keywords: _current.keywords,
      naturalForm: _current.explanation,
    );

    if (result.isCorrect) {
      _correctCount++;
    }

    setState(() {
      _answered = true;
      _isCorrect = result.isCorrect;
      _feedback = result.feedback;
    });
    _focusNode.unfocus();
    context.read<AppProvider>().recordQuizAnswered();

    // 힌트를 보고 맞힌 문제는 감점 없이 복습 목록에 담아 다시 만나게 한다
    if (result.isCorrect && _hintUsed) {
      context.read<AppProvider>().addWrongAnswer(
            WrongAnswer(
              level: widget.level,
              day: widget.day,
              korean: _current.korean,
              answers: _current.answers,
              hint: _current.hint,
              explanation: _current.explanation,
              keywords: _current.keywords,
              addedAt: DateTime.now().millisecondsSinceEpoch,
              nextReviewAt: DateTime.now()
                  .add(const Duration(days: 1))
                  .millisecondsSinceEpoch,
            ),
          );
      setState(() {
        _feedback = _feedback + '\n\n📌 힌트를 봤으니 복습 목록에 담아둘게요.';
      });
    }

    // 틀렸으면 wrongAnswers에 저장 (비동기, 화면 블로킹 없음)
    if (!result.isCorrect) {
      context.read<AppProvider>().addWrongAnswer(
            WrongAnswer(
              level: widget.level,
              day: widget.day,
              korean: _current.korean,
              answers: _current.answers,
              hint: _current.hint,
              explanation: _current.explanation,
              keywords: _current.keywords,
              addedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    }
  }

  void _showAnswer() {
    setState(() {
      _answered = true;
      _isCorrect = false;
      _feedback = '정답: "${_current.answers[0]}"';
      if (_current.explanation.isNotEmpty) {
        _feedback += '\n\n💡 ${_current.explanation}';
      }
    });
    _focusNode.unfocus();
    context.read<AppProvider>().recordQuizAnswered();

    // 답 보기도 틀린 것으로 처리
    context.read<AppProvider>().addWrongAnswer(
          WrongAnswer(
            level: widget.level,
            day: widget.day,
            korean: _current.korean,
            answers: _current.answers,
            hint: _current.hint,
            explanation: _current.explanation,
            keywords: _current.keywords,
            addedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> _next() async {
    if (_currentIndex < _dayData!.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _showHint = false;
        _hintUsed = false;
        _isCorrect = false;
        _feedback = '';
        _inputCtrl.clear();
        _pool = [];
        _picked = [];
      });
      _setupArrange();
      if (!_isArrange) {
        Future.delayed(const Duration(milliseconds: 100), () => _focusNode.requestFocus());
      }
    } else {
      // Day 완료
      final result = await context.read<AppProvider>().completeDay(
            level: widget.level,
            day: widget.day,
            correctCount: _correctCount,
          );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DayCompleteScreen(
              level: widget.level,
              day: widget.day,
              correctCount: _correctCount,
              totalCount: _dayData!.questions.length,
              result: result,
              mode: widget.mode,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    if (_dayData == null || _dayData!.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Day ${widget.day}')),
        body: const Center(child: Text('문제를 불러올 수 없어요.')),
      );
    }

    final total = _dayData!.questions.length;
    final progress = (_currentIndex + (_answered ? 1 : 0)) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_levelName(widget.level)} · Day ${widget.day}'),
        actions: [
          IconButton(
            onPressed: _showModeSheet,
            icon: const Icon(Icons.tune_rounded),
            tooltip: '학습 모드 변경',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / $total',
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
            value: progress,
            backgroundColor: AppTheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 토픽 뱃지
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _dayData!.topic,
                        style: TextStyle(color: AppTheme.primary, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 한국어 문장
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text('영어로 작성하세요',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(height: 10),
                        Text(
                          _current.korean,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // 힌트 버튼
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showHint = !_showHint;
                        if (_showHint) _hintUsed = true;
                      });
                    },
                    icon: const Icon(Icons.lightbulb_outline, size: 16),
                    label: Text(_showHint ? '힌트 숨기기' : '힌트 보기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: BorderSide(color: AppTheme.accent, width: 1),
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
                        style: TextStyle(color: AppTheme.accent, fontSize: 14),
                      ),
                    ).animate().fadeIn(duration: 200.ms),
                  ],

                  const SizedBox(height: 16),

                  // 입력 영역: 직접 작문 or 순서 맞추기
                  if (!_isArrange)
                    TextField(
                      controller: _inputCtrl,
                      focusNode: _focusNode,
                      enabled: !_answered,
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: '영어로 입력하세요...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _checkAnswer(),
                    )
                  else ...[
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 56),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                      ),
                      child: _picked.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '🧩 아래 단어를 순서대로 탭하세요',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (int i = 0; i < _picked.length; i++)
                                  GestureDetector(
                                    onTap: () => _unpickWord(i),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppTheme.primary.withOpacity(0.6)),
                                      ),
                                      child: Text(
                                        _picked[i],
                                        style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (int i = 0; i < _pool.length; i++)
                          GestureDetector(
                            onTap: () => _pickWord(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBright,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                _pool[i],
                                style: TextStyle(
                                    color: AppTheme.textPrimary, fontSize: 15),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // 버튼 행
                  if (!_answered) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _showAnswer,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              side: BorderSide(color: AppTheme.textSecondary),
                            ),
                            child: const Text('답 보기'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _checkAnswer,
                            child: const Text('확인'),
                          ),
                        ),
                      ],
                    ),
                  ],

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
                            _isCorrect ? '✅ 정답!' : '❌ 오답',
                            style: TextStyle(
                              color: _isCorrect ? AppTheme.success : AppTheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _feedback,
                            style: TextStyle(
                                color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  TtsService.instance.speak(_current.answers[0]),
                              icon: const Icon(Icons.volume_up_rounded, size: 16),
                              label: const Text('정답 발음 듣기',
                                  style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: BorderSide(
                                    color: AppTheme.primary.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentIndex == _dayData!.questions.length - 1
                            ? AppTheme.success
                            : AppTheme.primary,
                      ),
                      child: Text(
                        _currentIndex == _dayData!.questions.length - 1 ? '완료! 🎉' : '다음 문제 →',
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

  String _levelName(String level) {
    switch (level) {
      case 'beginner':
        return '초급';
      case 'intermediate':
        return '중급';
      case 'advanced':
        return '고급';
      default:
        return level;
    }
  }
}
