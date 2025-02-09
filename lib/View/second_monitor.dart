import 'dart:convert';

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show RawKeyDownEvent;

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

import 'package:second_monitor/Model/Message1C.dart';
import 'package:video_player_win/video_player_win.dart';
import 'package:second_monitor/Service/logger.dart';



// Класс настроек приложения

class Settings {

  String brand;  // Бренд приложения

  bool fullscreen;  // Полноэкранный режим

  String videoFilePath;  // Путь к видеофайлу

  String videoUrl;  // URL видео

  bool isVideoFromInternet;  // Использовать видео из интернета

  bool showLoyaltyWidget;  // Показать виджет лояльности

  Color backgroundColor;  // Цвет фона

  Color borderColor;  // Цвет рамки

  String backgroundImagePath;  // Путь к изображению фона

  bool useBackgroundImage;  // Использовать изображение фона

  String logoPath;  // Путь к логотипу

  bool showSideAdvert;  // Показать боковую рекламу

  bool isSideAdvertFromInternet;  // Использовать боковую рекламу из интернета

  String sideAdvertVideoPath;  // Путь к видео боковой рекламы

  String sideAdvertVideoUrl;  // URL видео боковой рекламы

  Map<String, Map<String, double>> widgetPositions;  // Позиции виджетов

  bool showAdvertWithoutSales;  // Показать рекламу без продаж

  String openSettingsHotkey;  // Горячая клавиша для открытия настроек

  String closeMainWindowHotkey;  // Горячая клавиша для закрытия окна

  Color loyaltyWidgetColor;  // Цвет виджета лояльности

  Color paymentWidgetColor;  // Цвет виджета оплаты

  Color summaryWidgetColor;  // Цвет виджета итога

  Color itemsWidgetColor;  // Цвет виджета таблицы товаров

  String customFontPath;  // Путь к пользовательскому шрифту

  double loyaltyFontSize;  // Размер шрифта виджета лояльности

  Color loyaltyFontColor;  // Цвет шрифта виджета лояльности

  double paymentFontSize;  // Размер шрифта QR-кода

  Color paymentFontColor;  // Цвет шрифта QR-кода

  double summaryFontSize;  // Размер шрифта итогов

  Color summaryFontColor;  // Цвет шрифта итогов

  double itemsFontSize;  // Размер шрифта таблицы товаров

  Color itemsFontColor;  // Цвет шрифта таблицы товаров

  String fontFamily;  // Название шрифта



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

      widgetPositions: Map<String, Map<String, double>>.from(json['widgetPositions'] ?? {}),

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

    };

  }

}



// Основной виджет второго монитора

class SecondMonitor extends StatefulWidget {

  final AppSettings? settings;  // Настройки приложения

  

  const SecondMonitor({super.key, this.settings});



  @override

  _SecondMonitorState createState() => _SecondMonitorState();

}



class _SecondMonitorState extends State<SecondMonitor> with WidgetsBindingObserver {

  late AppSettings settings;  // Переменная для хранения настроек

  bool isLoading = true;  // Флаг загрузки

  Size selectedSize = const Size(1280, 1024); // Размер по умолчанию

  late WebSocketService _webSocketService;  // Сервис WebSocket

  late Server _server;  // Сервис сервера

  LoyaltyProgram? _loyaltyProgram;  // Программа лояльности

  Summary? _summary;  // Сводка

  List<CheckItem> _checkItems = [];  // Список элементов проверки

  PaymentQRCode? _paymentQRCode;  // QR-код для оплаты

  late VideoManager _videoManager;  // Менеджер видео

  late VideoManager _sideAdvertVideoManager;  // Менеджер боковой рекламы

  final FocusNode _focusNode = FocusNode();



  @override

  void initState() {

    super.initState();

    

    try {

      WidgetsBinding.instance.addObserver(this);

      _focusNode.requestFocus();



      settings = widget.settings ?? AppSettings(

        isFullScreen: false,

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

      );



      if (widget.settings != null) {

        final parts = settings.selectedResolution.split('x');

        selectedSize = Size(

          double.parse(parts[0]),

          double.parse(parts[1])

        );

      }



      getSecondMonitorSize().then((size) {

        setState(() {

          selectedSize = size;

        });

      });



      _server = Server();

      _server.setVersion85(settings.isVersion85);

      _server.startServer(settings.httpUrl, settings.httpPort);

      _webSocketService = WebSocketService();

      _webSocketService.setOnDataReceived(_onDataReceived);
      log('Starting services initialization');
      _initializeServices().then((_) {
        log('Services initialized successfully');
        _initializeVideoServices();
      }).catchError((e, stack) {
        log('Error initializing services: $e');
        log('Stack trace: $stack');
      });


      _videoManager = VideoManager();
      _sideAdvertVideoManager = VideoManager();

    } catch (e, stack) {

      log('Error in initState: $e');

      log('Stack trace: $stack');

    }

  }



  Future<void> _initializeServices() async {

    try {

      // Инициализация WebSocket

      await _webSocketService.connect('ws://localhost:4002/ws/');

    } catch (e) {

      log('Error initializing services: $e');

      // Продолжаем работу даже при ошибке подключения

    }

  }



  // Загрузка настроек

  Future<void> _loadSettings() async {

    settings = await AppSettings.loadSettings();  // Загрузка настроек

    log('Loaded settings:');  // Отладочный вывод

    log('Open settings hotkey: ${settings.openSettingsHotkey}');

    log('Close window hotkey: ${settings.closeMainWindowHotkey}');

    // Получаем размеры из настроек

    final parts = settings.selectedResolution.split('x');

    setState(() {

      selectedSize = Size(

        double.parse(parts[0]),

        double.parse(parts[1])

      );

      isLoading = false;  // Устанавливаем флаг загрузки в false

    });

  }



  // Инициализация полноэкранного режима

  void _initFullScreen() async {
    log('Initializing full screen');
    await windowManager.ensureInitialized();  // Убедитесь, что менеджер окна инициализирован

    final screenManager = ScreenManager();  // Инициализация менеджера экрана
    log('Moving to second screen');
    await screenManager.moveToSecondScreen();  // Перемещение на второй экран

    

    if (settings.isFullScreen) {
      log('Setting full screen');
      await windowManager.setFullScreen(true);  // Установка полноэкранного режима

    } else {
      log('Setting size');
      await windowManager.setSize(selectedSize);  // Установка размера окна в соответствии с разрешением

      await windowManager.center();  // Центрирование окна

    }

  }



  // Инициализация видео

  void _initializeVideo() {
    try {
      log('Initializing video SM');
      if (!settings.showAdvertWithoutSales) {
        log('Video playback disabled in settings');
        return;
      }

      // Отложенная инициализация
      log('Delaying video initialization');
      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        log('Checking if mounted');

        try {
          log('Starting video initialization');
          
          // Проверяем существование файла для локального видео
          if (!settings.isVideoFromInternet) {
            final file = File(settings.videoFilePath);
            if (!await file.exists()) {
              log('Video file not found: ${settings.videoFilePath}');
              return;
            }
          }

          // Инициализируем видео
          log('Initializing video manager SM');
          await _videoManager.initialize(
            isVideoFromInternet: settings.isVideoFromInternet,
            videoSource: settings.isVideoFromInternet ? settings.videoUrl : settings.videoFilePath,
          );

          // Обновляем UI после успешной инициализации
          log('Updating UI');
          if (mounted) {
            log('UI is mounted');
            setState(() {});
          }

        } catch (e) {
          log('Error in video initialization: $e');
        }
      });

    } catch (e) {
      log('Error in _initializeVideo: $e');
    }
  }



  // Инициализация боковой рекламы

  void _initializeSideAdvertVideo() {
    try {
      log('Initializing side advert video');
      if (!settings.showSideAdvert) {
        log('Side advert disabled in settings');
        return;

      }

      // Защита от падения в релизе
      try {
        log('Checking side video file availability...');
        if (Platform.isWindows) {
          log('Checking side video file availability...');
          if (settings.sideAdvertVideoPath.isNotEmpty) {
            final file = File(settings.sideAdvertVideoPath);
            if (!file.existsSync()) {
              log('Side video file not found: ${settings.sideAdvertVideoPath}');
              return;
            }
            log('Side video file exists and accessible');
          }
        }
      } catch (e) {
        log('Error checking side video file: $e');
        return;
      }

      // Отложенная инициализация
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        try {
          log('Starting delayed side video initialization');
          _sideAdvertVideoManager = VideoManager();
          _sideAdvertVideoManager.initialize(
            isVideoFromInternet: settings.isSideAdvertFromInternet,
            videoSource: settings.isSideAdvertFromInternet ? settings.sideAdvertVideoUrl : settings.sideAdvertVideoPath,
          ).catchError((error) {
            log('Error in side video initialization: $error');
          });
        } catch (e) {
          log('Error in delayed side initialization: $e');
        }
      });

    } catch (e, stack) {
      log('Fatal error in _initializeSideAdvertVideo: $e');
      log('Stack trace: $stack');
    }
  }



  // Обработка полученных данных

  void _onDataReceived(dynamic message) {

    try {

      log('Raw message received: $message');



      String cleanMessage = message.toString().trim();

      if (cleanMessage.startsWith('{')) {

        log('Attempting to parse JSON: $cleanMessage');

        var jsonData = jsonDecode(cleanMessage);

        

        if (jsonData['messageType'] == 'checkData') {

          final message1C = Message1C.fromJson(jsonData);

          log('Successfully parsed message: ${message1C.items.length} items');

          

          setState(() {

            _checkItems = message1C.items;

            _loyaltyProgram = message1C.loyalty;

            _paymentQRCode = message1C.payment;

            _summary = message1C.summary;

          });



          // Управляем воспроизведением видео

          if (_shouldShowVideo()) {

            _videoManager.play();

          } else {

            _videoManager.pause();

          }

        }

      } else {

        log('Received message is not a JSON object');

      }

    } catch (e, stack) {

      log('Error processing message: $e');

      log('Stack trace: $stack');

      log('Message that caused error: $message');

    }

  }



  // Условие для показа видео

  bool _shouldShowVideo() {
    log('Checking if video should be shown');

    return settings.showAdvertWithoutSales && 

           (_checkItems.isEmpty || _summary == null || _summary!.total == 0);

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: Stack(

        children: [

          if (settings.showAdvertWithoutSales && _videoManager.isInitialized)

            Positioned.fill(

              child: _buildVideoPlayer(),

            ),

          RawKeyboardListener(

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

            child: Stack(

              children: [

                if (settings.showLogo)

                  _buildLogo(1.0),

                _buildScaledWidget('items', settings, 1.0, 1.0),

                if (settings.showLoyaltyWidget)

                  _buildScaledWidget('loyalty', settings, 1.0, 1.0),

                _buildScaledWidget('payment', settings, 1.0, 1.0),

                _buildScaledWidget('summary', settings, 1.0, 1.0),

                if (settings.showSideAdvert)

                  _buildScaledSideAdvertVideo(1.0, 1.0),

              ],

            ),

          ),

        ],

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

  Widget _buildScaledWidget(String type, AppSettings settings, double scaleX, double scaleY) {

    final position = settings.widgetPositions[type];

    if (position == null || position.isEmpty) return const SizedBox.shrink();



    // QR-код показываем только при наличии данных

    if (type == 'payment' && _paymentQRCode == null) {

      return const SizedBox.shrink();

    }



    Widget content;

    switch (type) {

      case 'loyalty':

        content = Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            FittedBox(

              fit: BoxFit.scaleDown,

              child: Text(

                'ПРОГРАММА ЛОЯЛЬНОСТИ',

                style: _getWidgetTextStyle(type).copyWith(fontWeight: FontWeight.bold),

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

                        'Уровень: ${_loyaltyProgram!.cardNumber}',

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

                    FittedBox(

                      fit: BoxFit.scaleDown,

                      child: Text(

                        'До следующего уровня: 0',

                        style: _getWidgetTextStyle(type),

                      ),

                    ),

                    FittedBox(

                      fit: BoxFit.scaleDown,

                      child: Text(

                        'Сгорание: 15 750 до 31.12.2025',

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
            ]);
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

                style: _getWidgetTextStyle(type).copyWith(fontWeight: FontWeight.bold),

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

                        style: _getWidgetTextStyle(type).copyWith(fontWeight: FontWeight.bold),

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

        content = _buildItemsList();

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

        decoration: BoxDecoration(

          color: widgetColor, // Используем выбранный цвет

          border: Border.all(color: settings.borderColor),

          borderRadius: BorderRadius.circular(8),

        ),

        child: Padding(

          padding: const EdgeInsets.all(12),

          child: content,

        ),

      ),

    );

  }



  // Построение списка товаров

  Widget _buildItemsList() {

    return Column(

      children: [

        Container(

          color: Colors.grey[200],

          child: Row(

            children: [

              Expanded(

                flex: 1,

                child: Padding(

                  padding: const EdgeInsets.all(8.0),

                  child: Text(

                    '№',

                    style: _getWidgetTextStyle('items').copyWith(fontWeight: FontWeight.bold),

                  ),

                ),

              ),

              Expanded(

                flex: 4,

                child: Padding(

                  padding: const EdgeInsets.all(8.0),

                  child: Text(

                    'Наименование',

                    style: _getWidgetTextStyle('items').copyWith(fontWeight: FontWeight.bold),

                  ),

                ),

              ),

              Expanded(

                flex: 2,

                child: Padding(

                  padding: const EdgeInsets.all(8.0),

                  child: Text(

                    'Кол-во',

                    style: _getWidgetTextStyle('items').copyWith(fontWeight: FontWeight.bold),

                  ),

                ),

              ),

              Expanded(

                flex: 2,

                child: Padding(

                  padding: const EdgeInsets.all(8.0),

                  child: Text(

                    'Цена',

                    style: _getWidgetTextStyle('items').copyWith(fontWeight: FontWeight.bold),

                  ),

                ),
              ),
            ],

          ),

        ),

        Expanded(

          child: ListView.builder(

            itemCount: _checkItems.length,

            itemBuilder: (context, index) {

              final item = _checkItems[index];

              return Row(

                children: [

                  Expanded(

                    flex: 1,

                    child: Padding(

                      padding: const EdgeInsets.all(8.0),

                      child: Text(

                        '${index + 1}',

                        style: _getWidgetTextStyle('items'),

                      ),

                    ),

                  ),

                  Expanded(

                    flex: 4,

                    child: Padding(

                      padding: const EdgeInsets.all(8.0),

                      child: Text(

                        item.name,

                        style: _getWidgetTextStyle('items'),

                      ),

                    ),

                  ),

                  Expanded(

                    flex: 2,

                    child: Padding(

                      padding: const EdgeInsets.all(8.0),

                      child: Text(

                        '${item.quantity}',

                        style: _getWidgetTextStyle('items'),

                      ),

                    ),

                  ),

                  Expanded(

                    flex: 2,

                    child: Padding(

                      padding: const EdgeInsets.all(8.0),

                      child: Text(

                        '${item.price}',

                        style: _getWidgetTextStyle('items'),

                      ),

                    ),

                  ),

                ],

              );

            },

          ),

        ),

      ],

    );

  }



  // Получение заголовка виджета

  String _getWidgetTitle(String type) {

    switch (type) {

      case 'loyalty': return 'Виджет лояльности';

      case 'payment': return 'QR-код оплаты';

      case 'summary': return 'Итого';

      case 'sideAdvert': return 'Боковая реклама';

      case 'items': return 'Таблица товаров';

      default: return '';

    }

  }



  // Построение боковой рекламы

  Widget _buildScaledSideAdvertVideo(double scaleX, double scaleY) {

    final pos = settings.widgetPositions['sideAdvert'];

    if (pos == null) return const SizedBox.shrink();



    return Positioned(

      left: pos['x']! * scaleX,

      top: pos['y']! * scaleY,

      width: pos['w']! * scaleX,

      height: pos['h']! * scaleY,

      child: Container(

        decoration: const BoxDecoration(),

        clipBehavior: Clip.antiAlias,

        child: _sideAdvertVideoManager.buildVideoPlayer(),

      ),

    );

  }



  void _openSettings() {

    Navigator.push(

      context,

      MaterialPageRoute(builder: (context) => const SettingsWindow()),

    );

  }



  void _closeMainWindowAndOpenLaunchWindow() {

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(builder: (context) => const LaunchWindow()),

    );

  }



  bool _isHotkeyMatch(RawKeyEvent event, String hotkey) {

    if (hotkey.isEmpty) return false;
    

    log('Checking hotkey match:');

    log('Hotkey from settings: $hotkey');

    log('Pressed key: ${event.logicalKey.keyLabel}');

    

    List<String> keys = hotkey.split(' + ');

    

    bool ctrlRequired = keys.contains('Ctrl');

    bool shiftRequired = keys.contains('Shift');

    bool altRequired = keys.contains('Alt');

    

    // Получаем основную клавишу (последний элемент в комбинации)

    String letterKey = keys.lastWhere(

      (k) => !['Ctrl', 'Shift', 'Alt'].contains(k),

      orElse: () => '',

    );



    // Проверяем совпадение модификаторов

    bool modifiersMatch = event.isControlPressed == ctrlRequired &&

                         event.isShiftPressed == shiftRequired &&

                         event.isAltPressed == altRequired;



    // Проверяем совпадение основной клавиши

    bool keyMatches = event.logicalKey.keyLabel.toUpperCase() == letterKey.toUpperCase();

    

    log('Modifiers match: $modifiersMatch');

    log('Key matches: $keyMatches');

    log('Letter key required: $letterKey');

    

    return modifiersMatch && keyMatches;

  }



  @override

  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    _focusNode.dispose();

    _videoManager.dispose();

    _sideAdvertVideoManager.dispose();

    _webSocketService.dispose();

    _server.stopServer();

    super.dispose();

  }



  @override

  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.inactive || 

        state == AppLifecycleState.paused) {

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
      

      // Обновляем UI

      setState(() {

        settings = settings.copyWith(

          customFontPath: 'CustomFont', // Используем имя, заданное в FontManager

        );

      });
      

      log('Font loaded successfully: CustomFont');

    } catch (e) {

      log('Error loading font: $e');

    }

  }



  Future<void> updateFont(String newFontPath) async {

    try {

      settings = settings.copyWith(

        customFontPath: newFontPath,

      );
      

      await settings.saveSettings();
      

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



  void _initializeVideoServices() {
    try {
      _loadSettings().then((_) {
        _initializeVideo();
        _initializeSideAdvertVideo();
        _initFullScreen();
      });

      if (settings.customFontPath.isNotEmpty) {
        _loadCustomFont();
      }
    } catch (e, stack) {
      log('Error in _initializeVideoServices: $e');
      log('Stack trace: $stack');
    }
  }

  Widget _buildVideoPlayer() {
    return _videoManager.isInitialized
        ? Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoManager.controller.value.size.width,
                height: _videoManager.controller.value.size.height,
                child: WinVideoPlayer(_videoManager.controller),
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

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