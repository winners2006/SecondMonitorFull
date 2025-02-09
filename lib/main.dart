import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:second_monitor/View/second_monitor.dart';
import 'package:second_monitor/View/WindowManager.dart';
import 'package:second_monitor/View/LaunchWindow.dart';
import 'package:second_monitor/Service/AppSettings.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (args.contains('--settings')) {
    // Окно настроек всегда в полноэкранном режиме
    await windowManager.waitUntilReadyToShow();
    await windowManager.setFullScreen(true);
    await windowManager.show();
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SettingsWindow(),
    ));
  } else if (args.contains('--monitor')) {
    // Получаем размер второго монитора
    final screens = await ScreenRetriever.instance.getAllDisplays();
    final targetScreen = screens.length > 1 ? screens[1] : screens[0];
    
    await windowManager.waitUntilReadyToShow();
    // Убираем рамку и заголовок окна
    await windowManager.setAsFrameless();
    // Устанавливаем позицию и размер
    await windowManager.setBounds(Rect.fromLTWH(
      targetScreen.visiblePosition!.dx,
      targetScreen.visiblePosition!.dy,
      targetScreen.size.width,
      targetScreen.size.height,
    ));
    await windowManager.show();

    final settings = await AppSettings.loadSettings();
    runApp(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: SecondMonitor(settings: settings),
      ),
    ));
  } else {
    // Окно запуска в обычном размере по центру
    await windowManager.waitUntilReadyToShow();
    await windowManager.setTitle('Second Monitor');
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    //await windowManager.setSize(const Size(800, 600));
    await windowManager.center();
    await windowManager.show();
    
    runApp(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: LaunchWindow(),
      ),
    ));
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();