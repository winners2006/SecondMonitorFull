import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:second_monitor/View/second_monitor.dart';
import 'package:second_monitor/View/WindowManager.dart';
import 'package:second_monitor/View/LaunchWindow.dart';
import 'package:second_monitor/Service/AppSettings.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Настройки окна запуска
  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('Second Monitor');
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setSize(const Size(800, 800));
    await windowManager.setMinimumSize(const Size(600, 600));
    await windowManager.center();
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  });

  // Проверяем, запущено ли приложение с параметром автозапуска
  if (args.contains('--autostart')) {
    final settings = await AppSettings.loadSettings();
    runApp(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: SecondMonitor(settings: settings),
      ),
    ));
  } else {
    runApp(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: LaunchWindow(),
      ),
    ));
  }
}

class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsWindow(),
    );
  }
}

// Параллельный запуск окна настроек
void showSettingsWindow() async {
  await windowManager.show();
  windowManager.setSize(const Size(400, 300));
  windowManager.setTitle('Настройки');
  windowManager.setResizable(false);

  runApp(const SettingsApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
