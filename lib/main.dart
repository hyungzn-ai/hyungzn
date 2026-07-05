import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    await NotificationService.instance.init();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('notif_on') ?? false) {
      await NotificationService.instance.scheduleDaily();
    }
  } catch (_) {}
  runApp(const WriteMon());
}

class WriteMon extends StatelessWidget {
  const WriteMon({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: '영작몬',
            debugShowCheckedModeBanner: false,
            theme: provider.isLoaded
                ? provider.currentTheme
                : AppTheme.buildTheme(AppTheme.purpleColors),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const WriteMon());
}

class WriteMon extends StatelessWidget {
  const WriteMon({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: '영작몬',
            debugShowCheckedModeBanner: false,
            theme: provider.isLoaded
                ? provider.currentTheme
                : AppTheme.buildTheme(AppTheme.purpleColors),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
