import 'dart:convert';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show RawKeyDownEvent, RawKeyboard;
import 'package:second_monitor/Service/logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:second_monitor/Service/ScreenManager.dart';
import 'package:second_monitor/Service/VideoManager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:second_monitor/Service/WebSocketService.dart';
import 'package:second_monitor/Model/CheckItem.dart';
import 'package:second_monitor/Model/LoyaltyProgram.dart';
import 'package:second_monitor/Model/PaymentQRCode.dart';
import 'package:second_monitor/Model/Summary.dart';
import 'package:second_monitor/Service/Server.dart';
import 'dart:io';
import 'package:second_monitor/Service/AppSettings.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:second_monitor/View/WindowManager.dart';
import 'package:second_monitor/View/LaunchWindow.dart';
import 'package:video_player_win/video_player_win.dart';
import 'package:second_monitor/Service/FontManager.dart';
import 'package:second_monitor/View/LicenseCheckWidget.dart';

class Settings {
  String brand; // Бренд приложения
  bool fullscreen; // Полноэкранный режим
  String videoFilePath; // Путь к видеофайлу
  String videoUrl; // URL видео
  bool isVideoFromInternet; // Использовать видео из интернета
  bool showLoyaltyWidget; // Показать виджет лояльности
  Color backgroundColor; // Цвет фона
  Color borderColor; // Цвет рамки
  String backgroundImagePath; // Путь к изображению фона
  bool useBackgroundImage; // Использовать изображение фона
  String logoPath; // Путь к логотипу
  bool showSideAdvert; // Показать боковую рекламу
  bool isSideAdvertFromInternet; // Использовать боковую рекламу из интернета
  String sideAdvertVideoPath; // Путь к видео боковой рекламы
  String sideAdvertVideoUrl; // URL видео боковой рекламы
  Map<String, Map<String, double>> widgetPositions; // Позиции виджетов
  bool showAdvertWithoutSales; // Показать рекламу без продаж
  String openSettingsHotkey; // Горячая клавиша для открытия настроек
  String closeMainWindowHotkey; // Горячая клавиша для закрытия окна
  Color loyaltyWidgetColor; // Цвет виджета лояльности
  Color paymentWidgetColor; // Цвет виджета оплаты
  Color summaryWidgetColor; // Цвет виджета итога
  Color itemsWidgetColor; // Цвет виджета таблицы товаров
  String customFontPath; // Путь к пользовательскому шрифту
  double loyaltyFontSize; // Размер шрифта виджета лояльности
  Color loyaltyFontColor; // Цвет шрифта виджета лояльности
  double paymentFontSize; // Размер шрифта QR-кода
  Color paymentFontColor; // Цвет шрифта QR-кода
  double summaryFontSize; // Размер шрифта итогов
  Color summaryFontColor; // Цвет шрифта итогов
  double itemsFontSize; // Размер шрифта таблицы товаров
  Color itemsFontColor; // Цвет шрифта таблицы товаров
  String fontFamily; // Название шрифта
  bool isDarkTheme; // Добавляем новое поле
  bool useAlternatingRowColors; // Использовать чередование цветов
  Color evenRowColor; // Цвет четных строк
  Color oddRowColor; // Цвет нечетных строк
  bool showLogo; // Показать логотип
  bool showPaymentQR; // Показать QR-код оплаты
  bool showSummary; // Показать итоги
  String webSocketUrl; // URL WebSocket
  String httpUrl; // URL HTTP
  bool isVersion85; // Версия 8.5
  int webSocketPort; // Порт WebSocket
  int httpPort; // Порт HTTP
  bool useInactivityTimer; // Использовать таймер бездействия
  int inactivityTimeout; // Таймаут бездействия

  Settings({
    required this.brand,
    required this.fullscreen,
    required this.videoFilePath,
    required this.videoUrl,
    required this.isVideoFromInternet,
    required this.showLoyaltyWidget,
    required this.backgroundColor,
    required this.borderColor,
    required this.backgroundImagePath,
    required this.useBackgroundImage,
    required this.logoPath,
    required this.showSideAdvert,
    required this.isSideAdvertFromInternet,
    required this.sideAdvertVideoPath,
    required this.sideAdvertVideoUrl,
    required this.widgetPositions,
    required this.showAdvertWithoutSales,
    required this.openSettingsHotkey,
    required this.closeMainWindowHotkey,
    required this.loyaltyWidgetColor,
    required this.paymentWidgetColor,
    required this.summaryWidgetColor,
    required this.itemsWidgetColor,
    required this.customFontPath,
    required this.loyaltyFontSize,
    required this.loyaltyFontColor,
    required this.paymentFontSize,
    required this.paymentFontColor,
    required this.summaryFontSize,
    required this.summaryFontColor,
    required this.itemsFontSize,
    required this.itemsFontColor,
    required this.fontFamily,
    required this.isDarkTheme,
    required this.useAlternatingRowColors,
    required this.evenRowColor,
    required this.oddRowColor,
    required this.showLogo,
    required this.showPaymentQR,
    required this.showSummary,
    required this.webSocketUrl,
    required this.httpUrl,
    required this.isVersion85,
    required this.webSocketPort,
    required this.httpPort,
    required this.useInactivityTimer,
    required this.inactivityTimeout,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      brand: json['brand'] ?? 'SP',
      fullscreen: json['fullscreen'] ?? false,
      videoFilePath: json['videoFilePath'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      isVideoFromInternet: json['isVideoFromInternet'] ?? true,
      showLoyaltyWidget: json['showLoyaltyWidget'] ?? true,
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFFFFF),
      borderColor: Color(json['borderColor'] ?? 0xFFD92038),
      backgroundImagePath: json['backgroundImagePath'] ?? '',
      useBackgroundImage: json['useBackgroundImage'] ?? false,
      logoPath: json['logoPath'] ?? '',
      showSideAdvert: json['showSideAdvert'] ?? false,
      isSideAdvertFromInternet: json['isSideAdvertFromInternet'] ?? true,
      sideAdvertVideoPath: json['sideAdvertVideoPath'] ?? '',
      sideAdvertVideoUrl: json['sideAdvertVideoUrl'] ?? '',
      widgetPositions:
          Map<String, Map<String, double>>.from(json['widgetPositions'] ?? {}),
      showAdvertWithoutSales: json['showAdvertWithoutSales'] ?? false,
      openSettingsHotkey: json['openSettingsHotkey'] ?? '',
      closeMainWindowHotkey: json['closeMainWindowHotkey'] ?? '',
      loyaltyWidgetColor: Color(json['loyaltyWidgetColor'] ?? 0xFFFFFFFF),
      paymentWidgetColor: Color(json['paymentWidgetColor'] ?? 0xFFFFFFFF),
      summaryWidgetColor: Color(json['summaryWidgetColor'] ?? 0xFFFFFFFF),
      itemsWidgetColor: Color(json['itemsWidgetColor'] ?? 0xFFFFFFFF),
      customFontPath: json['customFontPath'] ?? '',
      loyaltyFontSize: json['loyaltyFontSize'] ?? 16.0,
      loyaltyFontColor: Color(json['loyaltyFontColor'] ?? 0xFF000000),
      paymentFontSize: json['paymentFontSize'] ?? 16.0,
      paymentFontColor: Color(json['paymentFontColor'] ?? 0xFF000000),
      summaryFontSize: json['summaryFontSize'] ?? 16.0,
      summaryFontColor: Color(json['summaryFontColor'] ?? 0xFF000000),
      itemsFontSize: json['itemsFontSize'] ?? 16.0,
      itemsFontColor: Color(json['itemsFontColor'] ?? 0xFF000000),
      fontFamily: json['fontFamily'] ?? '',
      isDarkTheme: json['isDarkTheme'] ?? false,
      useAlternatingRowColors: json['useAlternatingRowColors'] ?? false,
      evenRowColor: Color(json['evenRowColor'] ?? 0xFFFFFFFF),
      oddRowColor: Color(json['oddRowColor'] ?? 0xFFF5F5F5),
      showLogo: json['showLogo'] ?? false,
      showPaymentQR: json['showPaymentQR'] ?? false,
      showSummary: json['showSummary'] ?? false,
      webSocketUrl: json['webSocketUrl'] ?? '',
      httpUrl: json['httpUrl'] ?? '',
      isVersion85: json['isVersion85'] ?? false,
      webSocketPort: json['webSocketPort'] ?? 0,
      httpPort: json['httpPort'] ?? 0,
      useInactivityTimer: json['useInactivityTimer'] ?? false,
      inactivityTimeout: json['inactivityTimeout'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'fullscreen': fullscreen,
      'videoFilePath': videoFilePath,
      'videoUrl': videoUrl,
      'isVideoFromInternet': isVideoFromInternet,
      'showLoyaltyWidget': showLoyaltyWidget,
      'backgroundColor': backgroundColor.value,
      'borderColor': borderColor.value,
      'backgroundImagePath': backgroundImagePath,
      'useBackgroundImage': useBackgroundImage,
      'logoPath': logoPath,
      'showSideAdvert': showSideAdvert,
      'isSideAdvertFromInternet': isSideAdvertFromInternet,
      'sideAdvertVideoPath': sideAdvertVideoPath,
      'sideAdvertVideoUrl': sideAdvertVideoUrl,
      'widgetPositions': widgetPositions,
      'showAdvertWithoutSales': showAdvertWithoutSales,
      'openSettingsHotkey': openSettingsHotkey,
      'closeMainWindowHotkey': closeMainWindowHotkey,
      'loyaltyWidgetColor': loyaltyWidgetColor.value,
      'paymentWidgetColor': paymentWidgetColor.value,
      'summaryWidgetColor': summaryWidgetColor.value,
      'itemsWidgetColor': itemsWidgetColor.value,
      'customFontPath': customFontPath,
      'loyaltyFontSize': loyaltyFontSize,
      'loyaltyFontColor': loyaltyFontColor.value,
      'paymentFontSize': paymentFontSize,
      'paymentFontColor': paymentFontColor.value,
      'summaryFontSize': summaryFontSize,
      'summaryFontColor': summaryFontColor.value,
      'itemsFontSize': itemsFontSize,
      'itemsFontColor': itemsFontColor.value,
      'fontFamily': fontFamily,
      'isDarkTheme': isDarkTheme,
      'useAlternatingRowColors': useAlternatingRowColors,
      'evenRowColor': evenRowColor.value,
      'oddRowColor': oddRowColor.value,
      'showLogo': showLogo,
      'showPaymentQR': showPaymentQR,
      'showSummary': showSummary,
      'webSocketUrl': webSocketUrl,
      'httpUrl': httpUrl,
      'isVersion85': isVersion85,
      'webSocketPort': webSocketPort,
      'httpPort': httpPort,
      'useInactivityTimer': useInactivityTimer,
      'inactivityTimeout': inactivityTimeout,
    };
  }
}

// Основной виджет второго монитора

class SecondMonitor extends LicenseCheckWidget {
  final AppSettings? settings; // Настройки приложения
  const SecondMonitor({super.key, this.settings});
  @override
  _SecondMonitorState createState() => _SecondMonitorState();
}

class _SecondMonitorState extends LicenseCheckState<SecondMonitor> with WidgetsBindingObserver {
  late AppSettings settings;
  bool isLoading = true;
  late Size selectedSize;
  late WebSocketService _webSocketService;
  late Server _server;
  LoyaltyProgram? _loyaltyProgram;
  Summary? _summary;
  List<CheckItem> _checkItems = [];
  PaymentQRCode? _paymentQRCode;
  final VideoManager _videoManager = VideoManager();
  final VideoManager _sideAdvertVideoManager = VideoManager();
  final FocusNode _focusNode = FocusNode();
  WinVideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String _currentVideoPath = '';
  bool _isSideAdvertVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.requestFocus();
    settings = widget.settings ??
        AppSettings(
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
          loyaltyWidgetColor: Colors.white,
          paymentWidgetColor: Colors.white,
          summaryWidgetColor: Colors.white,
          itemsWidgetColor: Colors.white,
          customFontPath: '',
          loyaltyFontSize: 16.0,
          loyaltyFontColor: Colors.black,
          paymentFontSize: 16.0,
          paymentFontColor: Colors.black,
          summaryFontSize: 16.0,
          summaryFontColor: Colors.black,
          itemsFontSize: 16.0,
          itemsFontColor: Colors.black,
          fontFamily: '',
          sideAdvertType: 'video',
          sideAdvertPath: '',
          isSideAdvertContentFromInternet: false,
          isDarkTheme: false,
          useAlternatingRowColors: false,
          evenRowColor: const Color(0xFFFFFFFF),
          oddRowColor: const Color(0xFFF5F5F5),
        );

    _initScreenSize().then((_) async {
      _server = Server(settings);
      _server.setVersion85(settings.isVersion85);
      _server.setOnDataReceived(_onDataReceived);
      _server.startServer(settings.httpUrl, settings.httpPort);
      _webSocketService = WebSocketService();
      _webSocketService.setOnDataReceived(_onDataReceived);
      _webSocketService.connect('ws://${settings.webSocketUrl}:${settings.webSocketPort}');

      await _checkAndCopyDll();

      _loadSettings().then((_) async {
        await _initializeVideo();
        await _initializeSideAdvertVideo();
        await _initFullScreen();
      });

      if (settings.customFontPath.isNotEmpty) {
        _loadCustomFont();
      }
    });

    if (settings.showSideAdvert) {
      if (settings.sideAdvertType == 'video') {
        String videoSource = settings.isSideAdvertContentFromInternet
            ? settings.sideAdvertUrl
            : settings.sideAdvertPath;
        log('Video source will be: $videoSource');
      }
    }
  }

  // Загрузка настроек
  Future<void> _loadSettings() async {
    try {
      final loadedSettings = await AppSettings.loadSettings();
      setState(() {
        settings = loadedSettings;

        // Проверяем и инициализируем позиции виджетов если они пустые
        if (settings.widgetPositions.isEmpty) {
          settings = settings.copyWith(
            widgetPositions: {
              'loyalty': {'x': 0.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
              'payment': {'x': 1130.0, 'y': 0.0, 'w': 150.0, 'h': 120.0},
              'summary': {'x': 1130.0, 'y': 904.0, 'w': 150.0, 'h': 120.0},
              'items': {'x': 200.0, 'y': 150.0, 'w': 880.0, 'h': 874.0},
              'sideAdvert': {'x': 0.0, 'y': 150.0, 'w': 200.0, 'h': 874.0},
              'logo': {'x': 10.0, 'y': 10.0, 'w': 100.0, 'h': 50.0},
            },
          );
        }

        // Получаем размеры из настроек
        final parts = settings.selectedResolution.split('x');
        selectedSize = Size(double.parse(parts[0]), double.parse(parts[1]));

        isLoading = false;
      });

      // Сохраняем обновленные настройки
      await AppSettings.saveSettings(settings);

    } catch (e, stack) {
      log('Error loading settings: $e');
      log('Stack trace: $stack');
    }
  }

  // Инициализация полноэкранного режима
  Future<void> _initFullScreen() async {
    await windowManager.ensureInitialized();
    final screenManager = ScreenManager();
    await screenManager.moveToSecondScreen();
    await windowManager
        .setFullScreen(true); // Всегда устанавливаем полноэкранный режим
  }

  Future<void> _initializeVideo() async {
    try {
      final videoPath = settings.isAdvertFromInternet
          ? settings.advertVideoUrl
          : settings.advertVideoPath;
      // Проверяем валидность пути/URL
      if (videoPath.isEmpty) {
        log('Ошибка: путь к видео пустой');
        return;
      }

      // Проверяем, нужно ли переинициализировать видео
      if (_currentVideoPath == videoPath && _isVideoInitialized) {
        log('Видео уже инициализировано');
        return;
      }
      await _disposeVideoController();

      // Проверяем существование файла для локального видео
      if (!settings.isVideoFromInternet) {
        final file = File(videoPath);
        if (!file.existsSync()) {
          log('Ошибка: локальный файл не найден: $videoPath');
          return;
        }
      }

      try {
        _videoController = settings.isVideoFromInternet
            ? WinVideoPlayerController.network(videoPath)
            : WinVideoPlayerController.file(File(videoPath));
      } catch (e) {
        log('Ошибка создания контроллера: $e');
        return;
      }

      try {
        await _videoController!.initialize();

        if (!mounted) {
          log('Виджет уже не mounted');
          await _disposeVideoController();
          return;
        }

        setState(() {
          _isVideoInitialized = true;
          _currentVideoPath = videoPath;
        });

        await _videoController!.setLooping(true);
        await _videoController!.setVolume(0.0);

        if (_shouldShowVideo()) {
          await _videoController!.play();
        }
      } catch (e) {
        log('Ошибка при инициализации контроллера: $e');
        await _disposeVideoController();
      }
    } catch (e, stack) {
      log('Общая ошибка инициализации видео: $e');
      log('Stack trace: $stack');
      _isVideoInitialized = false;
    }
  }

  Future<void> _disposeVideoController() async {
    if (_videoController != null) {
      await _videoController!.pause();
      await _videoController!.dispose();
      _videoController = null;
      _isVideoInitialized = false;
      _currentVideoPath = '';
    }
  }

  void _playVideo() {
    if (_isVideoInitialized && _videoController != null) {
      try {
        _videoController!.play();
      } catch (e) {
        log('Ошибка воспроизведения видео: $e');
      }
    }
  }

  void _pauseVideo() {
    if (_isVideoInitialized && _videoController != null) {
      try {
        _videoController!.pause();
      } catch (e) {
        log('Ошибка паузы видео: $e');
      }
    }
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: WinVideoPlayer(_videoController!),
        ),
      ),
    );
  }

  // Инициализация боковой рекламы

  Future<void> _initializeSideAdvertVideo() async {
    if (!settings.showSideAdvert) return;

    if (settings.sideAdvertType == 'video') {
      if (settings.sideAdvertVideoPath.isEmpty) {
        log('Error: video path is empty');
        return;
      }

      try {
        await _sideAdvertVideoManager.initialize(
          isVideoFromInternet: false,
          videoSource: settings.sideAdvertVideoPath,
        );

        if (mounted) {
          setState(() {
            _isSideAdvertVideoInitialized = true;
          });
          _sideAdvertVideoManager.play();
        }
      } catch (e) {
        log('Error initializing video: $e');
        _isSideAdvertVideoInitialized = false;
      }
    } else {
      // Если тип не видео, отключаем видеоплеер
      _isSideAdvertVideoInitialized = false;
    }
  }

  // Обработка полученных данных
  void _onDataReceived(dynamic message) {
    try {
      String cleanMessage = message.toString().trim();

      if (cleanMessage.startsWith('{')) {
        var jsonData = jsonDecode(cleanMessage);

        // Преобразуем данные в единый формат и обрабатываем
        Map<String, dynamic> processedData = {
          'messageType': 'checkData',
          'items': jsonData['items'] ?? [],
          'loyalty': jsonData['loyalty'],
          'payment': jsonData['payment'],
          'summary': jsonData['summary']
        };

        _processCheckData(processedData);
        if (_summary != null) {
        }
      }
    } catch (e, stack) {
      log('Error processing data:');
      log('Error: $e');
      log('Stack trace: $stack');
      log('Message that caused error: $message');
    }
  }

  void _processCheckData(Map<String, dynamic> jsonData) {
    setState(() {
      _checkItems = jsonData['items'] != null
          ? List<CheckItem>.from(
              jsonData['items'].map((item) => CheckItem.fromJson(item)))
          : [];

      _loyaltyProgram = jsonData['loyalty'] != null
          ? LoyaltyProgram.fromJson(jsonData['loyalty'])
          : null;

      _paymentQRCode =
          (jsonData['payment'] != null && jsonData['payment']['qrData'] != '')
              ? PaymentQRCode.fromJson(jsonData['payment'])
              : null;

      _summary = jsonData['summary'] != null
          ? Summary.fromJson(jsonData['summary'])
          : null;

      // Сохраняем настройки отображения
      settings = settings.copyWith(
        useAlternatingRowColors: settings.useAlternatingRowColors,
        evenRowColor: settings.evenRowColor,
        oddRowColor: settings.oddRowColor,
      );
    });

    // Управляем воспроизведением видео
    if (_shouldShowVideo()) {
      _playVideo();
    } else {
      _pauseVideo();
    }
  }

  // Условие для показа видео
  bool _shouldShowVideo() {
    return settings.showAdvertWithoutSales &&
        (_checkItems.isEmpty || _summary == null || _summary!.total == 0);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (_isHotkeyMatch(event, settings.openSettingsHotkey)) {
            _openSettings();
          } else if (_isHotkeyMatch(event, settings.closeMainWindowHotkey)) {
            _closeMainWindowAndOpenLaunchWindow();
          }
        }
      },
      child: MaterialApp(
        theme: settings.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: _shouldShowVideo()
                    ? _buildVideoPlayer()
                    : Container(
                        decoration: BoxDecoration(
                          color: settings.useBackgroundImage
                              ? null
                              : settings.backgroundColor,
                          image: settings.useBackgroundImage &&
                                  settings.backgroundImagePath.isNotEmpty &&
                                  File(settings.backgroundImagePath)
                                      .existsSync()
                              ? DecorationImage(
                                  image: FileImage(
                                      File(settings.backgroundImagePath)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: Stack(
                          children: [
                            if (settings.showLogo &&
                                settings.logoPath.isNotEmpty &&
                                File(settings.logoPath).existsSync())
                              _buildScaledWidget('logo', settings, 1.0, 1.0),
                            _buildScaledWidget('items', settings, 1.0, 1.0),
                            if (settings.showLoyaltyWidget)
                              _buildScaledWidget('loyalty', settings, 1.0, 1.0),
                            if (settings.showPaymentQR)
                              _buildScaledWidget('payment', settings, 1.0, 1.0),
                            if (settings.showSummary)
                              _buildScaledWidget('summary', settings, 1.0, 1.0),
                            if (settings.showSideAdvert) _buildSideAdvert(),
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Построение логотипа
  Widget _buildLogo(double scale) {
    if (settings.logoPath.isEmpty || !File(settings.logoPath).existsSync()) {
      return const SizedBox.shrink();
    }

    final pos = settings.logoPosition;

    return Positioned(
      left: pos['x']! * scale,
      top: pos['y']! * scale,
      width: pos['w']! * scale,
      height: pos['h']! * scale,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(settings.logoPath)),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Построение масштабируемого виджета
  Widget _buildScaledWidget(
      String type, AppSettings settings, double scaleX, double scaleY) {
    final position = settings.widgetPositions[type];
    if (position == null) return const SizedBox.shrink();

    Widget content;
    switch (type) {
      case 'logo':
        content = Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(settings.logoPath)),
              fit: BoxFit.contain,
            ),
          ),
        );
        break;
      case 'loyalty':
        content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'ПРОГРАММА ЛОЯЛЬНОСТИ',
                style: _getWidgetTextStyle(type)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            if (_loyaltyProgram != null) ...[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Уровень: ${_loyaltyProgram!.customerName}',
                        style: _getWidgetTextStyle(type),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Баллы: ${_loyaltyProgram!.bonusBalance}',
                        style: _getWidgetTextStyle(type),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: Text(
                      'Нет данных',
                      style: _getWidgetTextStyle(type),
                    ),
                  ),
                ),
              ),
          ],
        );
        break;
      case 'payment':
        content = Center(
          child: _paymentQRCode != null
              ? QrImageView(
                  data: _paymentQRCode!.qrData,
                  version: QrVersions.auto,
                  size: position['w']! * 0.8, // 80% от ширины виджета
                )
              : const SizedBox.shrink(),
        );
        break;
      case 'summary':
        final double totalBeforeDiscount = _summary?.total ?? 0.0;
        final double discount = _summary?.discount ?? 0.0;
        final double finalAmount = totalBeforeDiscount - discount;

        content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'ИТОГО',
                style: _getWidgetTextStyle(type)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Позиций: ${_checkItems.length}',
                      style: _getWidgetTextStyle(type),
                    ),
                  ),
                  if (_summary != null) ...[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Сумма: $totalBeforeDiscount',
                        style: _getWidgetTextStyle(type),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Скидка: $discount',
                        style: _getWidgetTextStyle(type),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'К ОПЛАТЕ: $finalAmount',
                        style: _getWidgetTextStyle(type)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
        break;
      case 'items':
        content = _buildItemsWidget();
        break;
      default:
        content = Text(
          _getWidgetTitle(type),
          style: _getWidgetTextStyle(type),
        );
    }

    // Определяем цвет для каждого типа виджета
    Color widgetColor;
    switch (type) {
      case 'loyalty':
        widgetColor = settings.loyaltyWidgetColor;
        break;
      case 'payment':
        widgetColor = settings.paymentWidgetColor;
        break;
      case 'summary':
        widgetColor = settings.summaryWidgetColor;
        break;
      case 'items':
        widgetColor = settings.itemsWidgetColor;
        break;
      default:
        widgetColor = Colors.white;
    }

    return Positioned(
      left: position['x']! * scaleX,
      top: position['y']! * scaleY,
      width: position['w']! * scaleX,
      height: position['h']! * scaleY,
      child: Container(
        clipBehavior: type == 'logo' ? Clip.antiAlias : Clip.none,
        decoration: BoxDecoration(
          color: type == 'logo' ? Colors.transparent : widgetColor,
          border:
              type == 'logo' ? null : Border.all(color: settings.borderColor),
          borderRadius: type == 'logo' ? null : BorderRadius.circular(8),
        ),
        child: Padding(
          padding: type == 'logo' ? EdgeInsets.zero : const EdgeInsets.all(12),
          child: content,
        ),
      ),
    );
  }

  // Построение списка товаров
  Widget _buildItemsWidget() {
    return Column(
      children: [
        // Заголовок таблицы
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: settings.borderColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('№',
                      style: _getWidgetTextStyle('items')
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Наименование',
                      style: _getWidgetTextStyle('items')
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Кол-во',
                      style: _getWidgetTextStyle('items')
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Цена',
                      style: _getWidgetTextStyle('items')
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Сумма',
                      style: _getWidgetTextStyle('items')
                          .copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),

        // Список товаров
        Expanded(
          child: ListView.builder(
            itemCount: _checkItems.length,
            itemBuilder: (context, index) {
              final item = _checkItems[index];
              return Container(
                decoration: BoxDecoration(
                  color: settings.useAlternatingRowColors
                      ? (index % 2 == 0
                          ? settings.evenRowColor
                          : settings.oddRowColor)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${index + 1}',
                            style: _getWidgetTextStyle('items')),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item.name,
                            style: _getWidgetTextStyle('items')),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_formatQuantity(item.quantity),
                            style: _getWidgetTextStyle('items')),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_formatMoney(item.price),
                            style: _getWidgetTextStyle('items')),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_formatMoney(item.amount),
                            style: _getWidgetTextStyle('items')),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Итоги (если виджет итогов отключен)
        if (!settings.showSummary && _summary != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: settings.borderColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Сумма: ${_formatMoney(_summary!.subtotal)} | ',
                  style: _getWidgetTextStyle('items'),
                ),
                Text(
                  'Скидка: ${_formatMoney(_summary!.discount)} | ',
                  style: _getWidgetTextStyle('items'),
                ),
                Text(
                  'ИТОГО: ${_formatMoney(_summary!.total)}',
                  style: _getWidgetTextStyle('items').copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Получение заголовка виджета
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

      default:
        return '';
    }
  }

  // Построение боковой рекламы
  Widget _buildSideAdvert() {
    if (!settings.showSideAdvert) return const SizedBox.shrink();

    final pos = settings.widgetPositions['sideAdvert'];
    if (pos == null) return const SizedBox.shrink();

    Widget content;
    if (settings.sideAdvertType == 'video' && _isSideAdvertVideoInitialized) {
      content = _sideAdvertVideoManager.buildVideoPlayer(context);
    } else if (settings.sideAdvertType == 'image') {
      content = Image.file(
        File(settings.sideAdvertPath),
        fit: BoxFit.contain,
      );
    } else {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: pos['x']!,
      top: pos['y']!,
      width: pos['w']!,
      height: pos['h']!,
      child: Container(
        decoration: const BoxDecoration(),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }

  void _openSettings() async {
    await SettingsWindow.showFullscreen(context);
  }

  void _closeMainWindowAndOpenLaunchWindow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LaunchWindow()),
    );
  }

  bool _isHotkeyMatch(RawKeyEvent event, String hotkey) {
    try {
      if (hotkey.isEmpty) return false;

      List<String> keys = hotkey.split(' + ');
      bool ctrlRequired = keys.contains('Ctrl');
      bool shiftRequired = keys.contains('Shift');
      bool altRequired = keys.contains('Alt');
      
      String letterKey = keys.lastWhere(
        (k) => !['Ctrl', 'Shift', 'Alt'].contains(k),
        orElse: () => '',
      );

      if (letterKey.isEmpty) return false;

      // Проверяем модификаторы более безопасным способом
      bool modifiersMatch = 
        (event.isControlPressed == ctrlRequired) &&
        (event.isShiftPressed == shiftRequired) &&
        (event.isAltPressed == altRequired);

      // Более безопасная проверка основной клавиши
      bool keyMatches = false;
      try {
        keyMatches = event.logicalKey.keyLabel.toUpperCase() == letterKey.toUpperCase();
      } catch (e) {
        log('Error matching key: $e');
        return false;
      }

      return modifiersMatch && keyMatches;
    } catch (e) {
      log('Error in hotkey matching: $e');
      return false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _videoManager.dispose();
    _sideAdvertVideoManager.dispose();
    _webSocketService.dispose();
    _server.stopServer();
    _disposeVideoController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || 
        state == AppLifecycleState.paused) {
      _focusNode.unfocus();
    }
  }

  TextStyle _getWidgetTextStyle(String type) {
    FontWeight weight = FontWeight.normal;
    double? fontSize;
    Color? color;
    switch (type) {
      case 'loyalty':
        fontSize = settings.loyaltyFontSize;
        color = settings.loyaltyFontColor;
        break;

      case 'payment':
        fontSize = settings.paymentFontSize;
        color = settings.paymentFontColor;
        break;

      case 'summary':
        fontSize = settings.summaryFontSize;
        color = settings.summaryFontColor;
        break;

      case 'items':
        fontSize = settings.itemsFontSize;
        color = settings.itemsFontColor;
        break;
    }

    return TextStyle(
      fontFamily: settings.fontFamily.isNotEmpty ? settings.fontFamily : null,
      fontSize: fontSize,
      color: color,
      fontWeight: weight,
    );
  }

  Future<void> _loadCustomFont() async {
    try {
      if (settings.customFontPath.isEmpty) return;
      final baseStyle = TextStyle(
        fontSize: settings.loyaltyFontSize,
        color: settings.loyaltyFontColor,
      );

      // Загружаем и применяем шрифт через FontManager
      final newStyle =
          await FontManager.loadCustomFont(settings.customFontPath, baseStyle);

      // Обновляем UI
      setState(() {
        settings = settings.copyWith(
          fontFamily: newStyle.fontFamily ?? 'CustomFont',
        );
      });

    } catch (e) {
      log('Error loading font: $e');
    }
  }

  Future<void> updateFont(String newFontPath) async {
    try {
      settings = settings.copyWith(
        customFontPath: newFontPath,
      );

      await AppSettings.saveSettings(settings);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LaunchWindow(),
          ),
        );
      }
    } catch (e) {
      log('Error updating font: $e');
    }
  }

  Future<void> _initScreenSize() async {
    final screens = await ScreenRetriever.instance.getAllDisplays();

    final targetScreen = screens.length > 1 ? screens[1] : screens[0];

    setState(() {
      selectedSize = Size(
        targetScreen.size.width,
        targetScreen.size.height,
      );

      settings = settings.copyWith(
          selectedResolution:
              '${selectedSize.width.toInt()}x${selectedSize.height.toInt()}');
    });
  }

  Future<void> _checkAndCopyDll() async {
    try {
      final String exePath = Platform.resolvedExecutable;
      final String exeDir = File(exePath).parent.path;
      final String dllPath = '$exeDir\\video_player_win_plugin.dll';
      final String debugDllPath = '$exeDir\\Debug\\video_player_win_plugin.dll';

      // Проверяем существование Debug DLL
      if (File(debugDllPath).existsSync()) {
        await File(debugDllPath).copy(dllPath);
      } else {
        log('Debug DLL not found at: $debugDllPath');
      }
    } catch (e) {
      log('Error copying DLL: $e');
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

  String _formatMoney(double value) {
    return value.toStringAsFixed(2);
  }

  String _formatQuantity(double value) {
    return value.truncateToDouble() == value
        ? value.toInt().toString()
        : value.toString();
  }
}