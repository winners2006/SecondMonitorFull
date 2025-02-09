import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:second_monitor/View/second_monitor.dart';
import 'package:second_monitor/View/WindowManager.dart';
import 'package:second_monitor/View/LaunchWindow.dart';
import 'package:second_monitor/Service/AppSettings.dart';
import 'package:second_monitor/Service/logger.dart';

void main(List<String> args) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    // Настройка логгера
    final logger = Logger();
    await logger.log('Application started');

    // Оборачиваем запуск приложения в ErrorWidget.builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      log('Flutter error: ${details.exception}');
      log('Stack trace: ${details.stack}');
      return Container(
        color: Colors.white,
        child: Center(
          child: Text(
            'Произошла ошибка: ${details.exception}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    };

    // Добавляем глобальный обработчик ошибок
    FlutterError.onError = (FlutterErrorDetails details) {
      log('Flutter error caught: ${details.exception}');
      log('Stack trace: ${details.stack}');
      FlutterError.presentError(details);
    };

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
      runApp(const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: LaunchWindow(),
        ),
      ));
    }
  } catch (e, stack) {
    log('Fatal error in main: $e');
    log('Stack trace: $stack');
    // Показываем окно с ошибкой вместо закрытия
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Критическая ошибка: $e'),
        ),
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
