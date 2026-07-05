import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;
  bool _finishing = false;

  static const List<List<String>> _pages = [
    ['✍️', '한국어를 영어로!', '하루 5문장씩 영작 연습으로\n영어 실력을 차곡차곡 쌓아요.\n힌트와 친절한 피드백이 도와줄게요.'],
    ['🐾', '몬스터와 함께 성장!', '문제를 풀면 포인트를 얻고\n포인트로 몬스터를 뽑아 진화시켜요.\n히든 몬스터까지 모두 모아보세요!'],
    ['🔥', '매일매일 꾸준하게!', '연속 학습 스트릭과 일일 미션으로\n꾸준함을 보상받아요.\n알림을 켜면 까먹을 일이 없어요!'],
  ];

  Future<void> _finish({required bool enableNotif}) async {
    if (_finishing) return;
    _finishing = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (enableNotif) {
      try {
        final ok = await NotificationService.instance.requestPermission();
        if (ok) {
          await NotificationService.instance.scheduleDaily();
          await prefs.setBool('notif_on', true);
        }
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: isLast
                    ? const SizedBox(height: 40)
                    : TextButton(
                        onPressed: () => _pageCtrl.animateToPage(
                          _pages.length - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        child: Text('건너뛰기',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p[0], style: const TextStyle(fontSize: 90)),
                        const SizedBox(height: 32),
                        Text(
                          p[1],
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p[2],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? AppTheme.primary : AppTheme.card,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLast) {
                          _finish(enableNotif: true);
                        } else {
                          _pageCtrl.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isLast ? '🔔 알림 켜고 시작하기' : '다음',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (isLast)
                    TextButton(
                      onPressed: () => _finish(enableNotif: false),
                      child: Text('알림 없이 시작할게요',
                          style: TextStyle(color: AppTheme.textSecondary)),
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
