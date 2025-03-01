import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'second_monitor.dart';
import 'package:second_monitor/Service/AppSettings.dart';
import 'package:second_monitor/View/LaunchWindow.dart';
import 'package:second_monitor/Service/VideoManager.dart';
import 'dart:async';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:second_monitor/Service/FontManager.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:developer';
import 'package:second_monitor/View/LicenseWindow.dart';
import 'package:second_monitor/View/LicenseCheckWidget.dart';
import 'package:second_monitor/Service/WindowService.dart';
import 'package:second_monitor/View/ResizableWidget.dart';

// Окно настроек приложения
class SettingsWindow extends LicenseCheckWidget {
  static Future<void> showFullscreen(BuildContext context) async {
    await windowManager.waitUntilReadyToShow();
    await windowManager.setFullScreen(true);
    await windowManager.show();

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SettingsWindow(),
          fullscreenDialog: true, // Важный параметр
        ),
      );
    }
  }

  static Future<void> showSettings(BuildContext context) async {
    await WindowService.moveToMainScreen();
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SettingsWindow(),
        ),
      );
    }
  }

  const SettingsWindow({super.key});

  @override
  _SettingsWindowState createState() => _SettingsWindowState();
}

class _SettingsWindowState extends LicenseCheckState<SettingsWindow> with WindowListener {
  AppSettings settings = AppSettings(
    videoFilePath: '',
    videoUrl: '',
    isVideoFromInternet: true,
    showLoyaltyWidget: true,
    backgroundColor: Colors.white,
    borderColor: Colors.black,
    backgroundImagePath: '',
    useBackgroundImage: false,
    logoPath: '',
    showAdvertWithoutSales: false,
    showSideAdvert: false,
    sideAdvertVideoPath: '',
    isSideAdvertFromInternet: true,
    sideAdvertVideoUrl: '',
    widgetPositions: {
      'loyalty': {'x': 0.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
      'payment': {'x': 1130.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
      'summary': {'x': 1130.0, 'y': 904.0, 'w': 150.0, 'h': 120.0},
      'items': {'x': 200.0, 'y': 150.0, 'w': 880.0, 'h': 874.0},
      'sideAdvert': {'x': 0.0, 'y': 150.0, 'w': 200.0, 'h': 874.0},
      'logo': {
        'x': 10.0,
        'y': 10.0,
        'w': 100.0,
        'h': 50.0
      }, // Добавляем позицию для логотипа
    },
    logoPosition: {
      'x': 10.0,
      'y': 10.0,
      'w': 100.0,
      'h': 50.0,
    },
    selectedResolution: '1920x1080',
    autoStart: false,
    useInactivityTimer: true,
    inactivityTimeout: 50,
    openSettingsHotkey: 'Ctrl + Shift + S',
    closeMainWindowHotkey: 'Ctrl + Shift + L',
    sideAdvertType: 'video',
    sideAdvertPath: '',
    isSideAdvertContentFromInternet: false,
  );

  // Базовые настройки
  bool autoStart = false;
  bool useInactivityTimer = true;
  int inactivityTimeout = 50;
  bool isInSettings = true;

  // Настройки видео
  String videoFilePath = '';
  String videoUrl = '';
  bool isVideoFromInternet = true;
  bool showAdvertWithoutSales = true;
  bool showSideAdvert = false;
  String sideAdvertVideoPath = '';
  bool isSideAdvertFromInternet = true;
  String sideAdvertVideoUrl = '';

  // Настройки внешнего вида
  bool showLoyaltyWidget = true;
  Color backgroundColor = Colors.white;
  Color borderColor = Colors.black;
  String backgroundImagePath = '';
  bool useBackgroundImage = false;
  String logoPath = '';
  Map<String, double> logoPosition = {
    'x': 10.0,
    'y': 10.0,
    'w': 100.0,
    'h': 50.0,
  };

  // Настройки виджетов
  Map<String, Map<String, double>> widgetPositions = {
    'loyalty': {'x': 0.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
    'payment': {'x': 1130.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
    'summary': {'x': 1130.0, 'y': 904.0, 'w': 150.0, 'h': 120.0},
    'items': {'x': 200.0, 'y': 150.0, 'w': 880.0, 'h': 874.0},
    'sideAdvert': {'x': 0.0, 'y': 150.0, 'w': 200.0, 'h': 874.0},
    'logo': {
      'x': 10.0,
      'y': 10.0,
      'w': 100.0,
      'h': 50.0
    }, // Добавляем позицию для логотипа
  };

  // Служебные переменные
  bool isLoading = true;
  Timer? _inactivityTimer;
  bool _userInteracted = false;
  Map<String, List<String>> overlappingWidgets = {};
  int selectedLayout = 0;

  // Списки и константы
  final List<String> draggableWidgets = [
    'loyalty',
    'payment',
    'summary',
    'sideAdvert',
    'items',
  ];

  final List<List<Map<String, double>>> gridLayouts = [
    [
      {'x': 0, 'y': 0, 'w': 200, 'h': 150},
      {'x': 220, 'y': 0, 'w': 200, 'h': 150},
      {'x': 440, 'y': 0, 'w': 200, 'h': 150},
      {'x': 660, 'y': 0, 'w': 200, 'h': 300},
    ],
    [
      {'x': 0, 'y': 0, 'w': 300, 'h': 150},
      {'x': 320, 'y': 0, 'w': 300, 'h': 150},
      {'x': 0, 'y': 170, 'w': 300, 'h': 150},
      {'x': 320, 'y': 170, 'w': 200, 'h': 300},
    ],
  ];

  final Size selectedSize = const Size(1920, 1080);
  Size previewSize = const Size(1280, 1024);

  // В классе _SettingsWindowState добавим новые переменные
  bool showLogo = true;
  bool showPaymentQR = true;
  bool showSummary = true;

  // В классе _SettingsWindowState добавим новые переменные
  String webSocketUrl = 'localhost';
  String httpUrl = 'localhost';
  bool isVersion85 = false;
  int webSocketPort = 4002;
  int httpPort = 4001;

  String selectedResolution = '1024x768';

  // Расстояние, на котором виджеты будут примагничиваться
  static const double snapDistance = 10.0;

  // Проверяет, близки ли значения для примагничивания
  bool _isSnapping(double value1, double value2) {
    return (value1 - value2).abs() < snapDistance;
  }

  double lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  double _findSnapPosition(double currentValue, List<double> snapValues) {
    for (final snapValue in snapValues) {
      final distance = (currentValue - snapValue).abs();
      if (distance < snapDistance) {
        final t = distance / snapDistance;
        return lerp(snapValue, currentValue, t);
      }
    }
    return currentValue;
  }

  // Получает все возможные позиции для примагничивания
  List<double> _getSnapPositions(String currentType, bool isHorizontal) {
    List<double> positions = [];

    widgetPositions.forEach((type, pos) {
      if (type != currentType) {
        if (isHorizontal) {
          // Добавляем левые и правые края
          positions.add(pos['x']!);
          positions.add(pos['x']! + pos['w']!);
        } else {
          // Добавляем верхние и нижние края
          positions.add(pos['y']!);
          positions.add(pos['y']! + pos['h']!);
        }
      }
    });

    // Добавляем края экрана
    if (isHorizontal) {
      positions.add(0);
      positions.add(selectedSize.width);
    } else {
      positions.add(0);
      positions.add(selectedSize.height);
    }

    return positions;
  }

  @override
  void initState() {
    super.initState();
    // Добавляем обработчик закрытия окна
    windowManager.setPreventClose(true);
    windowManager.addListener(this);
    _initializeWidgetPositions();
    getSecondMonitorSize().then((size) {
      setState(() {
        previewSize = size;
        _adjustWidgetPositions(); // Пересчет позиций под новый размер
      });
    });
    _initSettings();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // Добавляем обработчик закрытия окна
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      // Показываем диалог подтверждения
      if (!context.mounted) return;
      bool shouldClose = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Подтверждение'),
          content: const Text('Вы уверены, что хотите закрыть программу?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ) ?? false;

      if (shouldClose) {
        await windowManager.destroy();
      }
    }
  }

  void _initializeWidgetPositions() {
    // Убедимся, что у нас есть начальные позиции для всех виджетов
    widgetPositions = settings.widgetPositions ?? {};
    if (!widgetPositions.containsKey('logo')) {
      widgetPositions['logo'] = {
        'x': 10.0,
        'y': 10.0,
        'w': 100.0,
        'h': 50.0,
      };
    }
    settings = settings.copyWith(widgetPositions: widgetPositions);
  }

  // Инициализация настроек
  Future<void> _initSettings() async {
    final loadedSettings = await AppSettings.loadSettings();
    setState(() {
      settings = loadedSettings;
      _loadSettings();
    });
  }

  // Загрузка настроек из хранилища
  void _loadSettings() async {
    settings = await AppSettings.loadSettings();
    setState(() {
      _selectedVideoPath = settings.sideAdvertVideoPath;
    });
    setState(() {
      videoFilePath = settings.videoFilePath;
      videoUrl = settings.videoUrl;
      isVideoFromInternet = settings.isVideoFromInternet;
      showLoyaltyWidget = settings.showLoyaltyWidget;
      backgroundColor = settings.backgroundColor;
      borderColor = settings.borderColor;
      backgroundImagePath = settings.backgroundImagePath;
      useBackgroundImage = settings.useBackgroundImage;
      logoPath = settings.logoPath;
      showAdvertWithoutSales = settings.showAdvertWithoutSales;
      showSideAdvert = settings.showSideAdvert;
      sideAdvertVideoPath = settings.sideAdvertVideoPath;
      isSideAdvertFromInternet = settings.isSideAdvertFromInternet;
      sideAdvertVideoUrl = settings.sideAdvertVideoUrl;
      widgetPositions.clear();
      if (settings.widgetPositions.isEmpty) {
        widgetPositions.addAll({
          'loyalty': {'x': 0.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
          'payment': {'x': 1130.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
          'summary': {'x': 1130.0, 'y': 904.0, 'w': 150.0, 'h': 120.0},
          'items': {'x': 200.0, 'y': 150.0, 'w': 880.0, 'h': 874.0},
          'sideAdvert': {'x': 0.0, 'y': 150.0, 'w': 200.0, 'h': 874.0},
          'logo': {
            'x': 10.0,
            'y': 10.0,
            'w': 100.0,
            'h': 50.0
          }, // Добавляем позицию для логотипа
        });
      } else {
        widgetPositions.addAll(
            Map<String, Map<String, double>>.from(settings.widgetPositions));
        // Убедимся, что позиция логотипа существует
        if (!widgetPositions.containsKey('logo')) {
          widgetPositions['logo'] = {
            'x': 10.0,
            'y': 10.0,
            'w': 100.0,
            'h': 50.0,
          };
        }
        logoPosition = settings.logoPosition;
        isLoading = false;
        useInactivityTimer = settings.useInactivityTimer;
        inactivityTimeout = settings.inactivityTimeout;
        showLogo = settings.showLogo;
        showPaymentQR = settings.showPaymentQR;
        showSummary = settings.showSummary;
        webSocketUrl = settings.webSocketUrl;
        httpUrl = settings.httpUrl;
        isVersion85 = settings.isVersion85;
        webSocketPort = settings.webSocketPort;
        httpPort = settings.httpPort;
      }
    });
  }

  // Сохранение настроек в хранилище
  Future<void> _saveSettings() async {

    settings = AppSettings(
      videoFilePath: videoFilePath,
      videoUrl: videoUrl,
      isVideoFromInternet: isVideoFromInternet,
      showLoyaltyWidget: showLoyaltyWidget,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      backgroundImagePath: backgroundImagePath,
      useBackgroundImage: useBackgroundImage,
      logoPath: logoPath,
      showAdvertWithoutSales: showAdvertWithoutSales,
      showSideAdvert: showSideAdvert,
      sideAdvertVideoPath:
          settings.sideAdvertVideoPath, // Используем существующий путь
      sideAdvertPath: settings.sideAdvertPath, // Используем существующий путь
      sideAdvertType: settings.sideAdvertType, // Сохраняем текущий тип
      isSideAdvertFromInternet: isSideAdvertFromInternet,
      sideAdvertVideoUrl: sideAdvertVideoUrl,
      widgetPositions: widgetPositions,
      logoPosition: logoPosition,
      selectedResolution: selectedResolution,
      autoStart: autoStart,
      useInactivityTimer: useInactivityTimer,
      inactivityTimeout: inactivityTimeout,
      webSocketUrl: webSocketUrl,
      httpUrl: httpUrl,
      isVersion85: isVersion85,
      webSocketPort: webSocketPort,
      httpPort: httpPort,
      loyaltyWidgetColor: settings.loyaltyWidgetColor,
      paymentWidgetColor: settings.paymentWidgetColor,
      summaryWidgetColor: settings.summaryWidgetColor,
      itemsWidgetColor: settings.itemsWidgetColor,
      loyaltyFontSize: settings.loyaltyFontSize,
      paymentFontSize: settings.paymentFontSize,
      summaryFontSize: settings.summaryFontSize,
      itemsFontSize: settings.itemsFontSize,
      loyaltyFontColor: settings.loyaltyFontColor,
      paymentFontColor: settings.paymentFontColor,
      summaryFontColor: settings.summaryFontColor,
      itemsFontColor: settings.itemsFontColor,
      customFontPath: settings.customFontPath,
      fontFamily: settings.fontFamily,
      showLogo: showLogo,
      showPaymentQR: showPaymentQR,
      showSummary: showSummary,
      advertVideoPath: settings.advertVideoPath,
      advertVideoUrl: settings.advertVideoUrl,
      isAdvertFromInternet: settings.isAdvertFromInternet,
      //sideAdvertPath: _selectedVideoPath,        // Используем выбранный путь
      isSideAdvertContentFromInternet: false,
      sideAdvertUrl: sideAdvertVideoUrl,
      useAlternatingRowColors: settings
          .useAlternatingRowColors, // Добавляем параметры чередования строк
      evenRowColor: settings.evenRowColor,
      oddRowColor: settings.oddRowColor,
      isDarkTheme: settings.isDarkTheme, // Добавляем параметр темы
    );

    await AppSettings.saveSettings(settings);
  }

  // Выбор видеофайла
  Future<void> _selectVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null) {
      final path = result.files.single.path!;

      final newSettings = settings.copyWith(
        videoFilePath: path,
        isVideoFromInternet: false,
        showAdvertWithoutSales: true,
        advertVideoPath: '',
        advertVideoUrl: '',
      );

      setState(() {
        settings = newSettings;
      });

      await AppSettings.saveSettings(settings);

      // Перезагружаем настройки для проверки
      final loadedSettings = await AppSettings.loadSettings();
      log('VideoFilePath: ${loadedSettings.videoFilePath}');
    }
  }

  // Выбор изображения
  Future<void> _selectImage(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        if (type == 'logo') {
          logoPath = result.files.single.path!;
        } else if (type == 'background') {
          backgroundImagePath = result.files.single.path!;
        } else if (type == 'sideAdvert') {
          settings = settings.copyWith(
            showSideAdvert: true,
            sideAdvertType: 'image', // Меняем тип на изображение
            sideAdvertVideoPath: '', // Очищаем путь к видео
            sideAdvertPath: result.files.single.path!,
            isSideAdvertContentFromInternet: false,
          );
        }
      });
      await AppSettings.saveSettings(settings);
    }
  }

  // Запуск таймера бездействия
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    if (useInactivityTimer && !isInSettings) {
      // Используем флаг вместо проверки маршрута
      _inactivityTimer = Timer(Duration(seconds: inactivityTimeout), () {
        if (!_userInteracted) {
          _launchSecondMonitor(context);
        }
      });
    }
  }

  // Сброс таймера бездействия
  void _resetInactivityTimer() {
    _userInteracted = true;
    _startInactivityTimer();
  }

  // Запуск второго монитора
  void _launchSecondMonitor(BuildContext context) async {
    await WindowService.moveToSecondScreen();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SecondMonitor()),
      );
    }
  }

  // Показать цветовой пикер
  Future<Color?> showColorPicker({
    required BuildContext context,
    required Color color,
  }) async {
    Color? selectedColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите цвет'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: color,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
              enableAlpha: false,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Выбрать'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: settings.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'Настройки',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3579A6)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LaunchWindow()),
              );
            },
          ),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Color(0xFF3579A6)),
              label: const Text(
                'Запустить',
                style: TextStyle(color: Color(0xFF3579A6)),
              ),
              onPressed: () => _launchSecondMonitor(context),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.key, color: Color(0xFF3579A6)),
              label: const Text(
                'Лицензия',
                style: TextStyle(color: Color(0xFF3579A6)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LicenseWindow()),
                );
              },
            ),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Настройки экрана
                      ExpansionTile(
                        title: const Row(
                          children: [
                            Icon(Icons.palette, color: Color(0xFF3579A6)),
                            SizedBox(width: 10),
                            Text(
                              'Оформление',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          ListTile(
                            title: const Text(
                              'Цвет фона',
                            ),
                            trailing: GestureDetector(
                              onTap: () => _selectBackgroundColor(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              'Цвет рамки',
                            ),
                            trailing: GestureDetector(
                              onTap: () => _selectBorderColor(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: borderColor,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            title:
                                const Text('Использовать фоновое изображение'),
                            trailing: Switch(
                              activeColor: const Color(0xFF3579A6),
                              value: settings.useBackgroundImage,
                              onChanged: (bool value) async {
                                setState(() {
                                  settings = settings.copyWith(
                                      useBackgroundImage: value);
                                  AppSettings.saveSettings(settings);
                                });

                                // Если включаем фон, сразу предлагаем выбрать изображение
                                if (value) {
                                  final result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                    allowedExtensions: ['jpg', 'jpeg', 'png'],
                                  );

                                  if (result != null) {
                                    setState(() {
                                      settings = settings.copyWith(
                                        backgroundImagePath:
                                            result.files.single.path!,
                                        useBackgroundImage: true,
                                      );
                                    });
                                  } else {
                                    // Если изображение не выбрано, отключаем опцию
                                    setState(() {
                                      settings = settings.copyWith(
                                          useBackgroundImage: false);
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                          // Показываем путь к изображению и кнопку выбора только если опция включена
                          if (settings.useBackgroundImage)
                            ListTile(
                              title: const Text('Фоновое изображение'),
                              subtitle: Text(
                                  settings.backgroundImagePath.isEmpty
                                      ? 'Изображение не выбрано'
                                      : settings.backgroundImagePath),
                              trailing: IconButton(
                                icon: const Icon(Icons.folder_open),
                                onPressed: () async {
                                  final result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                    allowedExtensions: ['jpg', 'jpeg', 'png'],
                                  );
                                  if (result != null) {
                                    setState(() {
                                      settings = settings.copyWith(
                                        backgroundImagePath:
                                            result.files.single.path!,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          // Добавляем настройки чередования строк
                          const Divider(),
                          SwitchListTile(
                            title: const Text(
                              'Чередование цветов строк',
                            ),
                            activeColor: const Color(0xFF3579A6),
                            value: settings.useAlternatingRowColors,
                            onChanged: (value) {
                              setState(() {
                                settings = settings.copyWith(
                                    useAlternatingRowColors: value);
                              });
                              AppSettings.saveSettings(settings);
                            },
                          ),
                          if (settings.useAlternatingRowColors) ...[
                            ListTile(
                              title: const Text(
                                'Цвет четных строк',
                              ),
                              trailing: GestureDetector(
                                onTap: () async {
                                  final color = await showColorPicker(
                                    context: context,
                                    color: settings.evenRowColor,
                                  );
                                  if (color != null) {
                                    setState(() {
                                      settings = settings.copyWith(
                                          evenRowColor: color);
                                    });
                                    AppSettings.saveSettings(settings);
                                  }
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: settings.evenRowColor,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text(
                                'Цвет нечетных строк',
                              ),
                              trailing: GestureDetector(
                                onTap: () async {
                                  final color = await showColorPicker(
                                    context: context,
                                    color: settings.oddRowColor,
                                  );
                                  if (color != null) {
                                    setState(() {
                                      settings =
                                          settings.copyWith(oddRowColor: color);
                                    });
                                    AppSettings.saveSettings(settings);
                                  }
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: settings.oddRowColor,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Виджеты
                      ExpansionTile(
                        title: const Row(
                          children: [
                            Icon(Icons.widgets, color: Color(0xFF3579A6)),
                            SizedBox(width: 10),
                            Text(
                              'Виджеты',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          // Управление видимостью виджетов
                          SwitchListTile(
                            title: const Text(
                              'Логотип',
                            ),
                            activeColor: const Color(0xFF3579A6),
                            value: showLogo,
                            onChanged: (value) {
                              setState(() {
                                showLogo = value;
                              });
                              _saveSettings();
                            },
                          ),
                          if (showLogo) ...[
                            const Divider(),
                            // Добавляем выбор типа контента
                            ListTile(
                              title: const Text('Выбрать изображение'),
                              subtitle: Text(settings.logoPath.isEmpty
                                  ? 'Логотип не выбран'
                                  : settings.logoPath),
                              trailing: const Icon(Icons.folder_open),
                              onTap: () async {
                                final result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  allowedExtensions: ['png', 'jpg', 'jpeg'],
                                );
                                if (result != null) {
                                  setState(() {
                                    settings = settings.copyWith(
                                      logoPath: result.files.single.path!,
                                    );
                                    AppSettings.saveSettings(
                                        settings); // Добавляем сохранение
                                  });
                                }
                              },
                            ),
                          ],
                          SwitchListTile(
                            title: const Text(
                              'Программа лояльности',
                            ),
                            activeColor: const Color(0xFF3579A6),
                            value: showLoyaltyWidget,
                            onChanged: (value) {
                              setState(() {
                                showLoyaltyWidget = value;
                              });
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text(
                              'QR-код оплаты',
                            ),
                            activeColor: const Color(0xFF3579A6),
                            value: showPaymentQR,
                            onChanged: (value) {
                              setState(() {
                                showPaymentQR = value;
                              });
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text(
                              'Итоговая сумма',
                            ),
                            activeColor: const Color(0xFF3579A6),
                            value: showSummary,
                            onChanged: (value) {
                              setState(() {
                                showSummary = value;
                              });
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text(
                              'Боковая реклама',
                            ),
                            activeColor: const Color(0xFF3579A6),
                            value: showSideAdvert,
                            onChanged: (value) {
                              setState(() {
                                showSideAdvert = value;
                              });
                              _saveSettings();
                            },
                          ),
                          if (showSideAdvert) ...[
                            const Divider(),
                            // Добавляем выбор типа контента
                            ListTile(
                              title: const Text(
                                'Тип контента',
                              ),
                              trailing: DropdownButton<String>(
                                value: settings.sideAdvertType,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'video',
                                    child: Text(
                                      'Видео',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'image',
                                    child: Text(
                                      'Изображение',
                                    ),
                                  ),
                                ],
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      settings = _updateSettings(
                                          sideAdvertType: value);
                                    });
                                  }
                                },
                              ),
                            ),
                            SwitchListTile(
                              title: const Text(
                                'Контент из интернета',
                              ),
                              activeColor: const Color(0xFF3579A6),
                              value: isSideAdvertFromInternet,
                              onChanged: (value) {
                                setState(() {
                                  isSideAdvertFromInternet = value;
                                });
                                _saveSettings();
                              },
                            ),
                            if (isSideAdvertFromInternet)
                              ListTile(
                                title: TextField(
                                  controller: TextEditingController(
                                      text: sideAdvertVideoUrl),
                                  decoration: InputDecoration(
                                    labelText:
                                        'URL ${settings.sideAdvertType == 'video' ? 'видео' : 'изображения'}',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      sideAdvertVideoUrl = value;
                                    });
                                    _saveSettings();
                                  },
                                ),
                              ),
                            if (!isSideAdvertFromInternet)
                              ListTile(
                                title: Text(
                                  'Выбрать ${settings.sideAdvertType == 'video' ? 'видео' : 'изображение'}',
                                  style:
                                      const TextStyle(color: Color(0xFF2D5456)),
                                ),
                                trailing: const Icon(Icons.folder_open),
                                onTap: () async {
                                  final result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions:
                                        settings.sideAdvertType == 'video'
                                            ? ['mp4', 'avi', 'mkv']
                                            : ['jpg', 'jpeg', 'png'],
                                  );
                                  if (result != null) {
                                    setState(() {
                                      settings = _updateSettings(
                                        sideAdvertPath:
                                            result.files.single.path ?? '',
                                      );
                                    });
                                  }
                                },
                              ),
                          ],
                          const Divider(),
                          // Настройки цветов
                          ExpansionTile(
                            title: const Row(
                              children: [
                                Icon(Icons.palette, color: Color(0xFF3579A6)),
                                SizedBox(width: 10),
                                Text(
                                  'Цвета виджетов',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              // Общий цвет для всех виджетов
                              ListTile(
                                title: const Text(
                                  'Общий цвет виджетов',
                                ),
                                trailing: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: settings
                                        .commonWidgetColor, // Исправляем на правильный параметр
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Выберите цвет'),
                                              content: SingleChildScrollView(
                                                child: ColorPicker(
                                                  pickerColor: settings
                                                      .commonWidgetColor, // Используем правильный параметр
                                                  onColorChanged:
                                                      (Color color) {
                                                    setState(() {
                                                      settings =
                                                          _updateSettings(
                                                        commonWidgetColor:
                                                            color, // Обновляем правильный параметр
                                                        useCommonWidgetColor:
                                                            true, // Включаем использование общего цвета
                                                      );
                                                    });
                                                  },
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                              // Индивидуальные цвета
                              if (showLoyaltyWidget)
                                ListTile(
                                  title: const Text(
                                    'Цвет виджета лояльности',
                                  ),
                                  trailing: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: settings.loyaltyWidgetColor,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onTap: () async {
                                    final color = await showColorPicker(
                                      context: context,
                                      color: settings.loyaltyWidgetColor,
                                    );
                                    if (color != null) {
                                      setState(() {
                                        settings = _updateSettings(
                                            loyaltyWidgetColor: color);
                                      });
                                      _saveSettings();
                                    }
                                  },
                                ),
                              if (showPaymentQR)
                                ListTile(
                                  title: const Text(
                                    'Цвет QR-кода',
                                  ),
                                  trailing: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: settings.paymentWidgetColor,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onTap: () async {
                                    final color = await showColorPicker(
                                      context: context,
                                      color: settings.paymentWidgetColor,
                                    );
                                    if (color != null) {
                                      setState(() {
                                        settings = _updateSettings(
                                            paymentWidgetColor: color);
                                      });
                                      _saveSettings();
                                    }
                                  },
                                ),
                              if (showSummary)
                                ListTile(
                                  title: const Text(
                                    'Цвет итогов',
                                  ),
                                  trailing: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: settings.summaryWidgetColor,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onTap: () async {
                                    final color = await showColorPicker(
                                      context: context,
                                      color: settings.summaryWidgetColor,
                                    );
                                    if (color != null) {
                                      setState(() {
                                        settings = _updateSettings(
                                            summaryWidgetColor: color);
                                      });
                                      _saveSettings();
                                    }
                                  },
                                ),
                              ListTile(
                                title: const Text(
                                  'Цвет таблицы товаров',
                                ),
                                trailing: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: settings.itemsWidgetColor,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onTap: () async {
                                  final color = await showColorPicker(
                                    context: context,
                                    color: settings.itemsWidgetColor,
                                  );
                                  if (color != null) {
                                    setState(() {
                                      settings = _updateSettings(
                                          itemsWidgetColor: color);
                                    });
                                    _saveSettings();
                                  }
                                },
                              ),
                            ],
                          ),
                          // Настройки шрифта
                          ExpansionTile(
                            title: const Row(
                              children: [
                                Icon(Icons.text_fields,
                                    color: Color(0xFF3579A6)),
                                SizedBox(width: 10),
                                Text(
                                  'Настройки шрифта',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              // Загрузка пользовательского шрифта
                              ListTile(
                                title: const Text('Загрузить шрифт'),
                                subtitle: Text(settings.customFontPath.isEmpty
                                    ? 'Используется системный шрифт'
                                    : settings.customFontPath.split('/').last),
                                trailing: const Icon(Icons.upload_file),
                                onTap: () async {
                                  final result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['ttf', 'otf'],
                                  );
                                  if (result != null) {
                                    final path = result.files.single.path!;

                                    // Создаем базовый стиль
                                    final baseStyle = TextStyle(
                                      fontSize: settings.loyaltyFontSize,
                                      color: settings.loyaltyFontColor,
                                    );

                                    // Загружаем шрифт через FontManager и получаем новый стиль
                                    final newStyle =
                                        await FontManager.loadCustomFont(
                                            path, baseStyle);

                                    setState(() {
                                      settings = _updateSettings(
                                        customFontPath: path,
                                        // Сохраняем имя шрифта из нового стиля
                                        fontFamily: newStyle.fontFamily,
                                      );
                                    });
                                    await _saveSettings();
                                  }
                                },
                              ),
                              const Divider(),
                              // Общие настройки для всех виджетов
                              ListTile(
                                title: const Text('Общий размер шрифта'),
                                subtitle:
                                    const Text('Применится ко всем виджетам'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${settings.loyaltyFontSize.toInt()}'),
                                    SizedBox(
                                      width: 150,
                                      child: Slider(
                                        value: settings.loyaltyFontSize,
                                        min: 10,
                                        max: 30,
                                        divisions: 20,
                                        onChanged: (value) {
                                          setState(() {
                                            settings = _updateSettings(
                                              loyaltyFontSize: value,
                                              paymentFontSize: value,
                                              summaryFontSize: value,
                                              itemsFontSize: value,
                                            );
                                          });
                                          _saveSettings();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListTile(
                                title: const Text('Общий цвет шрифта'),
                                subtitle:
                                    const Text('Применится ко всем виджетам'),
                                trailing: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: settings.loyaltyFontColor,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                                onTap: () async {
                                  final color = await showColorPicker(
                                    context: context,
                                    color: settings.loyaltyFontColor,
                                  );
                                  if (color != null) {
                                    setState(() {
                                      settings = _updateSettings(
                                        loyaltyFontColor: color,
                                        paymentFontColor: color,
                                        summaryFontColor: color,
                                        itemsFontColor: color,
                                      );
                                    });
                                    _saveSettings();
                                  }
                                },
                              ),
                              const Divider(),
                            ],
                          ),
                        ],
                      ),
                      // Реклама
                      ExpansionTile(
                        title: const Row(
                          children: [
                            Icon(Icons.video_library, color: Color(0xFF3579A6)),
                            SizedBox(width: 10),
                            Text(
                              'Основная реклама',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          // Показывать рекламу без продаж
                          SwitchListTile(
                            title: const Text('Показывать рекламу без продаж'),
                            activeColor: const Color(0xFF3579A6),
                            value: settings.showAdvertWithoutSales,
                            onChanged: (bool value) {
                              setState(() {
                                settings = _updateSettings(
                                  showAdvertWithoutSales: value,
                                );
                              });
                            },
                          ),
                          if (settings.showAdvertWithoutSales) ...[
                            SwitchListTile(
                              title: const Text('Видео из интернета'),
                              activeColor: const Color(0xFF3579A6),
                              value: settings.isAdvertFromInternet,
                              onChanged: (bool value) {
                                setState(() {
                                  settings = _updateSettings(
                                    isAdvertFromInternet: value,
                                  );
                                });
                              },
                            ),
                            if (settings.isAdvertFromInternet)
                              ListTile(
                                title: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'URL видео'),
                                  controller: TextEditingController(
                                      text: settings
                                          .advertVideoUrl), // Используем controller вместо value
                                  onChanged: (value) {
                                    setState(() {
                                      settings = _updateSettings(
                                          advertVideoUrl: value);
                                    });
                                  },
                                ),
                              )
                            else
                              ListTile(
                                title: const Text('Выбрать видео'),
                                subtitle: Text(settings.advertVideoPath.isEmpty
                                    ? 'Видео не выбрано'
                                    : settings.advertVideoPath),
                                trailing: IconButton(
                                  icon: const Icon(Icons.folder_open),
                                  onPressed: () async {
                                    final result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.video,
                                    );
                                    if (result != null) {
                                      setState(() {
                                        settings = _updateSettings(
                                          advertVideoPath:
                                              result.files.single.path!,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                          ],
                        ],
                      ),
                      // Безопасность
                      ExpansionTile(
                        title: const Text(
                          'Безопасность',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: const Icon(Icons.security,
                            color: Color(0xFF3579A6)),
                        children: [
                          SwitchListTile(
                            title: const Text(
                              'Использовать таймер неактивности',
                            ),
                            activeColor: const Color(
                                0xFF3579A6), // Изменили с 0xFF1B354F на 0xFF3579A6
                            value: useInactivityTimer,
                            onChanged: (value) {
                              setState(() {
                                useInactivityTimer = value;
                              });
                              _saveSettings();
                            },
                          ),
                          if (useInactivityTimer)
                            ListTile(
                              title: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Время неактивности (сек)',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    inactivityTimeout =
                                        int.tryParse(value) ?? 50;
                                  });
                                  _saveSettings();
                                },
                                controller: TextEditingController(
                                    text: inactivityTimeout.toString()),
                              ),
                            ),
                        ],
                      ),
                      // Общие настройки
                      ExpansionTile(
                        title: const Text('Общие настройки',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.settings,
                            color: Color(0xFF3579A6)),
                        children: [
                          SwitchListTile(
                            title: const Text('Автозапуск'),
                            activeColor: const Color(0xFF3579A6),
                            subtitle: const Text(
                                'Запускать приложение при старте Windows'),
                            value: autoStart,
                            onChanged: _updateAutoStart,
                          ),
                          SwitchListTile(
                            title: const Text('Темная тема'),
                            activeColor: const Color(0xFF3579A6),
                            value: settings.isDarkTheme,
                            onChanged: (value) {
                              setState(() {
                                settings =
                                    settings.copyWith(isDarkTheme: value);
                              });
                              AppSettings.saveSettings(settings);
                            },
                          ),
                        ],
                      ),
                      // Горячие клавиши
                      ExpansionTile(
                        title: const Text('Горячие клавиши',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.keyboard,
                            color: Color(0xFF3579A6)),
                        children: [
                          _buildHotkeysSection(),
                        ],
                      ),
                      // Настройки подключения
                      ExpansionTile(
                        title: const Text('Настройки подключения',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.settings_ethernet,
                            color: Color(0xFF3579A6)),
                        children: [
                          SwitchListTile(
                            title: const Text('Использовать 1С 8.5'),
                            activeColor: const Color(0xFF3579A6),
                            subtitle:
                                const Text('Работа напрямую через WebSocket'),
                            value: isVersion85,
                            onChanged: (value) {
                              setState(() {
                                isVersion85 = value;
                              });
                              _saveSettings();
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'WebSocket URL',
                                    hintText: 'localhost',
                                  ),
                                  initialValue: webSocketUrl,
                                  onChanged: (value) {
                                    webSocketUrl = value;
                                    _saveSettings();
                                  },
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'WebSocket Port',
                                    hintText: '4002',
                                  ),
                                  initialValue: webSocketPort.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    webSocketPort = int.tryParse(value) ?? 4002;
                                    _saveSettings();
                                  },
                                ),
                                if (!isVersion85) ...[
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'HTTP URL',
                                      hintText: 'localhost',
                                    ),
                                    initialValue: httpUrl,
                                    enabled: !isVersion85,
                                    onChanged: (value) {
                                      httpUrl = value;
                                      _saveSettings();
                                    },
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'HTTP Port',
                                      hintText: '4001',
                                    ),
                                    initialValue: httpPort.toString(),
                                    enabled: !isVersion85,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      httpPort = int.tryParse(value) ?? 4001;
                                      _saveSettings();
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Кнопки управления
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.file_upload,
                                  color: Color(0xFF3579A6)),
                              label: const Text(
                                'Экспорт',
                                style: TextStyle(color: Color(0xFF3579A6)),
                              ),
                              onPressed: _exportSettings,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.file_download,
                                  color: Color(0xFF3579A6)),
                              label: const Text(
                                'Импорт',
                                style: TextStyle(color: Color(0xFF3579A6)),
                              ),
                              onPressed: _importSettings,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh,
                                  color: Color(0xFF3579A6)),
                              label: const Text(
                                'Сброс',
                                style: TextStyle(color: Color(0xFF3579A6)),
                              ),
                              onPressed: _resetSettings,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Правая панель с предпросмотром
            Expanded(
              flex: 3,
              child: _buildPreview(),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для построения виджетов предпросмотра
  List<Widget> _buildPreviewWidgets(double scale, Size selectedSize) {
    List<Widget> widgets = [];

    // Добавляем логотип
    if (settings.showLogo &&
        settings.logoPath.isNotEmpty &&
        File(settings.logoPath).existsSync()) {
      final pos =
          widgetPositions['logo']!; // Используем позицию из widgetPositions
      widgets.add(
        Positioned(
          left: pos['x']! * scale,
          top: pos['y']! * scale,
          width: pos['w']! * scale,
          height: pos['h']! * scale,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                final newPos = Map<String, double>.from(pos);
                newPos['x'] = (pos['x']! + details.delta.dx / scale)
                    .clamp(0.0, selectedSize.width - pos['w']!);
                newPos['y'] = (pos['y']! + details.delta.dy / scale)
                    .clamp(0.0, selectedSize.height - pos['h']!);
                widgetPositions['logo'] = newPos;
                _saveSettings();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(settings.logoPath)),
                  fit: BoxFit.contain,
                ),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Добавляем основные виджеты с учетом их видимости
    for (var type in draggableWidgets) {
      if (type == 'loyalty' && !showLoyaltyWidget) continue;
      if (type == 'payment' && !showPaymentQR) continue;
      if (type == 'summary' && !showSummary) continue;
      if (type == 'sideAdvert' && !showSideAdvert) continue;

      widgets.add(_buildPreviewWidget(type, scale));
    }

    return widgets;
  }

  Widget _buildPreviewWidget(String type, double scale) {
    final pos = widgetPositions[type];
    if (pos == null) return const SizedBox.shrink();

    return Positioned(
      left: pos['x']! * scale,
      top: pos['y']! * scale,
      width: pos['w']! * scale,
      height: pos['h']! * scale,
      child: MouseRegion(
        child: Stack(
          children: [
            GestureDetector(
              onPanUpdate: (details) {
                double newX = pos['x']! + details.delta.dx / scale;
                double newY = pos['y']! + details.delta.dy / scale;

                // Получаем позиции для примагничивания только если скорость перемещения не слишком высокая
                final speed = details.delta.distance;
                if (speed < 10) {
                  // Порог скорости для активации примагничивания
                  final horizontalSnaps = _getSnapPositions(type, true);
                  final verticalSnaps = _getSnapPositions(type, false);

                  newX = _findSnapPosition(newX, horizontalSnaps);
                  final rightEdge = newX + pos['w']!;
                  final snappedRight =
                      _findSnapPosition(rightEdge, horizontalSnaps);
                  if (rightEdge != snappedRight) {
                    newX = snappedRight - pos['w']!;
                  }

                  newY = _findSnapPosition(newY, verticalSnaps);
                  final bottomEdge = newY + pos['h']!;
                  final snappedBottom =
                      _findSnapPosition(bottomEdge, verticalSnaps);
                  if (bottomEdge != snappedBottom) {
                    newY = snappedBottom - pos['h']!;
                  }
                }

                // Ограничиваем движение границами экрана
                newX = newX.clamp(0.0, selectedSize.width - pos['w']!);
                newY = newY.clamp(0.0, selectedSize.height - pos['h']!);

                setState(() {
                  pos['x'] = newX;
                  pos['y'] = newY;
                });
                _saveSettings();
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  color: _getWidgetColor(type).withOpacity(0.3),
                ),
              ),
            ),
            // Подпись
            Positioned(
              left: 5,
              top: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getWidgetTitle(type),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            // Маркеры изменения размера
            _buildResizeHandle(pos, scale, 'right'),
            _buildResizeHandle(pos, scale, 'bottom'),
            _buildResizeHandle(pos, scale, 'corner'),
          ],
        ),
      ),
    );
  }

  Widget _buildResizeHandle(
      Map<String, double> pos, double scale, String type) {
    switch (type) {
      case 'right':
        return Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              onPanUpdate: (details) {
                final newW = (pos['w']! + details.delta.dx / scale)
                    .clamp(100.0, selectedSize.width - pos['x']!);
                setState(() {
                  pos['w'] = newW;
                });
                _saveSettings();
              },
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                ),
              ),
            ),
          ),
        );
      case 'bottom':
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeUpDown,
            child: GestureDetector(
              onPanUpdate: (details) {
                final newH = (pos['h']! + details.delta.dy / scale)
                    .clamp(100.0, selectedSize.height - pos['y']!);
                setState(() {
                  pos['h'] = newH;
                });
                _saveSettings();
              },
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                ),
              ),
            ),
          ),
        );
      case 'corner':
        return Positioned(
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeDownRight,
            child: GestureDetector(
              onPanUpdate: (details) {
                final newW = (pos['w']! + details.delta.dx / scale)
                    .clamp(100.0, selectedSize.width - pos['x']!);
                final newH = (pos['h']! + details.delta.dy / scale)
                    .clamp(100.0, selectedSize.height - pos['y']!);
                setState(() {
                  pos['w'] = newW;
                  pos['h'] = newH;
                });
                _saveSettings();
              },
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getWidgetColor(String type) {
    switch (type) {
      case 'loyalty':
        return settings.loyaltyWidgetColor;
      case 'payment':
        return settings.paymentWidgetColor;
      case 'summary':
        return settings.summaryWidgetColor;
      case 'items':
        return settings.itemsWidgetColor;
      case 'sideAdvert':
        return Colors.transparent;
      default:
        return Colors.white;
    }
  }

  String _getWidgetTitle(String type) {
    switch (type) {
      case 'loyalty':
        return 'Виджет лояльности';
      case 'payment':
        return 'QR-код оплаты';
      case 'summary':
        return 'Итого';
      case 'sideAdvert':
        return 'Боковая реклама';
      case 'items':
        return 'Таблица товаров';
      case 'advert':
        return 'Реклама без продаж';
      default:
        return '';
    }
  }

  void _resetSettings() {
    setState(() {
      videoFilePath = '';
      videoUrl = '';
      isVideoFromInternet = true;
      showLoyaltyWidget = true;
      backgroundColor = Colors.white;
      borderColor = Colors.black;
      backgroundImagePath = '';
      useBackgroundImage = false;
      logoPath = '';
      showAdvertWithoutSales = true;
      showSideAdvert = false;
      sideAdvertVideoPath = '';
      isSideAdvertFromInternet = true;
      sideAdvertVideoUrl = '';
      widgetPositions.clear();
      widgetPositions.addAll({
        'loyalty': {'x': 0.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
        'payment': {'x': 1130.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
        'summary': {'x': 1130.0, 'y': 904.0, 'w': 150.0, 'h': 120.0},
        'items': {'x': 200.0, 'y': 150.0, 'w': 880.0, 'h': 874.0},
        'sideAdvert': {'x': 0.0, 'y': 150.0, 'w': 200.0, 'h': 874.0},
        'logo': {
          'x': 10.0,
          'y': 10.0,
          'w': 100.0,
          'h': 50.0
        }, // Добавляем позицию для логотипа
      });
    });
    _saveSettings();
  }

  Future<void> _exportSettings() async {
    try {
      // Загружаем текущие настройки из файла
      final currentSettings = await AppSettings.loadSettings();

      // Получаем путь для сохранения
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить настройки',
        fileName: 'settings.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (result != null) {
        // Конвертируем настройки в JSON
        final jsonSettings = jsonEncode(currentSettings.toJson());

        // Сохраняем в выбранный файл
        await File(result).writeAsString(jsonSettings);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Настройки успешно экспортированы')),
          );
        }
      }
    } catch (e) {
      log('Error exporting settings: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при экспорте настроек')),
        );
      }
    }
  }

  Future<void> _importSettings() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final importedSettings = jsonDecode(jsonString);

        // Создаем объект AppSettings вместо Settings
        final newSettings = AppSettings.fromJson(importedSettings);

        await AppSettings.saveSettings(newSettings);

        setState(() {
          settings = newSettings;
          _loadSettings();
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Настройки успешно импортированы')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LaunchWindow()),
          );
        }
      }
    } catch (e) {
      log('Error importing settings: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при импорте настроек')),
        );
      }
    }
  }

  // Метод для проверки пересечения с другими виджетами
  bool _checkWidgetOverlap(
      String type, double x, double y, double w, double h) {
    for (var otherType in widgetPositions.keys) {
      // Пропускаем сам виджет и неактивные виджеты
      if (otherType == type || !_isWidgetActive(otherType)) continue;

      final otherPos = widgetPositions[otherType]!;
      if (_doBoxesOverlap(x, y, w, h, otherPos['x']!, otherPos['y']!,
          otherPos['w']!, otherPos['h']!)) {
        return true;
      }
    }
    return false;
  }

  // Вспомогательный метод для проверки активности виджета
  bool _isWidgetActive(String type) {
    switch (type) {
      case 'loyalty':
        return showLoyaltyWidget;
      case 'payment':
        return showPaymentQR;
      case 'summary':
        return showSummary;
      case 'sideAdvert':
        return showSideAdvert;
      case 'items':
        return true; // Таблица товаров всегда активна
      default:
        return true;
    }
  }

  // Метод для проверки пересечения двух прямоугольников
  bool _doBoxesOverlap(double x1, double y1, double w1, double h1, double x2,
      double y2, double w2, double h2) {
    return (x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2);
  }

  // метод для получения размеров из строки разрешения
  Size _getSelectedSize() {
    return previewSize; // Используем актуальные размеры из previewSize
  }

  // метод для пересчета позиций виджетов
  void _adjustWidgetPositions() {
    final selectedSize = _getSelectedSize();

    // Обрабатываем логотип
    final maxLogoX = selectedSize.width - logoPosition['w']!;
    final maxLogoY = selectedSize.height - logoPosition['h']!;

    logoPosition['x'] =
        logoPosition['x']!.clamp(0.0, maxLogoX > 0 ? maxLogoX : 0.0);
    logoPosition['y'] =
        logoPosition['y']!.clamp(0.0, maxLogoY > 0 ? maxLogoY : 0.0);
    logoPosition['w'] = logoPosition['w']!.clamp(50.0, selectedSize.width);
    logoPosition['h'] = logoPosition['h']!.clamp(50.0, selectedSize.height);

    // Обрабатываем остальные виджеты
    for (var widget in widgetPositions.entries) {
      final pos = widget.value;
      final maxX = selectedSize.width - pos['w']!;
      final maxY = selectedSize.height - pos['h']!;

      pos['x'] = pos['x']!.clamp(0.0, maxX > 0 ? maxX : 0.0);
      pos['y'] = pos['y']!.clamp(0.0, maxY > 0 ? maxY : 0.0);
      pos['w'] = pos['w']!.clamp(100.0, selectedSize.width);
      pos['h'] = pos['h']!.clamp(100.0, selectedSize.height);
    }

    setState(() {}); // Обновляем UI после изменений
  }

  Widget _buildSettingButton(
      String title, IconData icon, VoidCallback onPressed) {
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(title),
      onPressed: onPressed,
    );
  }

  void _showSettingsPanel(String panel) {
    // Implementation of _showSettingsPanel method
  }

  Widget _buildSettingsPanel() {
    // Implementation of _buildSettingsPanel method
    return Container(); // Placeholder return, actual implementation needed
  }

  Future<void> _updateAutoStart(bool value) async {
    setState(() {
      autoStart = value;
    });
    await settings.setAutoStart(value);
    _saveSettings();
  }

  // Получение размеров второго монитора
  Future<Size> getSecondMonitorSize() async {
    final screens = await ScreenRetriever.instance.getAllDisplays();
    if (screens.length > 1) {
      // Если есть второй экран, возвращаем его размеры
      final secondScreen = screens[1];
      return Size(secondScreen.size.width, secondScreen.size.height);
    }
    // Если второго экрана нет, возвращаем размеры первого
    final firstScreen = screens[0];
    return Size(firstScreen.size.width, firstScreen.size.height);
  }

  // Метод для построения предварительного просмотра
  Widget _buildPreview() {
    final selectedSize = _getSelectedSize();
    final containerWidth = MediaQuery.of(context).size.width * 0.5;
    final containerHeight = MediaQuery.of(context).size.height * 0.8;

    final scale = math.min(containerWidth / selectedSize.width,
        containerHeight / selectedSize.height);

    return Column(
      children: [
        const Text('Предварительный просмотр',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: InteractiveViewer(
            constrained: false,
            child: Center(
              child: Container(
                width: selectedSize.width * scale,
                height: selectedSize.height * scale,
                decoration: BoxDecoration(
                  color: settings.useBackgroundImage
                      ? null
                      : settings.backgroundColor,
                  border: Border.all(color: settings.borderColor, width: 2),
                  image: settings.useBackgroundImage &&
                          settings.backgroundImagePath.isNotEmpty &&
                          File(settings.backgroundImagePath).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(settings.backgroundImagePath)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    _buildPreviewWidget('items', scale),
                    if (settings.showLoyaltyWidget)
                      _buildPreviewWidget('loyalty', scale),
                    if (settings.showPaymentQR)
                      _buildPreviewWidget('payment', scale),
                    if (settings.showSummary)
                      _buildPreviewWidget('summary', scale),
                    if (settings.showSideAdvert)
                      _buildPreviewWidget('sideAdvert', scale),
                    if (settings.showLogo &&
                        settings.logoPath.isNotEmpty &&
                        File(settings.logoPath).existsSync())
                      _buildPreviewLogo(scale),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Добавление метода для отображения горячих клавиш
  Widget _buildHotkeysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Назначение горячих клавиш',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildHotkeyItem(
          'Открытие настроек',
          settings.openSettingsHotkey,
          () {
            // Логика для изменения горячей клавиши
          },
        ),
        _buildHotkeyItem(
          'Закрытие основного окна и открытие LaunchWindow',
          settings.closeMainWindowHotkey,
          () {
            // Логика для изменения горячей клавиши
          },
        ),
      ],
    );
  }

  // Вспомогательный метод для создания элемента горячей клавиши
  Widget _buildHotkeyItem(String title, String hotkey, VoidCallback onPressed) {
    return ListTile(
      title: Text(title),
      subtitle: Text(hotkey),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          // Показываем диалог для изменения горячей клавиши
          String? newHotkey = await _showHotkeyDialog(hotkey);
          if (newHotkey != null) {
            setState(() {
              if (title == 'Открытие настроек') {
                settings.openSettingsHotkey = newHotkey;
              } else if (title ==
                  'Закрытие основного окна и открытие LaunchWindow') {
                settings.closeMainWindowHotkey = newHotkey;
              }
            });
            AppSettings.saveSettings(settings); // Сохраняем изменения
          }
        },
      ),
    );
  }

  // Метод для отображения диалога изменения горячей клавиши
  Future<String?> _showHotkeyDialog(String currentHotkey) async {
    TextEditingController controller =
        TextEditingController(text: currentHotkey);
    bool isRecording = false;
    String newHotkey = currentHotkey;

    void handleKeyEvent(RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        List<String> keys = [];

        // Добавляем модификаторы
        if (event.isControlPressed) keys.add('Ctrl');
        if (event.isShiftPressed) keys.add('Shift');
        if (event.isAltPressed) keys.add('Alt');

        // Добавляем основную клавишу
        String keyLabel = event.logicalKey.keyLabel;
        // Проверяем, не является ли клавиша модификатором
        if (!['Control', 'Shift', 'Alt'].contains(keyLabel)) {
          keys.add(keyLabel.toUpperCase());
        }

        if (keys.isNotEmpty) {
          newHotkey = keys.join(' + ');
          controller.text = newHotkey;
        }
      }
    }

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (isRecording) {
              RawKeyboard.instance.addListener(handleKeyEvent);
            } else {
              RawKeyboard.instance.removeListener(handleKeyEvent);
            }

            return AlertDialog(
              title: const Text('Изменить горячую клавишу'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText:
                          'Нажмите кнопку "Записать" и введите комбинацию клавиш',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isRecording ? Icons.stop : Icons.fiber_manual_record,
                          color: isRecording ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isRecording = !isRecording;
                          });
                        },
                      ),
                    ),
                  ),
                  if (isRecording)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Запись комбинации клавиш...',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Отмена'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Сохранить'),
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAdvertisingSection() {
    return ExpansionTile(
      title: const Row(
        children: [
          Icon(Icons.video_library),
          SizedBox(width: 10),
          Text('Основная реклама'),
        ],
      ),
      children: [
        // Показывать рекламу без продаж
        SwitchListTile(
          title: const Text('Показывать рекламу без продаж'),
          activeColor: const Color(0xFF3579A6),
          value: settings.showAdvertWithoutSales,
          onChanged: (bool value) {
            setState(() {
              settings = _updateSettings(
                showAdvertWithoutSales: value,
              );
            });
          },
        ),
        if (settings.showAdvertWithoutSales) ...[
          SwitchListTile(
            title: const Text('Видео из интернета'),
            activeColor: const Color(0xFF3579A6),
            value: settings.isAdvertFromInternet,
            onChanged: (bool value) {
              setState(() {
                settings = _updateSettings(
                  isAdvertFromInternet: value,
                );
              });
            },
          ),
          if (settings.isAdvertFromInternet)
            ListTile(
              title: TextField(
                decoration: const InputDecoration(labelText: 'URL видео'),
                controller: TextEditingController(
                    text: settings
                        .advertVideoUrl), // Используем controller вместо value
                onChanged: (value) {
                  setState(() {
                    settings = _updateSettings(advertVideoUrl: value);
                  });
                },
              ),
            )
          else
            ListTile(
              title: const Text('Выбрать видео'),
              subtitle: Text(settings.advertVideoPath.isEmpty
                  ? 'Видео не выбрано'
                  : settings.advertVideoPath),
              trailing: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.video,
                  );
                  if (result != null) {
                    setState(() {
                      settings = _updateSettings(
                        advertVideoPath: result.files.single.path!,
                      );
                    });
                  }
                },
              ),
            ),
        ],
      ],
    );
  }

  void _previewVideo(String source, bool isFromInternet) {
    if (source.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите видео или укажите URL')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Предпросмотр видео'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: _VideoPreview(
            videoSource: source,
            isFromInternet: isFromInternet,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  AppSettings _updateSettings({
    String? logoPath,
    String? advertVideoPath,
    String? advertVideoUrl,
    bool? useBackgroundImage,
    String? backgroundImagePath,
    bool? isAdvertFromInternet,
    bool? showAdvertWithoutSales,
    String? sideAdvertType,
    String? sideAdvertPath,
    bool? showSideAdvert,
    String? sideAdvertVideoPath,
    bool? isSideAdvertFromInternet,
    String? sideAdvertVideoUrl,
    Color? commonWidgetColor,
    bool? useCommonWidgetColor,
    Color? loyaltyWidgetColor,
    Color? paymentWidgetColor,
    Color? summaryWidgetColor,
    Color? itemsWidgetColor,
    double? loyaltyFontSize,
    double? paymentFontSize,
    double? summaryFontSize,
    double? itemsFontSize,
    Color? loyaltyFontColor,
    Color? paymentFontColor,
    Color? summaryFontColor,
    Color? itemsFontColor,
    String? customFontPath,
    String? fontFamily,
    Map<String, Map<String, double>>? widgetPositions,
    bool? showLogo,
    bool? showPaymentQR,
    bool? showSummary,
    bool? showLoyaltyWidget,
  }) {
    final newSettings = settings.copyWith(
      logoPath: logoPath ?? settings.logoPath,
      advertVideoPath: advertVideoPath ?? settings.advertVideoPath,
      advertVideoUrl: advertVideoUrl ?? settings.advertVideoUrl,
      useBackgroundImage: useBackgroundImage ?? settings.useBackgroundImage,
      backgroundImagePath: backgroundImagePath ?? settings.backgroundImagePath,
      isAdvertFromInternet:
          isAdvertFromInternet ?? settings.isAdvertFromInternet,
      showAdvertWithoutSales:
          showAdvertWithoutSales ?? settings.showAdvertWithoutSales,
      sideAdvertType: sideAdvertType ?? settings.sideAdvertType,
      sideAdvertPath: sideAdvertPath ?? settings.sideAdvertPath,
      showSideAdvert: showSideAdvert ?? settings.showSideAdvert,
      sideAdvertVideoPath: sideAdvertVideoPath ?? settings.sideAdvertVideoPath,
      isSideAdvertFromInternet:
          isSideAdvertFromInternet ?? settings.isSideAdvertFromInternet,
      sideAdvertVideoUrl: sideAdvertVideoUrl ?? settings.sideAdvertVideoUrl,
      commonWidgetColor: commonWidgetColor ?? settings.commonWidgetColor,
      useCommonWidgetColor:
          useCommonWidgetColor ?? settings.useCommonWidgetColor,
      loyaltyWidgetColor: loyaltyWidgetColor ?? settings.loyaltyWidgetColor,
      paymentWidgetColor: paymentWidgetColor ?? settings.paymentWidgetColor,
      summaryWidgetColor: summaryWidgetColor ?? settings.summaryWidgetColor,
      itemsWidgetColor: itemsWidgetColor ?? settings.itemsWidgetColor,
      loyaltyFontSize: loyaltyFontSize ?? settings.loyaltyFontSize,
      paymentFontSize: paymentFontSize ?? settings.paymentFontSize,
      summaryFontSize: summaryFontSize ?? settings.summaryFontSize,
      itemsFontSize: itemsFontSize ?? settings.itemsFontSize,
      loyaltyFontColor: loyaltyFontColor ?? settings.loyaltyFontColor,
      paymentFontColor: paymentFontColor ?? settings.paymentFontColor,
      summaryFontColor: summaryFontColor ?? settings.summaryFontColor,
      itemsFontColor: itemsFontColor ?? settings.itemsFontColor,
      customFontPath: customFontPath ?? settings.customFontPath,
      fontFamily: fontFamily ?? settings.fontFamily,
      widgetPositions: widgetPositions ?? settings.widgetPositions,
      showLogo: showLogo ?? settings.showLogo,
      showPaymentQR: showPaymentQR ?? settings.showPaymentQR,
      showSummary: showSummary ?? settings.showSummary,
      showLoyaltyWidget: showLoyaltyWidget ?? settings.showLoyaltyWidget,
    );

    AppSettings.saveSettings(newSettings); // Автоматически сохраняем настройки
    return newSettings;
  }

  double _getScale() {
    const selectedSize =
        Size(1920, 1080); // Используем фиксированное разрешение
    return MediaQuery.of(context).size.width * 0.5 / selectedSize.width;
  }

  // В _SettingsWindowState добавим метод для сохранения настроек боковой рекламы
  void _saveSideAdvertSettings() async {
    if (_selectedVideoPath.isEmpty) {
      log('Error: Selected video path is empty');
      return;
    }

    settings = settings.copyWith(
      showSideAdvert: true,
      sideAdvertType: 'video',
      sideAdvertVideoPath: _selectedVideoPath,
      sideAdvertPath: _selectedVideoPath,
      isSideAdvertContentFromInternet: false,
    );

    await AppSettings.saveSettings(settings); // Исправлено здесь
  }

  String _selectedVideoPath = '';

  // В методе build добавим секцию для боковой рекламы
  Widget _buildSideAdvertSection() {
    return ExpansionTile(
      title: const Row(
        children: [
          Icon(Icons.video_library),
          SizedBox(width: 10),
          Text('Боковая реклама'),
        ],
      ),
      children: [
        SwitchListTile(
          title: const Text('Показывать боковую рекламу'),
          activeColor: const Color(0xFF3579A6),
          value: settings.showSideAdvert,
          onChanged: (value) {
            setState(() {
              settings = settings.copyWith(showSideAdvert: value);
              AppSettings.saveSettings(settings); // И здесь
            });
          },
        ),
        if (settings.showSideAdvert) ...[
          ListTile(
            title: const Text('Выбрать видео'),
            subtitle: Text(settings.sideAdvertVideoPath.isEmpty
                ? 'Видео не выбрано'
                : settings.sideAdvertVideoPath),
            trailing: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                );
                if (result != null) {
                  final path = result.files.single.path!;
                  log('Selected video path: $path');

                  setState(() {
                    settings = settings.copyWith(
                      showSideAdvert: true,
                      sideAdvertType: 'video',
                      sideAdvertVideoPath: path,
                      sideAdvertPath: path,
                      isSideAdvertContentFromInternet: false,
                    );
                  });

                  // Сразу сохраняем настройки
                  await AppSettings.saveSettings(settings);

                  // Проверяем сохраненные значения
                  log('After save:');
                  log('Type: ${settings.sideAdvertType}');
                  log('VideoPath: ${settings.sideAdvertVideoPath}');
                  log('Path: ${settings.sideAdvertPath}');
                }
              },
            ),
          ),
          ListTile(
            // Добавляем новый ListTile для изображения
            title: const Text('Выбрать изображение'),
            subtitle: Text(settings.sideAdvertPath.isEmpty
                ? 'Изображение не выбрано'
                : settings.sideAdvertPath),
            trailing: IconButton(
              icon: const Icon(Icons.image),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                );
                if (result != null) {
                  final path = result.files.single.path!;
                  setState(() {
                    settings = settings.copyWith(
                      showSideAdvert: true,
                      sideAdvertType: 'image',
                      sideAdvertVideoPath: '', // Очищаем путь к видео
                      sideAdvertPath: path,
                      isSideAdvertContentFromInternet: false,
                    );
                  });
                  await AppSettings.saveSettings(settings);
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectBackgroundColor(BuildContext context) async {
    final color = await showColorPicker(
      context: context,
      color: backgroundColor,
    );
    if (color != null) {
      setState(() {
        backgroundColor = color;
      });
      _saveSettings();
    }
  }

  Future<void> _selectBorderColor(BuildContext context) async {
    final color = await showColorPicker(
      context: context,
      color: borderColor,
    );
    if (color != null) {
      setState(() {
        borderColor = color;
      });
      _saveSettings();
    }
  }

  Widget _buildWidgetSettings() {
    return ExpansionTile(
      title: const Row(
        children: [
          Icon(Icons.widgets),
          SizedBox(width: 10),
          Text('Настройки виджетов'),
        ],
      ),
      children: [
        // Настройки логотипа
        SwitchListTile(
          title: const Text('Показывать логотип'),
          activeColor: const Color(0xFF3579A6),
          value: settings.showLogo,
          onChanged: (value) {
            setState(() {
              settings = settings.copyWith(showLogo: value);
              AppSettings.saveSettings(settings);
            });
          },
        ),
        if (settings.showLogo) ...[
          const Divider(),
          ListTile(
            title: const Text('Выбрать изображение'),
            subtitle: Text(settings.logoPath.isEmpty
                ? 'Логотип не выбран'
                : settings.logoPath),
            trailing: const Icon(Icons.folder_open),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowedExtensions: ['png', 'jpg', 'jpeg'],
              );
              if (result != null) {
                setState(() {
                  settings = _updateSettings(
                    logoPath: result.files.single.path!,
                  );
                });
              }
            },
          ),
        ],

        // Остальные настройки виджетов
        SwitchListTile(
          title: const Text('Показывать QR-код оплаты'),
          activeColor: const Color(0xFF3579A6),
          value: settings.showPaymentQR,
          onChanged: (value) {
            setState(() {
              settings = settings.copyWith(showPaymentQR: value);
              AppSettings.saveSettings(settings);
            });
          },
        ),
        SwitchListTile(
          title: const Text('Показывать итоги'),
          activeColor: const Color(0xFF3579A6),
          value: settings.showSummary,
          onChanged: (value) {
            setState(() {
              settings = settings.copyWith(showSummary: value);
              AppSettings.saveSettings(settings);
            });
          },
        ),
      ],
    );
  }

  // В классе _SettingsWindowState добавим метод для предпросмотра логотипа
  Widget _buildPreviewLogo(double scale) {
    if (!settings.showLogo ||
        settings.logoPath.isEmpty ||
        !File(settings.logoPath).existsSync()) {
      return const SizedBox.shrink();
    }

    final pos = Map<String, double>.from(widgetPositions['logo'] ??
        {
          'x': 10.0,
          'y': 10.0,
          'w': 100.0,
          'h': 50.0,
        });

    return Positioned(
      left: pos['x']! * scale,
      top: pos['y']! * scale,
      width: pos['w']! * scale,
      height: pos['h']! * scale,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              pos['x'] = pos['x']! + details.delta.dx / scale;
              pos['y'] = pos['y']! + details.delta.dy / scale;
              widgetPositions['logo'] = pos;
              settings = settings.copyWith(widgetPositions: widgetPositions);
              AppSettings.saveSettings(settings);
            });
          },
          child: CustomResizableWidget(
            onResize: (dx, dy) {
              setState(() {
                pos['w'] = pos['w']! + dx / scale;
                pos['h'] = pos['h']! + dy / scale;
                widgetPositions['logo'] = pos;
                settings = settings.copyWith(widgetPositions: widgetPositions);
                AppSettings.saveSettings(settings);
              });
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                image: DecorationImage(
                  image: FileImage(File(settings.logoPath)),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final String videoSource;
  final bool isFromInternet;

  const _VideoPreview({
    required this.videoSource,
    required this.isFromInternet,
  });

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoManager _videoManager;

  @override
  void initState() {
    super.initState();
    _videoManager = VideoManager();
    _initVideo();
  }

  Future<void> _initVideo() async {
    await _videoManager.initialize(
      isVideoFromInternet: widget.isFromInternet,
      videoSource: widget.videoSource,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _videoManager.buildVideoPlayer(context),
    );
  }
}
