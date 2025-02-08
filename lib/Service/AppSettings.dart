import 'dart:async';

import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:win32_registry/win32_registry.dart';

import 'package:second_monitor/Service/logger.dart';



class AppSettings {

  final bool isFullScreen;

  final String videoFilePath;

  final String videoUrl;

  final bool isVideoFromInternet;

  final bool showLoyaltyWidget;

  final Color backgroundColor;

  final Color borderColor;

  final String backgroundImagePath;

  final bool useBackgroundImage;

  final String logoPath;

  final bool showAdvertWithoutSales;

  final bool showSideAdvert;

  final String sideAdvertVideoPath;

  final bool isSideAdvertFromInternet;

  final String sideAdvertVideoUrl;

  final Map<String, Map<String, double>> widgetPositions;

  final Map<String, double> logoPosition;

  final String selectedResolution;

  final bool autoStart;

  final bool useInactivityTimer;

  final int inactivityTimeout;

  String openSettingsHotkey;

  String closeMainWindowHotkey;

  final bool showLogo;

  final bool showPaymentQR;

  final bool showSummary;

  final String webSocketUrl;

  final String httpUrl;

  final bool isVersion85;

  final int webSocketPort;

  final int httpPort;

  final String advertVideoPath;

  final String advertVideoUrl;

  final bool isAdvertFromInternet;

  final Color loyaltyWidgetColor;

  final Color paymentWidgetColor;

  final Color summaryWidgetColor;

  final Color itemsWidgetColor;

  final double loyaltyFontSize;

  final double paymentFontSize;

  final double summaryFontSize;

  final double itemsFontSize;

  final Color loyaltyFontColor;

  final Color paymentFontColor;

  final Color summaryFontColor;

  final Color itemsFontColor;

  final String customFontPath;

  final String fontFamily;



  AppSettings({

    required this.isFullScreen,

    required this.videoFilePath,

    required this.videoUrl,

    required this.isVideoFromInternet,

    required this.showLoyaltyWidget,

    required this.backgroundColor,

    required this.borderColor,

    required this.backgroundImagePath,

    required this.useBackgroundImage,

    required this.logoPath,

    required this.showAdvertWithoutSales,

    required this.showSideAdvert,

    required this.sideAdvertVideoPath,

    required this.isSideAdvertFromInternet,

    required this.sideAdvertVideoUrl,

    required this.widgetPositions,

    this.logoPosition = const {

      'x': 10.0,

      'y': 10.0,

      'w': 100.0,

      'h': 50.0,

    },

    this.selectedResolution = '1920x1080',

    this.autoStart = false,

    this.useInactivityTimer = true,

    this.inactivityTimeout = 50,

    this.openSettingsHotkey = 'Ctrl + Shift + S',

    this.closeMainWindowHotkey = 'Ctrl + Shift + L',

    this.showLogo = true,

    this.showPaymentQR = true,

    this.showSummary = true,

    this.webSocketUrl = 'localhost',

    this.httpUrl = 'localhost',

    this.isVersion85 = false,

    this.webSocketPort = 4002,

    this.httpPort = 4001,

    this.advertVideoPath = '',

    this.advertVideoUrl = '',

    this.isAdvertFromInternet = true,

    this.loyaltyWidgetColor = Colors.white,

    this.paymentWidgetColor = Colors.white,

    this.summaryWidgetColor = Colors.white,

    this.itemsWidgetColor = Colors.white,

    this.loyaltyFontSize = 14.0,

    this.paymentFontSize = 14.0,

    this.summaryFontSize = 14.0,

    this.itemsFontSize = 14.0,

    this.loyaltyFontColor = Colors.black,

    this.paymentFontColor = Colors.black,

    this.summaryFontColor = Colors.black,

    this.itemsFontColor = Colors.black,

    this.customFontPath = '',

    this.fontFamily = '',

  });



  static Future<AppSettings> loadSettings() async {

    final prefs = await SharedPreferences.getInstance();



    bool isFullScreen = prefs.getBool('isFullScreen') ?? false;

    String videoFilePath = prefs.getString('videoFilePath') ?? '';

    String videoUrl = prefs.getString('videoUrl') ?? '';

    bool isVideoFromInternet = prefs.getBool('isVideoFromInternet') ?? true;

    bool showLoyaltyWidget = prefs.getBool('showLoyaltyWidget') ?? true;

    Color backgroundColor = Color(prefs.getInt('backgroundColor') ?? Colors.white.value);

    Color borderColor = Color(prefs.getInt('borderColor') ?? Colors.black.value);

    String backgroundImagePath = prefs.getString('backgroundImagePath') ?? '';

    bool useBackgroundImage = prefs.getBool('useBackgroundImage') ?? false;

    String logoPath = prefs.getString('logoPath') ?? '';

    bool showAdvertWithoutSales = prefs.getBool('showAdvertWithoutSales') ?? false;

    bool showSideAdvert = prefs.getBool('showSideAdvert') ?? false;

    String sideAdvertVideoPath = prefs.getString('sideAdvertVideoPath') ?? '';

    bool isSideAdvertFromInternet = prefs.getBool('isSideAdvertFromInternet') ?? true;

    String sideAdvertVideoUrl = prefs.getString('sideAdvertVideoUrl') ?? '';

    Map<String, Map<String, double>> widgetPositions = {};



    // Загрузка позиций виджетов

    final widgetPositionsStr = prefs.getString('widgetPositions');

    

    if (widgetPositionsStr != null) {

      final decoded = jsonDecode(widgetPositionsStr);

      (decoded as Map<String, dynamic>).forEach((key, value) {

        widgetPositions[key] = {

          'x': (value['x'] as num).toDouble(),

          'y': (value['y'] as num).toDouble(),

          'w': (value['w'] as num?)?.toDouble() ?? 200.0,

          'h': (value['h'] as num?)?.toDouble() ?? 150.0,

        };

      });

    } else {

      widgetPositions = {

        'loyalty': {'x': 0.0, 'y': 0.0, 'w': 200.0, 'h': 150.0},

        'payment': {'x': 220.0, 'y': 0.0, 'w': 200.0, 'h': 150.0},

        'summary': {'x': 440.0, 'y': 0.0, 'w': 200.0, 'h': 150.0},

        'sideAdvert': {'x': 660.0, 'y': 0.0, 'w': 200.0, 'h': 300.0},

        'items': {'x': 0.0, 'y': 400.0, 'w': 800.0, 'h': 300.0},

      };

    }



    final logoPositionStr = prefs.getString('logoPosition');

    Map<String, double> logoPosition = {

      'x': 10.0,

      'y': 10.0,

      'w': 100.0,

      'h': 50.0,

    };

    if (logoPositionStr != null) {

      final Map<String, dynamic> decoded = jsonDecode(logoPositionStr);

      logoPosition = decoded.map((key, value) => MapEntry(key, value.toDouble()));

    }



    String selectedResolution = prefs.getString('selectedResolution') ?? '1920x1080';

    bool autoStart = prefs.getBool('autoStart') ?? false;

    bool useInactivityTimer = prefs.getBool('useInactivityTimer') ?? true;

    int inactivityTimeout = prefs.getInt('inactivityTimeout') ?? 50;



    String openSettingsHotkey = prefs.getString('openSettingsHotkey') ?? 'Ctrl + Shift + S';

    String closeMainWindowHotkey = prefs.getString('closeMainWindowHotkey') ?? 'Ctrl + Shift + L';



    return AppSettings(

      isFullScreen: isFullScreen,

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

      openSettingsHotkey: openSettingsHotkey,

      closeMainWindowHotkey: closeMainWindowHotkey,

      showLogo: prefs.getBool('showLogo') ?? true,

      showPaymentQR: prefs.getBool('showPaymentQR') ?? true,

      showSummary: prefs.getBool('showSummary') ?? true,

      webSocketUrl: prefs.getString('webSocketUrl') ?? 'localhost',

      httpUrl: prefs.getString('httpUrl') ?? 'localhost',

      isVersion85: prefs.getBool('isVersion85') ?? false,

      webSocketPort: prefs.getInt('webSocketPort') ?? 4002,

      httpPort: prefs.getInt('httpPort') ?? 4001,

      advertVideoPath: prefs.getString('advertVideoPath') ?? '',

      advertVideoUrl: prefs.getString('advertVideoUrl') ?? '',

      isAdvertFromInternet: prefs.getBool('isAdvertFromInternet') ?? true,

      loyaltyWidgetColor: Color(prefs.getInt('loyaltyWidgetColor') ?? Colors.white.value),

      paymentWidgetColor: Color(prefs.getInt('paymentWidgetColor') ?? Colors.white.value),

      summaryWidgetColor: Color(prefs.getInt('summaryWidgetColor') ?? Colors.white.value),

      itemsWidgetColor: Color(prefs.getInt('itemsWidgetColor') ?? Colors.white.value),

      loyaltyFontSize: prefs.getDouble('loyaltyFontSize') ?? 14.0,

      paymentFontSize: prefs.getDouble('paymentFontSize') ?? 14.0,

      summaryFontSize: prefs.getDouble('summaryFontSize') ?? 14.0,

      itemsFontSize: prefs.getDouble('itemsFontSize') ?? 14.0,

      loyaltyFontColor: Color(prefs.getInt('loyaltyFontColor') ?? Colors.black.value),

      paymentFontColor: Color(prefs.getInt('paymentFontColor') ?? Colors.black.value),

      summaryFontColor: Color(prefs.getInt('summaryFontColor') ?? Colors.black.value),

      itemsFontColor: Color(prefs.getInt('itemsFontColor') ?? Colors.black.value),

      customFontPath: prefs.getString('customFontPath') ?? '',

      fontFamily: prefs.getString('fontFamily') ?? '',

    );

  }



  Future<void> saveSettings() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isFullScreen', isFullScreen);

    await prefs.setString('videoFilePath', videoFilePath);

    await prefs.setString('videoUrl', videoUrl);

    await prefs.setBool('isVideoFromInternet', isVideoFromInternet);

    await prefs.setBool('showLoyaltyWidget', showLoyaltyWidget);

    await prefs.setInt('backgroundColor', backgroundColor.value);

    await prefs.setInt('borderColor', borderColor.value);

    await prefs.setString('backgroundImagePath', backgroundImagePath);

    await prefs.setBool('useBackgroundImage', useBackgroundImage);

    await prefs.setString('logoPath', logoPath);

    await prefs.setBool('showAdvertWithoutSales', showAdvertWithoutSales);

    await prefs.setBool('showSideAdvert', showSideAdvert);

    await prefs.setString('sideAdvertVideoPath', sideAdvertVideoPath);

    await prefs.setBool('isSideAdvertFromInternet', isSideAdvertFromInternet);

    await prefs.setString('sideAdvertVideoUrl', sideAdvertVideoUrl);

    

    // Сохранение позиций виджетов

    await prefs.setString('widgetPositions', jsonEncode(widgetPositions));

    await prefs.setString('logoPosition', jsonEncode(logoPosition));

    await prefs.setString('selectedResolution', selectedResolution);

    await prefs.setBool('autoStart', autoStart);

    await prefs.setBool('useInactivityTimer', useInactivityTimer);

    await prefs.setInt('inactivityTimeout', inactivityTimeout);

    await prefs.setString('openSettingsHotkey', openSettingsHotkey);

    await prefs.setString('closeMainWindowHotkey', closeMainWindowHotkey);

    await prefs.setBool('showLogo', showLogo);

    await prefs.setBool('showPaymentQR', showPaymentQR);

    await prefs.setBool('showSummary', showSummary);

    await prefs.setString('webSocketUrl', webSocketUrl);

    await prefs.setString('httpUrl', httpUrl);

    await prefs.setBool('isVersion85', isVersion85);

    await prefs.setInt('webSocketPort', webSocketPort);

    await prefs.setInt('httpPort', httpPort);

    await prefs.setString('advertVideoPath', advertVideoPath);

    await prefs.setString('advertVideoUrl', advertVideoUrl);

    await prefs.setBool('isAdvertFromInternet', isAdvertFromInternet);

    await prefs.setInt('loyaltyWidgetColor', loyaltyWidgetColor.value);

    await prefs.setInt('paymentWidgetColor', paymentWidgetColor.value);

    await prefs.setInt('summaryWidgetColor', summaryWidgetColor.value);

    await prefs.setInt('itemsWidgetColor', itemsWidgetColor.value);

    await prefs.setDouble('loyaltyFontSize', loyaltyFontSize);

    await prefs.setDouble('paymentFontSize', paymentFontSize);

    await prefs.setDouble('summaryFontSize', summaryFontSize);

    await prefs.setDouble('itemsFontSize', itemsFontSize);

    await prefs.setInt('loyaltyFontColor', loyaltyFontColor.value);

    await prefs.setInt('paymentFontColor', paymentFontColor.value);

    await prefs.setInt('summaryFontColor', summaryFontColor.value);

    await prefs.setInt('itemsFontColor', itemsFontColor.value);

    await prefs.setString('customFontPath', customFontPath);

    await prefs.setString('fontFamily', fontFamily);

  }



  Future<void> setAutoStart(bool enable) async {

    try {

      final key = Registry.openPath(RegistryHive.currentUser,

          path: r'Software\Microsoft\Windows\CurrentVersion\Run',

          desiredAccessRights: AccessRights.allAccess);

      

      if (enable) {

        final exePath = Platform.resolvedExecutable;

        // Добавляем параметр для автоматического запуска второго монитора

        key.createValue(RegistryValue(

          'SecondMonitor',

          RegistryValueType.string,

          '$exePath --autostart',

        ));

      } else {

        if (key.getValue('SecondMonitor') != null) {

          key.deleteValue('SecondMonitor');

        }

      }

      key.close();

    } catch (e) {

      log('Error setting autostart: $e');

    }

  }



  // Проверка статуса автозапуска

  Future<bool> checkAutoStart() async {

    try {

      final key = Registry.openPath(RegistryHive.currentUser,

          path: r'Software\Microsoft\Windows\CurrentVersion\Run');

      

      final value = key.getValue('SecondMonitor');

      key.close();

      

      return value != null;

    } catch (e) {

      log('Error checking autostart: $e');

      return false;

    }

  }



  factory AppSettings.fromJson(Map<String, dynamic> json) {

    return AppSettings(

      isFullScreen: json['isFullScreen'] ?? false,

      videoFilePath: json['videoFilePath'] ?? '',

      videoUrl: json['videoUrl'] ?? '',

      isVideoFromInternet: json['isVideoFromInternet'] ?? true,

      showLoyaltyWidget: json['showLoyaltyWidget'] ?? true,

      backgroundColor: Color(json['backgroundColor'] ?? Colors.white.value),

      borderColor: Color(json['borderColor'] ?? Colors.black.value),

      backgroundImagePath: json['backgroundImagePath'] ?? '',

      useBackgroundImage: json['useBackgroundImage'] ?? false,

      logoPath: json['logoPath'] ?? '',

      showAdvertWithoutSales: json['showAdvertWithoutSales'] ?? false,

      showSideAdvert: json['showSideAdvert'] ?? false,

      sideAdvertVideoPath: json['sideAdvertVideoPath'] ?? '',

      isSideAdvertFromInternet: json['isSideAdvertFromInternet'] ?? true,

      sideAdvertVideoUrl: json['sideAdvertVideoUrl'] ?? '',

      widgetPositions: json['widgetPositions'] ?? {},

      logoPosition: json['logoPosition'] ?? const {'x': 10.0, 'y': 10.0, 'w': 100.0, 'h': 50.0},

      selectedResolution: json['selectedResolution'] ?? '1920x1080',

      autoStart: json['autoStart'] ?? false,

      useInactivityTimer: json['useInactivityTimer'] ?? true,

      inactivityTimeout: json['inactivityTimeout'] ?? 50,

      openSettingsHotkey: json['openSettingsHotkey'] ?? 'Ctrl + Shift + S',

      closeMainWindowHotkey: json['closeMainWindowHotkey'] ?? 'Ctrl + Shift + L',

      showLogo: json['showLogo'] ?? true,

      showPaymentQR: json['showPaymentQR'] ?? true,

      showSummary: json['showSummary'] ?? true,

      webSocketUrl: json['webSocketUrl'] ?? 'localhost',

      httpUrl: json['httpUrl'] ?? 'localhost',

      isVersion85: json['isVersion85'] ?? false,

      webSocketPort: json['webSocketPort'] ?? 4002,

      httpPort: json['httpPort'] ?? 4001,

      advertVideoPath: json['advertVideoPath'] ?? '',

      advertVideoUrl: json['advertVideoUrl'] ?? '',

      isAdvertFromInternet: json['isAdvertFromInternet'] ?? true,

      loyaltyWidgetColor: Color(json['loyaltyWidgetColor'] ?? Colors.white.value),

      paymentWidgetColor: Color(json['paymentWidgetColor'] ?? Colors.white.value),

      summaryWidgetColor: Color(json['summaryWidgetColor'] ?? Colors.white.value),

      itemsWidgetColor: Color(json['itemsWidgetColor'] ?? Colors.white.value),

      loyaltyFontSize: json['loyaltyFontSize'] ?? 14.0,

      paymentFontSize: json['paymentFontSize'] ?? 14.0,

      summaryFontSize: json['summaryFontSize'] ?? 14.0,

      itemsFontSize: json['itemsFontSize'] ?? 14.0,

      loyaltyFontColor: Color(json['loyaltyFontColor'] ?? Colors.black.value),

      paymentFontColor: Color(json['paymentFontColor'] ?? Colors.black.value),

      summaryFontColor: Color(json['summaryFontColor'] ?? Colors.black.value),

      itemsFontColor: Color(json['itemsFontColor'] ?? Colors.black.value),

      customFontPath: json['customFontPath'] ?? '',

      fontFamily: json['fontFamily'] ?? '',

    );

  }



  Map<String, dynamic> toJson() {

    return {

      'isFullScreen': isFullScreen,

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

      'selectedResolution': selectedResolution,

      'autoStart': autoStart,

      'useInactivityTimer': useInactivityTimer,

      'inactivityTimeout': inactivityTimeout,

      'openSettingsHotkey': openSettingsHotkey,

      'closeMainWindowHotkey': closeMainWindowHotkey,

      'showLogo': showLogo,

      'showPaymentQR': showPaymentQR,

      'showSummary': showSummary,

      'webSocketUrl': webSocketUrl,

      'httpUrl': httpUrl,

      'isVersion85': isVersion85,

      'webSocketPort': webSocketPort,

      'httpPort': httpPort,

      'advertVideoPath': advertVideoPath,

      'advertVideoUrl': advertVideoUrl,

      'isAdvertFromInternet': isAdvertFromInternet,

      'loyaltyWidgetColor': loyaltyWidgetColor.value,

      'paymentWidgetColor': paymentWidgetColor.value,

      'summaryWidgetColor': summaryWidgetColor.value,

      'itemsWidgetColor': itemsWidgetColor.value,

      'loyaltyFontSize': loyaltyFontSize,

      'paymentFontSize': paymentFontSize,

      'summaryFontSize': summaryFontSize,

      'itemsFontSize': itemsFontSize,

      'loyaltyFontColor': loyaltyFontColor.value,

      'paymentFontColor': paymentFontColor.value,

      'summaryFontColor': summaryFontColor.value,

      'itemsFontColor': itemsFontColor.value,

      'customFontPath': customFontPath,

      'fontFamily': fontFamily,

    };

  }



  AppSettings copyWith({

    String? customFontPath,

    bool? isFullScreen,

    String? videoFilePath,

    String? videoUrl,

    bool? isVideoFromInternet,

    bool? showLoyaltyWidget,

    Color? backgroundColor,

    Color? borderColor,

    String? backgroundImagePath,

    bool? useBackgroundImage,

    String? logoPath,

    bool? showSideAdvert,

    bool? isSideAdvertFromInternet,

    String? sideAdvertVideoPath,

    String? sideAdvertVideoUrl,

    Map<String, Map<String, double>>? widgetPositions,

    bool? showAdvertWithoutSales,

    String? openSettingsHotkey,

    String? closeMainWindowHotkey,

    Color? loyaltyWidgetColor,

    Color? paymentWidgetColor,

    Color? summaryWidgetColor,

    Color? itemsWidgetColor,

    double? loyaltyFontSize,

    Color? loyaltyFontColor,

    double? paymentFontSize,

    Color? paymentFontColor,

    double? summaryFontSize,

    Color? summaryFontColor,

    double? itemsFontSize,

    Color? itemsFontColor,

    String? fontFamily,

  }) {

    return AppSettings(

      customFontPath: customFontPath ?? this.customFontPath,

      isFullScreen: isFullScreen ?? this.isFullScreen,

      videoFilePath: videoFilePath ?? this.videoFilePath,

      videoUrl: videoUrl ?? this.videoUrl,

      isVideoFromInternet: isVideoFromInternet ?? this.isVideoFromInternet,

      showLoyaltyWidget: showLoyaltyWidget ?? this.showLoyaltyWidget,

      backgroundColor: backgroundColor ?? this.backgroundColor,

      borderColor: borderColor ?? this.borderColor,

      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,

      useBackgroundImage: useBackgroundImage ?? this.useBackgroundImage,

      logoPath: logoPath ?? this.logoPath,

      showSideAdvert: showSideAdvert ?? this.showSideAdvert,

      isSideAdvertFromInternet: isSideAdvertFromInternet ?? this.isSideAdvertFromInternet,

      sideAdvertVideoPath: sideAdvertVideoPath ?? this.sideAdvertVideoPath,

      sideAdvertVideoUrl: sideAdvertVideoUrl ?? this.sideAdvertVideoUrl,

      widgetPositions: widgetPositions ?? this.widgetPositions,

      showAdvertWithoutSales: showAdvertWithoutSales ?? this.showAdvertWithoutSales,

      openSettingsHotkey: openSettingsHotkey ?? this.openSettingsHotkey,

      closeMainWindowHotkey: closeMainWindowHotkey ?? this.closeMainWindowHotkey,

      loyaltyWidgetColor: loyaltyWidgetColor ?? this.loyaltyWidgetColor,

      paymentWidgetColor: paymentWidgetColor ?? this.paymentWidgetColor,

      summaryWidgetColor: summaryWidgetColor ?? this.summaryWidgetColor,

      itemsWidgetColor: itemsWidgetColor ?? this.itemsWidgetColor,

      loyaltyFontSize: loyaltyFontSize ?? this.loyaltyFontSize,

      loyaltyFontColor: loyaltyFontColor ?? this.loyaltyFontColor,

      paymentFontSize: paymentFontSize ?? this.paymentFontSize,

      paymentFontColor: paymentFontColor ?? this.paymentFontColor,

      summaryFontSize: summaryFontSize ?? this.summaryFontSize,

      summaryFontColor: summaryFontColor ?? this.summaryFontColor,

      itemsFontSize: itemsFontSize ?? this.itemsFontSize,

      itemsFontColor: itemsFontColor ?? this.itemsFontColor,

      autoStart: this.autoStart,

      useInactivityTimer: this.useInactivityTimer,

      inactivityTimeout: this.inactivityTimeout,

      showLogo: this.showLogo,

      showPaymentQR: this.showPaymentQR,

      showSummary: this.showSummary,

      webSocketUrl: this.webSocketUrl,

      httpUrl: this.httpUrl,

      isVersion85: this.isVersion85,

      webSocketPort: this.webSocketPort,

      httpPort: this.httpPort,

      advertVideoPath: this.advertVideoPath,

      advertVideoUrl: this.advertVideoUrl,

      isAdvertFromInternet: this.isAdvertFromInternet,

      fontFamily: fontFamily ?? this.fontFamily,

    );

  }

}