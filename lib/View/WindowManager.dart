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

// Окно настроек приложения
class SettingsWindow extends StatefulWidget {
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

  const SettingsWindow({super.key});

  @override
  _SettingsWindowState createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
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
    getSecondMonitorSize().then((size) {
      setState(() {
        previewSize = size;
        _adjustWidgetPositions(); // Пересчет позиций под новый размер
      });
    });
    _initSettings();
  }

  // Инициализация настроек
  Future<void> _initSettings() async {
    final loadedSettings = await AppSettings.loadSettings();
    setState(() {
      settings = loadedSettings;
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // Загрузка настроек из хранилища
  void _loadSettings() async {
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
        });
      } else {
        widgetPositions.addAll(settings.widgetPositions);
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
    });
  }

  // Сохранение настроек в хранилище
  Future<void> _saveSettings() async {
    // Обновляем настройки перед сохранением
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
      sideAdvertVideoPath: sideAdvertVideoPath,
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
    );

    await settings.saveSettings();
  }

  // Выбор видеофайла
  Future<void> _selectVideoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        videoFilePath = result.files.single.path!;
      });
      await _saveSettings();
      _resetInactivityTimer();
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
        }
      });
      await _saveSettings();
      _resetInactivityTimer();
    }
  }

  // Запуск таймера бездействия
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    if (useInactivityTimer && !isInSettings) {  // Используем флаг вместо проверки маршрута
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
  void _launchSecondMonitor(BuildContext context) {
    _saveSettings();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SecondMonitor(
          settings: AppSettings(
            
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
            sideAdvertVideoPath: sideAdvertVideoPath,
            isSideAdvertFromInternet: isSideAdvertFromInternet,
            sideAdvertVideoUrl: sideAdvertVideoUrl,
            widgetPositions: widgetPositions,
            logoPosition: logoPosition,
            autoStart: autoStart,
            useInactivityTimer: useInactivityTimer,
            inactivityTimeout: inactivityTimeout,
            webSocketUrl: webSocketUrl,
            httpUrl: httpUrl,
            isVersion85: isVersion85,
            webSocketPort: webSocketPort,
            httpPort: httpPort,
          ),
        ),
      ),
    );
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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Настройки'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LaunchWindow()),
              );
            },
          ),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Запустить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _launchSecondMonitor(context),
            ),
            const SizedBox(width: 16),
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
                        initiallyExpanded: true,
                        title: const Text('Настройки экрана', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.monitor),
          children: [
        SwitchListTile(
                            secondary: const Icon(Icons.fullscreen),
                            title: const Text('Полноэкранный режим'),
                            value: false,
          onChanged: (value) {
            setState(() {
                                // isFullScreen = value;
            });
            _saveSettings();
                            },
              ),
            ],
          ),
                      // Оформление
                      ExpansionTile(
                        title: const Text('Оформление', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.palette),
            children: [
          ListTile(
            title: const Text('Цвет фона'),
            trailing: Container(
                              width: 24,
                              height: 24,
                color: backgroundColor,
            ),
            onTap: () async {
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
            },
          ),
        ListTile(
          title: const Text('Цвет рамки'),
          trailing: Container(
                              width: 24,
                              height: 24,
              color: borderColor,
          ),
          onTap: () async {
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
          },
        ),
                          SwitchListTile(
                            title: const Text('Использовать фоновое изображение'),
                            value: useBackgroundImage,
                            onChanged: (value) {
                              setState(() {
                                useBackgroundImage = value;
                              });
                              _saveSettings();
                            },
                          ),
                          if (useBackgroundImage)
                            ListTile(
                              title: const Text('Выбрать фоновое изображение'),
                              trailing: const Icon(Icons.image),
                              onTap: () => _selectImage('background'),
                            ),
                          if (showLogo)
                            ListTile(
                              title: const Text('Выбрать логотип'),
                              trailing: const Icon(Icons.image),
                              onTap: () => _selectImage('logo'),
                            ),
                        ],
                      ),
                      // Виджеты
                      ExpansionTile(
                        title: const Row(
                          children: [
                            Icon(Icons.widgets),
                            SizedBox(width: 10),
                            Text('Виджеты'),
                          ],
                        ),
                        children: [
                          // Управление видимостью виджетов
                          SwitchListTile(
                            title: const Text('Логотип'),
                            value: showLogo,
                            onChanged: (value) {
                              setState(() {
                                showLogo = value;
                              });
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Программа лояльности'),
                            value: showLoyaltyWidget,
                            onChanged: (value) {
                              setState(() {
                                showLoyaltyWidget = value;
                              });
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text('QR-код оплаты'),
                            value: showPaymentQR,
                            onChanged: (value) {
                              setState(() {
                                showPaymentQR = value;
                              });
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Итоговая сумма'),
                            value: showSummary,
                            onChanged: (value) {
                              setState(() {
                                showSummary = value;
                              });
                              _saveSettings();
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Боковая реклама'),
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
                            SwitchListTile(
                              title: const Text('Видео из интернета'),
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
                                  controller: TextEditingController(text: sideAdvertVideoUrl),
                                  decoration: const InputDecoration(
                                    labelText: 'URL видео',
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
                                title: const Text('Выбрать видео'),
                                trailing: const Icon(Icons.video_library),
                                onTap: _selectSideAdvertVideo,
                              ),
                          ],
                          const Divider(),
                          // Настройки цветов
                          ExpansionTile(
                            title: const Row(
                              children: [
                                Icon(Icons.palette),
                                SizedBox(width: 10),
                                Text('Цвета виджетов'),
                              ],
                            ),
                            children: [
                              // Общий цвет для всех виджетов
                              ListTile(
                                title: const Text('Общий цвет виджетов'),
                                trailing: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: settings.loyaltyWidgetColor,
                                    border: Border.all(color: Colors.grey),
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
                                        loyaltyWidgetColor: color,
                                        paymentWidgetColor: color,
                                        summaryWidgetColor: color,
                                        itemsWidgetColor: color,
                                      );
                                    });
                                    _saveSettings();
                                  }
                                },
                              ),
                              const Divider(),
                              // Индивидуальные цвета
                              if (showLoyaltyWidget)
                                ListTile(
                                  title: const Text('Цвет виджета лояльности'),
                                  trailing: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: settings.loyaltyWidgetColor,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                  ),
                                  onTap: () async {
                                    final color = await showColorPicker(
                                      context: context,
                                      color: settings.loyaltyWidgetColor,
                                    );
                                    if (color != null) {
                                      setState(() {
                                        settings = _updateSettings(loyaltyWidgetColor: color);
                                      });
                                      _saveSettings();
                                    }
                                  },
                                ),
                              if (showPaymentQR)
                                ListTile(
                                  title: const Text('Цвет виджета QR-кода'),
                                  trailing: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: settings.paymentWidgetColor,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                  ),
                                  onTap: () async {
                                    final color = await showColorPicker(
                                      context: context,
                                      color: settings.paymentWidgetColor,
                                    );
                                    if (color != null) {
                                      setState(() {
                                        settings = _updateSettings(paymentWidgetColor: color);
                                      });
                                      _saveSettings();
                                    }
                                  },
                                ),
                              if (showSummary)
                                ListTile(
                                  title: const Text('Цвет виджета итогов'),
                                  trailing: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: settings.summaryWidgetColor,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                  ),
                                  onTap: () async {
                                    final color = await showColorPicker(
                                      context: context,
                                      color: settings.summaryWidgetColor,
                                    );
                                    if (color != null) {
                                      setState(() {
                                        settings = _updateSettings(summaryWidgetColor: color);
                                      });
                                      _saveSettings();
                                    }
                                  },
                                ),
                              ListTile(
                                title: const Text('Цвет таблицы товаров'),
                                trailing: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: settings.itemsWidgetColor,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                                onTap: () async {
                                  final color = await showColorPicker(
                                    context: context,
                                    color: settings.itemsWidgetColor,
                                  );
                                  if (color != null) {
                                    setState(() {
                                      settings = _updateSettings(itemsWidgetColor: color);
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
                                Icon(Icons.text_fields),
                                SizedBox(width: 10),
                                Text('Настройки шрифта'),
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
                                  final result = await FilePicker.platform.pickFiles(
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
                                    final newStyle = await FontManager.loadCustomFont(path, baseStyle);
                                    
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
                                subtitle: const Text('Применится ко всем виджетам'),
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
                                subtitle: const Text('Применится ко всем виджетам'),
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
                              // Остальные настройки шрифта...
                              // ... существующий код ...
                            ],
                          ),
                        ],
                      ),
                      // Реклама
                      ExpansionTile(
                        title: const Row(
                          children: [
                            Icon(Icons.video_library),
                            SizedBox(width: 10),
                            Text('Реклама'),
                          ],
                        ),
                        children: [
                          // Реклама без продаж
                          SwitchListTile(
                            title: const Text('Показывать рекламу без продаж'),
                            value: showAdvertWithoutSales,
                            onChanged: (bool value) {
                              setState(() {
                                showAdvertWithoutSales = value;
                              });
                              _saveSettings();
                            },
                          ),
                          if (showAdvertWithoutSales) ...[
                            SwitchListTile(
                              title: const Text('Видео из интернета'),
                              value: isVideoFromInternet,
                              onChanged: (bool value) {
                                setState(() {
                                  isVideoFromInternet = value;
                                });
                                _saveSettings();
                              },
                            ),
                            if (isVideoFromInternet)
                              ListTile(
                                title: TextField(
                                  controller: TextEditingController(text: videoUrl),
                                  decoration: const InputDecoration(
                                    labelText: 'URL видео',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      videoUrl = value;
                                    });
                                    _saveSettings();
                                  },
                                ),
                              )
                            else
                              ListTile(
                                title: const Text('Выбрать видео'),
                                trailing: const Icon(Icons.video_library),
                                onTap: () async {
                                  final result = await FilePicker.platform.pickFiles(
                                    type: FileType.video,
                                    allowMultiple: false,
                                  );
                                  if (result != null) {
                                    setState(() {
                                      videoFilePath = result.files.single.path ?? '';
                                    });
                                    _saveSettings();
                                  }
                                },
                              ),
                          ],
                        ],
                      ),
                      // Безопасность
                      ExpansionTile(
                        title: const Text('Безопасность', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.security),
                        children: [
        SwitchListTile(
                            title: const Text('Использовать таймер неактивности'),
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
                                    inactivityTimeout = int.tryParse(value) ?? 50;
            });
            _saveSettings();
                                },
                                controller: TextEditingController(text: inactivityTimeout.toString()),
                              ),
                            ),
                        ],
                      ),
                      // Общие настройки
                      ExpansionTile(
                        title: const Text('Общие настройки', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.settings),
                        children: [
                          SwitchListTile(
                            title: const Text('Автозапуск'),
                            subtitle: const Text('Запускать приложение при старте Windows'),
                            value: autoStart,
                            onChanged: _updateAutoStart,
                          ),
                        ],
                      ),
                      // Горячие клавиши
                      ExpansionTile(
                        title: const Text('Горячие клавиши', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: const Icon(Icons.keyboard),
                        children: [
                          _buildHotkeysSection(),
                        ],
                      ),
                      // Настройки подключения
                      ExpansionTile(
                        title: const Text('Настройки подключения', 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        leading: const Icon(Icons.settings_ethernet),
                        children: [
                          SwitchListTile(
                            title: const Text('Использовать 1С 8.5'),
                            subtitle: const Text('Работа напрямую через WebSocket'),
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
                              icon: const Icon(Icons.file_upload),
                              label: const Text('Экспорт'),
                              onPressed: _exportSettings,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.file_download),
                              label: const Text('Импорт'),
                              onPressed: _importSettings,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Сброс'),
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
    
    // Добавляем логотип только если он включен
    if (showLogo && logoPath.isNotEmpty && File(logoPath).existsSync()) {
      final pos = logoPosition;
      widgets.add(
        Positioned(
          left: pos['x']! * scale,
          top: pos['y']! * scale,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                pos['x'] = (pos['x']! + details.delta.dx / scale)
                    .clamp(0.0, selectedSize.width - pos['w']!);
                pos['y'] = (pos['y']! + details.delta.dy / scale)
                    .clamp(0.0, selectedSize.height - pos['h']!);
              });
              _saveSettings();
            },
            child: Stack(
              children: [
                Container(
                  width: pos['w']! * scale,
                  height: pos['h']! * scale,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(logoPath)),
                      fit: BoxFit.contain,
                    ),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
            )],
              
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
                if (speed < 10) { // Порог скорости для активации примагничивания
                  final horizontalSnaps = _getSnapPositions(type, true);
                  final verticalSnaps = _getSnapPositions(type, false);

                  newX = _findSnapPosition(newX, horizontalSnaps);
                  final rightEdge = newX + pos['w']!;
                  final snappedRight = _findSnapPosition(rightEdge, horizontalSnaps);
                  if (rightEdge != snappedRight) {
                    newX = snappedRight - pos['w']!;
                  }

                  newY = _findSnapPosition(newY, verticalSnaps);
                  final bottomEdge = newY + pos['h']!;
                  final snappedBottom = _findSnapPosition(bottomEdge, verticalSnaps);
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

  Widget _buildResizeHandle(Map<String, double> pos, double scale, String type) {
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
      default:
        return Colors.white;
    }
  }

  String _getWidgetTitle(String type) {
    switch (type) {
      case 'loyalty': return 'Виджет лояльности';
      case 'payment': return 'QR-код оплаты';
      case 'summary': return 'Итого';
      case 'sideAdvert': return 'Боковая реклама';
      case 'items': return 'Таблица товаров';
      case 'advert': return 'Реклама без продаж';
      default: return '';
    }
  }

  Future<void> _selectSideAdvertVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        sideAdvertVideoPath = result.files.single.path!;
      });
      _saveSettings();
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
      });
    });
    _saveSettings();
  }

  Future<void> _exportSettings() async {
    try {
      final settings = {
        'videoFilePath': videoFilePath,
        'videoUrl': videoUrl,
        'isVideoFromInternet': isVideoFromInternet,
        'showLoyaltyWidget': showLoyaltyWidget,
        'backgroundColor': backgroundColor.value,
        'borderColor': borderColor.value,
        'backgroundImagePath': backgroundImagePath,
        'useBackgroundImage': useBackgroundImage,
        'logoPath': logoPath,
        'showAdvertWithoutSales': showAdvertWithoutSales,
        'showSideAdvert': showSideAdvert,
        'sideAdvertVideoPath': sideAdvertVideoPath,
        'isSideAdvertFromInternet': isSideAdvertFromInternet,
        'sideAdvertVideoUrl': sideAdvertVideoUrl,
        'widgetPositions': widgetPositions,
        'logoPosition': logoPosition,
        'useInactivityTimer': useInactivityTimer,
        'inactivityTimeout': inactivityTimeout,
        'showLogo': showLogo,
        'showPaymentQR': showPaymentQR,
        'showSummary': showSummary,
        'webSocketUrl': webSocketUrl,
        'httpUrl': httpUrl,
        'isVersion85': isVersion85,
        'webSocketPort': webSocketPort,
        'httpPort': httpPort,
      };

      String jsonString = jsonEncode(settings);
      
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить настройки',
        fileName: 'settings.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        await File(result).writeAsString(jsonString);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Настройки успешно сохранены')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении настроек: $e')),
      );
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
        final settings = jsonDecode(jsonString);

        setState(() {
          videoFilePath = settings['videoFilePath'] ?? '';
          videoUrl = settings['videoUrl'] ?? '';
          isVideoFromInternet = settings['isVideoFromInternet'] ?? true;
          showLoyaltyWidget = settings['showLoyaltyWidget'] ?? true;
          backgroundColor = Color(settings['backgroundColor'] ?? Colors.white.value);
          borderColor = Color(settings['borderColor'] ?? Colors.black.value);
          backgroundImagePath = settings['backgroundImagePath'] ?? '';
          useBackgroundImage = settings['useBackgroundImage'] ?? false;
          logoPath = settings['logoPath'] ?? '';
          showAdvertWithoutSales = settings['showAdvertWithoutSales'] ?? true;
          showSideAdvert = settings['showSideAdvert'] ?? false;
          sideAdvertVideoPath = settings['sideAdvertVideoPath'] ?? '';
          isSideAdvertFromInternet = settings['isSideAdvertFromInternet'] ?? true;
          sideAdvertVideoUrl = settings['sideAdvertVideoUrl'] ?? '';
          widgetPositions.clear();
          final Map<String, dynamic> positions = settings['widgetPositions'] ?? {};
          widgetPositions.addAll(Map<String, Map<String, double>>.from(positions));
          
          final Map<String, dynamic> defaultLogoPos = {
            'x': 10.0, 'y': 10.0, 'w': 100.0, 'h': 50.0,
          };
          logoPosition = Map<String, double>.from(settings['logoPosition'] ?? defaultLogoPos);
          useInactivityTimer = settings['useInactivityTimer'] ?? true;
          inactivityTimeout = settings['inactivityTimeout'] ?? 50;
          showLogo = settings['showLogo'] ?? true;
          showPaymentQR = settings['showPaymentQR'] ?? true;
          showSummary = settings['showSummary'] ?? true;
          webSocketUrl = settings['webSocketUrl'] ?? 'localhost';
          httpUrl = settings['httpUrl'] ?? 'localhost';
          isVersion85 = settings['isVersion85'] ?? false;
          webSocketPort = settings['webSocketPort'] ?? 4002;
          httpPort = settings['httpPort'] ?? 4001;
        });

        _saveSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Настройки успешно загружены')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке настроек: $e')),
      );
    }
  }

  // Метод для проверки пересечения с другими виджетами
  bool _checkWidgetOverlap(String type, double x, double y, double w, double h) {
    for (var otherType in widgetPositions.keys) {
      // Пропускаем сам виджет и неактивные виджеты
      if (otherType == type || !_isWidgetActive(otherType)) continue;

      final otherPos = widgetPositions[otherType]!;
      if (_doBoxesOverlap(
        x, y, w, h,
        otherPos['x']!, otherPos['y']!, otherPos['w']!, otherPos['h']!
      )) {
        return true;
      }
    }
    return false;
  }

  // Вспомогательный метод для проверки активности виджета
  bool _isWidgetActive(String type) {
    switch (type) {
      case 'loyalty': return showLoyaltyWidget;
      case 'payment': return showPaymentQR;
      case 'summary': return showSummary;
      case 'sideAdvert': return showSideAdvert;
      case 'items': return true; // Таблица товаров всегда активна
      default: return true;
    }
  }

  // Метод для проверки пересечения двух прямоугольников
  bool _doBoxesOverlap(
    double x1, double y1, double w1, double h1,
    double x2, double y2, double w2, double h2
  ) {
    return (x1 < x2 + w2 &&
            x1 + w1 > x2 &&
            y1 < y2 + h2 &&
            y1 + h1 > y2);
  }

  // Добавим метод для получения размеров из строки разрешения
  Size _getSelectedSize() {
  return previewSize; // Используем актуальные размеры из previewSize
}


  // Добавим метод для пересчета позиций виджетов
  void _adjustWidgetPositions() {
    final selectedSize = _getSelectedSize();
    
    // Обрабатываем логотип
    final maxLogoX = selectedSize.width - logoPosition['w']!;
    final maxLogoY = selectedSize.height - logoPosition['h']!;
    
    logoPosition['x'] = logoPosition['x']!.clamp(0.0, maxLogoX > 0 ? maxLogoX : 0.0);
    logoPosition['y'] = logoPosition['y']!.clamp(0.0, maxLogoY > 0 ? maxLogoY : 0.0);
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

  Widget _buildSettingButton(String title, IconData icon, VoidCallback onPressed) {
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

    final scale = math.min(containerWidth / selectedSize.width, containerHeight / selectedSize.height);

    final previewWidth = selectedSize.width * scale;
    final previewHeight = selectedSize.height * scale;

    return Column(
      children: [
        const Text('Предварительный просмотр', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 16),
        Expanded(
          child: InteractiveViewer(
            constrained: false,
            child: Center(
              child: Container(
                width: previewWidth,
                height: previewHeight,
                decoration: BoxDecoration(
                  color: useBackgroundImage ? null : backgroundColor,
                  border: Border.all(color: borderColor, width: 2),
                  image: useBackgroundImage && backgroundImagePath.isNotEmpty && 
                         File(backgroundImagePath).existsSync()
                    ? DecorationImage(
                        image: FileImage(File(backgroundImagePath)),
                        fit: BoxFit.cover,
                      )
                    : null,
                ),
                child: Stack(
                  children: _buildPreviewWidgets(scale, selectedSize),
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
              } else if (title == 'Закрытие основного окна и открытие LaunchWindow') {
                settings.closeMainWindowHotkey = newHotkey;
              }
            });
            settings.saveSettings(); // Сохраняем изменения
          }
        },
      ),
    );
  }

  // Метод для отображения диалога изменения горячей клавиши
  Future<String?> _showHotkeyDialog(String currentHotkey) async {
    TextEditingController controller = TextEditingController(text: currentHotkey);
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
                      hintText: 'Нажмите кнопку "Записать" и введите комбинацию клавиш',
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
          Text('Реклама'),
        ],
      ),
      children: [
        // Показывать рекламу без продаж
        SwitchListTile(
          title: const Text('Показывать рекламу без продаж'),
          value: showAdvertWithoutSales,
          onChanged: (bool value) {
            setState(() {
              showAdvertWithoutSales = value;
            });
            _saveSettings();
          },
        ),
        if (showAdvertWithoutSales) ...[
          SwitchListTile(
            title: const Text('Видео из интернета'),
            value: isVideoFromInternet,
            onChanged: (bool value) {
              setState(() {
                isVideoFromInternet = value;
              });
              _saveSettings();
            },
          ),
          if (isVideoFromInternet)
            ListTile(
              title: TextField(
                controller: TextEditingController(text: videoUrl),
                decoration: const InputDecoration(
                  labelText: 'URL видео',
                ),
                onChanged: (value) {
                  setState(() {
                    videoUrl = value;
                  });
                  _saveSettings();
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
    bool? showSideAdvert,
    bool? isSideAdvertFromInternet,
    String? sideAdvertVideoPath,
    String? sideAdvertVideoUrl,
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
  }) {
    final newSettings = AppSettings(
      
      videoFilePath: settings.videoFilePath,
      videoUrl: settings.videoUrl,
      isVideoFromInternet: settings.isVideoFromInternet,
      showLoyaltyWidget: settings.showLoyaltyWidget,
      backgroundColor: settings.backgroundColor,
      borderColor: settings.borderColor,
      backgroundImagePath: settings.backgroundImagePath,
      useBackgroundImage: settings.useBackgroundImage,
      logoPath: settings.logoPath,
      showAdvertWithoutSales: settings.showAdvertWithoutSales,
      showSideAdvert: showSideAdvert ?? settings.showSideAdvert,
      sideAdvertVideoPath: sideAdvertVideoPath ?? settings.sideAdvertVideoPath,
      isSideAdvertFromInternet: isSideAdvertFromInternet ?? settings.isSideAdvertFromInternet,
      sideAdvertVideoUrl: sideAdvertVideoUrl ?? settings.sideAdvertVideoUrl,
      widgetPositions: widgetPositions,
      logoPosition: settings.logoPosition,
      selectedResolution: selectedResolution,
      autoStart: settings.autoStart,
      useInactivityTimer: settings.useInactivityTimer,
      inactivityTimeout: settings.inactivityTimeout,
      webSocketUrl: settings.webSocketUrl,
      httpUrl: settings.httpUrl,
      isVersion85: settings.isVersion85,
      webSocketPort: settings.webSocketPort,
      httpPort: settings.httpPort,
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
      showLogo: settings.showLogo,
      showPaymentQR: settings.showPaymentQR,
      showSummary: settings.showSummary,
      advertVideoPath: settings.advertVideoPath,
      advertVideoUrl: settings.advertVideoUrl,
      isAdvertFromInternet: settings.isAdvertFromInternet,
    );

    newSettings.saveSettings();
    
    return newSettings;
  }

  double _getScale() {
    const selectedSize = Size(1920, 1080); // Используем фиксированное разрешение
    return MediaQuery.of(context).size.width * 0.5 / selectedSize.width;
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
