import 'dart:ui';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

class WindowService {
  static Future<void> setupMainWindow() async {
    await windowManager.ensureInitialized();
    
    // Настройки для основного окна (первый монитор)
    const windowOptions = WindowOptions(
      size: Size(1024, 768),
      center: true,
      skipTaskbar: false,
      title: 'Second Monitor',
      minimumSize: Size(800, 600),
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions);
    await windowManager.setPreventClose(true);
    await windowManager.show();
    await windowManager.focus();
  }

  static Future<void> moveToSecondScreen() async {
    final screens = await ScreenRetriever.instance.getAllDisplays();
    
    if (screens.length > 1) {
      final secondScreen = screens[1];
      final screenSize = secondScreen.size;
      final screenPos = secondScreen.visiblePosition;
      
      if (screenSize != null && screenPos != null) {
        print('Second screen found:');
        print('Position: ${screenPos.dx},${screenPos.dy}');
        print('Size: ${screenSize.width}x${screenSize.height}');
        
        // Сначала устанавливаем позицию и размер
        await windowManager.setFullScreen(false); // Временно отключаем полноэкранный режим
        await windowManager.setBounds(
          Rect.fromLTWH(
            screenPos.dx,
            screenPos.dy,
            screenSize.width,
            screenSize.height,
          ),
        );
        
        // Даем небольшую паузу перед включением полноэкранного режима
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Затем включаем полноэкранный режим
        await windowManager.setFullScreen(true);
      }
    } else {
      final primaryScreen = screens[0];
      final screenSize = primaryScreen.size;
      
      if (screenSize != null) {
        print('Using primary screen: ${screenSize.width}x${screenSize.height}');
        await windowManager.setBounds(
          Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
        );
        await windowManager.setFullScreen(true);
      }
    }
  }

  static Future<void> moveToMainScreen() async {
    // Возвращаем окно на основной экран с исходными размерами
    await windowManager.setFullScreen(false);
    await windowManager.setBounds(
      const Rect.fromLTWH(0, 0, 1024, 768),
      animate: true,
    );
    await windowManager.center();
  }
} 