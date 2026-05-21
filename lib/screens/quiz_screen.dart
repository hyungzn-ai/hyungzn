import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/wrong_answer.dart';
import '../providers/app_provider.dart';
import '../services/question_loader.dart';
import '../utils/answer_checker.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'day_complete_screen.dart';

class QuizScreen extends StatefulWidget {
  final String level;
  final int day;

  const QuizScreen({super.key, required this.level, required this.day});

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

  @override
  void initState() {
    super.initState();
    _loadDay();
  }

  Future<void> _loadDay() async {
    final data = await QuestionLoader.loadDay(widget.level, widget.day);
    if (mounted) {
      setState(() {
        _dayData = data;
        _isLoading = false;
      });
      Future.delayed(const Duration(milliseconds: 200), () => _focusNode.requestFocus());
    }
  }

  Question get _current => _dayData!.questions[_currentIndex];

  void _checkAnswer() {
    if (_answered) return;
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) return;

    final result = AnswerChecker.check(
      input,
      _current.answers,
      keywords: _current.keywords,
      naturalForm: _current.explanation,
    );

    // 포인트 계산 (힌트 사용 여부에 따라 차등)
    int earned = 0;
    if (result.isCorrect) {
      _correctCount++;
      if (_hintUsed) {
        earned = AppConstants.pointsCorrectWithHint;
      } else {
        earned = AppConstants.pointsCorrectFirst;
      }
    }

    setState(() {
      _answered = true;
      _isCorrect = result.isCorrect;
      _feedback = result.feedback;
      if (result.isCorrect && earned < AppConstants.pointsCorrectFirst && _hintUsed) {
        _feedback += '\n💡 힌트 사용으로 ${AppConstants.pointsCorrectFirst - earned}점 감점';
      }
    });
    _focusNode.unfocus();

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
      });
      Future.delayed(const Duration(milliseconds: 100), () => _focusNode.requestFocus());
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
      return const Scaffold(
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / $total',
                style: const TextStyle(color: AppTheme.textSecondary),
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
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
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
                        style: const TextStyle(color: AppTheme.primary, fontSize: 12),
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
                    label: Text(_showHint ? '힌트 숨기기' : '힌트 보기 (-${AppConstants.pointsCorrectFirst - AppConstants.pointsCorrectWithHint}점)'),
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

                  // 입력창
                  TextField(
                    controller: _inputCtrl,
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
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _checkAnswer(),
                  ),

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
                              side: const BorderSide(color: AppTheme.textSecondary),
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
                            style: const TextStyle(
                                color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
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
