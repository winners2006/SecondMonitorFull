import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:second_monitor/View/second_monitor.dart';
import 'package:second_monitor/View/WindowManager.dart';
import 'package:second_monitor/View/LaunchWindow.dart';
import 'package:second_monitor/Service/AppSettings.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:second_monitor/Service/Server.dart';
import 'package:second_monitor/Service/LicenseManager.dart';
import 'package:second_monitor/View/LicenseWindow.dart';
import 'package:second_monitor/Service/UpdateService.dart';
import 'package:second_monitor/Widget/UpdateDialog.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Настройки окна Windows
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: "Second Monitor",
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions);

  // Проверяем обновления
  try {
    final updateInfo = await UpdateService.checkForUpdates();
    if (updateInfo != null) {
      // Показываем диалог обновления после запуска приложения
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (context) => UpdateDialog(updateInfo: updateInfo),
        );
      });
    }
  } catch (e) {
    print('Ошибка при проверке обновлений: $e');
  }

  // Проверяем лицензию
  final licenseCheck = await LicenseManager.checkLicense();
  
  // Если лицензия недействительна, всегда показываем окно лицензии
  if (!licenseCheck['valid']) {
    // Очищаем все данные лицензии
    await LicenseManager.revokeLicense();
    
    await windowManager.waitUntilReadyToShow();
    await windowManager.setTitle('Активация лицензии');
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.center();
    await windowManager.show();
  }

  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    initialRoute: licenseCheck['valid'] ? '/launch' : '/',
    routes: {
      '/': (context) => const LicenseWindow(),
      '/launch': (context) => const LaunchWindow(),
      '/settings': (context) => const SettingsWindow(),
      '/monitor': (context) => const SecondMonitor(),
    },
    onUnknownRoute: (settings) {
      // Обработка неизвестных маршрутов
      return MaterialPageRoute(
        builder: (context) => const LaunchWindow(),
      );
    },
  ));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();