import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:second_monitor/View/WindowManager.dart';
import 'package:second_monitor/View/second_monitor.dart';

class LaunchWindow extends StatefulWidget {
  const LaunchWindow({super.key});

  @override
  _LaunchWindowState createState() => _LaunchWindowState();
}

class _LaunchWindowState extends State<LaunchWindow> {
  static const String appVersion = '1.0.0';
  bool autoStart = false;

  @override
  void initState() {
    super.initState();
    _loadAutoStartSetting();
    _initHotkeys();
  }

  Future<void> _loadAutoStartSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      autoStart = prefs.getBool('autoStart') ?? false;
    });
    
    // Проверяем аргументы запуска
    const bool isAutoRun = bool.fromEnvironment('AUTO_RUN', defaultValue: false);
    if (autoStart && isAutoRun) {
      _launchApp();
    }
  }

  void _initHotkeys() {
    RawKeyboard.instance.addListener((RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        // Ctrl + Shift + S для открытия настроек
        if (event.isControlPressed && event.isShiftPressed && 
            event.logicalKey == LogicalKeyboardKey.keyS) {
          _openSettings();
        }
      }
    });
  }

  void _launchApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SecondMonitor()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsWindow()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 24),
              const Text(
                'Second Monitor',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Версия $appVersion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Программа для управления вторым монитором в торговых точках',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Запустить'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    onPressed: _launchApp,
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Настройки'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    onPressed: _openSettings,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Контакты:\nEmail: support@example.com\nТел: +7 (999) 123-45-67',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 