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

import 'package:flutter/rendering.dart';

import 'package:second_monitor/Service/FontManager.dart';



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

  late Size selectedSize; // Убираем значение по умолчанию

  late WebSocketService _webSocketService;  // Сервис WebSocket

  late Server _server;  // Сервис сервера

  LoyaltyProgram? _loyaltyProgram;  // Программа лояльности

  Summary? _summary;  // Сводка

  List<CheckItem> _checkItems = [];  // Список элементов проверки

  PaymentQRCode? _paymentQRCode;  // QR-код для оплаты

  final VideoManager _videoManager = VideoManager();  // Менеджер видео

  final VideoManager _sideAdvertVideoManager = VideoManager();  // Менеджер боковой рекламы

  final FocusNode _focusNode = FocusNode();



  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _focusNode.requestFocus();



    settings = widget.settings ?? AppSettings(

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



    _initScreenSize().then((_) {

      _server = Server();

      _server.setVersion85(settings.isVersion85);

      _server.startServer(settings.httpUrl, settings.httpPort);

      _webSocketService = WebSocketService();

      _webSocketService.setOnDataReceived(_onDataReceived);

      _webSocketService.connect('ws://localhost:4002/ws/');



      _loadSettings().then((_) {

        _initializeVideo();

        _initializeSideAdvertVideo();

        _initFullScreen();

      });



      if (settings.customFontPath.isNotEmpty) {

        _loadCustomFont();

      }

    });

  }



  // Загрузка настроек

  Future<void> _loadSettings() async {

    settings = await AppSettings.loadSettings();  // Загрузка настроек

    print('Loaded settings:');  // Отладочный вывод

    print('Open settings hotkey: ${settings.openSettingsHotkey}');

    print('Close window hotkey: ${settings.closeMainWindowHotkey}');

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

    await windowManager.ensureInitialized();

    final screenManager = ScreenManager();

    await screenManager.moveToSecondScreen();

    await windowManager.setFullScreen(true); // Всегда устанавливаем полноэкранный режим

  }



  // Инициализация видео

  void _initializeVideo() {

    startTimerVideoReinit();

    

    // Инициализация основного видео

    if (settings.isVideoFromInternet) {

      _videoManager.initialize(

        isVideoFromInternet: true,

        videoSource: settings.videoUrl,

      ).then((_) {

        setState(() {});

      });

    } else {

      _videoManager.initialize(

        isVideoFromInternet: false,

        videoSource: settings.videoFilePath,

      ).then((_) {

        setState(() {});

      });

    }



    // Инициализация видео для рекламы

    if (settings.showAdvertWithoutSales) {

      if (settings.isAdvertFromInternet) {

        _videoManager.initialize(

          isVideoFromInternet: true,

          videoSource: settings.advertVideoUrl,

        ).then((_) {

          setState(() {});

        });

      } else {

        _videoManager.initialize(

          isVideoFromInternet: false,

          videoSource: settings.advertVideoPath,

        ).then((_) {

          setState(() {});

        });

      }

    }

  }



  // Инициализация боковой рекламы

  void _initializeSideAdvertVideo() {

    if (settings.showSideAdvert) {

      if (settings.isSideAdvertFromInternet) {

        _sideAdvertVideoManager.initialize(

          isVideoFromInternet: true,

          videoSource: settings.sideAdvertVideoUrl,

        ).then((_) {

          setState(() {});  // Обновление состояния

        });

      } else {

        _sideAdvertVideoManager.initialize(

          isVideoFromInternet: false,

          videoSource: settings.sideAdvertVideoPath,

        ).then((_) {

          setState(() {});  // Обновление состояния

        });

      }

    }

  }



  // Таймер для повторной инициализации видео

  void startTimerVideoReinit() {

    Timer.periodic(const Duration(hours: 5), (Timer timer) {

      _initializeVideo();  // Повторная инициализация видео

    });

  }



  // Обработка полученных данных

  void _onDataReceived(dynamic message) {

    try {

      print('Raw message received: $message');



      String cleanMessage = message.toString().trim();

      if (cleanMessage.startsWith('{')) {

        print('Attempting to parse JSON: $cleanMessage');

        var jsonData = jsonDecode(cleanMessage);

        

        if (jsonData['messageType'] == 'checkData') {

          final message1C = Message1C.fromJson(jsonData);

          print('Successfully parsed message: ${message1C.items.length} items');

          

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

        print('Received message is not a JSON object');

      }

    } catch (e, stack) {

      print('Error processing message: $e');

      print('Stack trace: $stack');

      print('Message that caused error: $message');

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

        debugShowCheckedModeBanner: false,

        home: Scaffold(

          body: LayoutBuilder(

            builder: (context, constraints) {

              return Container(

                width: constraints.maxWidth,

                height: constraints.maxHeight,

                child: _shouldShowVideo()

                  ? _videoManager.buildVideoPlayer(context)

                  : Container(

                      decoration: BoxDecoration(

                        color: settings.useBackgroundImage ? null : settings.backgroundColor,

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

        child: _sideAdvertVideoManager.buildVideoPlayer(context),

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

    if (hotkey.isEmpty) return false;
    

    print('Checking hotkey match:');

    print('Hotkey from settings: $hotkey');

    print('Pressed key: ${event.logicalKey.keyLabel}');

    

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

    

    print('Modifiers match: $modifiersMatch');

    print('Key matches: $keyMatches');

    print('Letter key required: $letterKey');

    

    return modifiersMatch && keyMatches;

  }



  @override

  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    _focusNode.dispose();

    _videoManager.dispose();

    _sideAdvertVideoManager.dispose();

    _webSocketService.disconnect();

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
      

      // Создаем базовый стиль

      final baseStyle = TextStyle(

        fontSize: settings.loyaltyFontSize,

        color: settings.loyaltyFontColor,

      );
      

      // Загружаем и применяем шрифт через FontManager

      final newStyle = await FontManager.loadCustomFont(settings.customFontPath, baseStyle);
      

      // Обновляем UI

      setState(() {

        settings = settings.copyWith(

          fontFamily: newStyle.fontFamily ?? 'CustomFont',

        );

      });
      

      print('Font loaded successfully: ${newStyle.fontFamily}');

    } catch (e) {

      print('Error loading font: $e');

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

      print('Error updating font: $e');

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

        selectedResolution: '${selectedSize.width.toInt()}x${selectedSize.height.toInt()}'

      );

    });

  }

}