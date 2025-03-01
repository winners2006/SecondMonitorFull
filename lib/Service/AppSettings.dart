import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:win32_registry/win32_registry.dart';
import 'package:second_monitor/Service/logger.dart';

class AppSettings {
  String videoFilePath = '';
  String videoUrl = '';
  bool isVideoFromInternet = true;
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
  final String sideAdvertType;
  final String sideAdvertPath;
  final String sideAdvertUrl;
  final bool isSideAdvertContentFromInternet;
  final bool isDarkTheme;
  final bool useAlternatingRowColors;
  final Color evenRowColor;
  final Color oddRowColor;
  final bool useCommonWidgetColor;
  final Color commonWidgetColor;

  AppSettings({
    String videoFilePath = '',
    String videoUrl = '',
    bool isVideoFromInternet = true,
    required this.showLoyaltyWidget,
    required this.backgroundColor,
    required this.borderColor,
    required this.backgroundImagePath,
    required this.useBackgroundImage,
    required this.logoPath,
    required this.showAdvertWithoutSales,
    required this.showSideAdvert,
    required this.sideAdvertType,
    required this.sideAdvertPath,
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
    this.sideAdvertUrl = '',
    required this.isSideAdvertContentFromInternet,
    this.isDarkTheme = false,
    this.useAlternatingRowColors = false,
    this.evenRowColor = const Color(0xFFFFFFFF),
    this.oddRowColor = const Color(0xFFF5F5F5),
    this.useCommonWidgetColor = false,
    this.commonWidgetColor = Colors.white,
  }) {
    this.videoFilePath = videoFilePath;
    this.videoUrl = videoUrl;
    this.isVideoFromInternet = isVideoFromInternet;
  }

  static Future<AppSettings> loadSettings() async {
    try {
      final appDataDir = await _getAppDataPath();
      final settingsFile = File('$appDataDir/settings.json');

      if (await settingsFile.exists()) {
        final jsonString = await settingsFile.readAsString();
        final jsonData = jsonDecode(jsonString);
        log('Loading settings from file:');
        // Проверяем тип рекламы и пути
        if (jsonData['sideAdvertType'] == 'image' &&
            jsonData['sideAdvertPath'].toString().isNotEmpty) {
          // Если тип - изображение, очищаем путь к видео
          jsonData['sideAdvertVideoPath'] = '';
        }
        return AppSettings.fromJson(jsonData);
      }
    } catch (e) {
      log('Error loading settings: $e');
    }
    // Возвращаем настройки по умолчанию, если не удалось загрузить
    return AppSettings(
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
      sideAdvertType: 'video',
      sideAdvertPath: '',
      sideAdvertVideoPath: '',
      isSideAdvertFromInternet: true,
      sideAdvertVideoUrl: '',
      widgetPositions: {},
      logoPosition: const {'x': 10.0, 'y': 10.0, 'w': 100.0, 'h': 50.0},
      selectedResolution: '1920x1080',
      autoStart: false,
      useInactivityTimer: true,
      inactivityTimeout: 50,
      openSettingsHotkey: 'Ctrl + Shift + S',
      closeMainWindowHotkey: 'Ctrl + Shift + L',
      showLogo: true,
      showPaymentQR: true,
      showSummary: true,
      webSocketUrl: 'localhost',
      httpUrl: 'localhost',
      isVersion85: false,
      webSocketPort: 4002,
      httpPort: 4001,
      advertVideoPath: '',
      advertVideoUrl: '',
      isAdvertFromInternet: true,
      loyaltyWidgetColor: Colors.white,
      paymentWidgetColor: Colors.white,
      summaryWidgetColor: Colors.white,
      itemsWidgetColor: Colors.white,
      loyaltyFontSize: 14.0,
      paymentFontSize: 14.0,
      summaryFontSize: 14.0,
      itemsFontSize: 14.0,
      loyaltyFontColor: Colors.black,
      paymentFontColor: Colors.black,
      summaryFontColor: Colors.black,
      itemsFontColor: Colors.black,
      customFontPath: '',
      fontFamily: '',
      sideAdvertUrl: '',
      isSideAdvertContentFromInternet: false,
      isDarkTheme: false,
      useAlternatingRowColors: false,
      evenRowColor: const Color(0xFFFFFFFF),
      oddRowColor: const Color(0xFFF5F5F5),
      useCommonWidgetColor: false,
      commonWidgetColor: Colors.white,
    );
  }

  static Future<void> saveSettings(AppSettings settings) async {
    try {
      final appDataPath = await _getAppDataPath();
      final settingsFile = File('$appDataPath\\settings.json');

      // Создаем директорию если её нет
      if (!await settingsFile.parent.exists()) {
        await settingsFile.parent.create(recursive: true);
      }

      final Map<String, dynamic> json = settings.toJson();

      log('Saving settings:');

      await settingsFile.writeAsString(jsonEncode(json));

      // Проверяем что файл создался
      if (await settingsFile.exists()) {
        final savedContent = await settingsFile.readAsString();
        final savedJson = jsonDecode(savedContent);
      }
    } catch (e) {
      log('Error saving settings: $e');
      log(e.toString());
    }
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
    final type = json['sideAdvertType'] ?? 'video';
    final path = json['sideAdvertPath'] ?? '';

    // Преобразование widgetPositions
    Map<String, Map<String, double>> convertedWidgetPositions = {};

    if (json['widgetPositions'] != null) {
      (json['widgetPositions'] as Map<String, dynamic>).forEach((key, value) {
        convertedWidgetPositions[key] = (value as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        );
      });
    }

    // Преобразование logoPosition
    Map<String, double> convertedLogoPosition = {};

    if (json['logoPosition'] != null) {
      (json['logoPosition'] as Map<String, dynamic>).forEach((key, value) {
        convertedLogoPosition[key] = (value as num).toDouble();
      });
    }

    return AppSettings(
      videoFilePath: json['videoFilePath'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      isVideoFromInternet: json['isVideoFromInternet'] ?? true,
      showLoyaltyWidget: json['showLoyaltyWidget'] ?? true,
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFFFFF),
      borderColor: Color(json['borderColor'] ?? Colors.black.value),
      backgroundImagePath: json['backgroundImagePath'] ?? '',
      useBackgroundImage: json['useBackgroundImage'] ?? false,
      logoPath: json['logoPath'] ?? '',
      showAdvertWithoutSales: json['showAdvertWithoutSales'] ?? false,
      showSideAdvert: json['showSideAdvert'] ?? false,
      sideAdvertType: type,
      sideAdvertPath: path,
      sideAdvertVideoPath: type == 'video' ? path : '',
      isSideAdvertFromInternet: json['isSideAdvertFromInternet'] ?? true,
      sideAdvertVideoUrl: json['sideAdvertVideoUrl'] ?? '',
      widgetPositions: convertedWidgetPositions,
      logoPosition: convertedLogoPosition,
      selectedResolution: json['selectedResolution'] ?? '1920x1080',
      autoStart: json['autoStart'] ?? false,
      useInactivityTimer: json['useInactivityTimer'] ?? true,
      inactivityTimeout: json['inactivityTimeout'] ?? 50,
      openSettingsHotkey: json['openSettingsHotkey'] ?? 'Ctrl + Shift + S',
      closeMainWindowHotkey:
          json['closeMainWindowHotkey'] ?? 'Ctrl + Shift + L',
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
      loyaltyWidgetColor: Color(json['loyaltyWidgetColor'] ?? 0xFFFFFFFF),
      paymentWidgetColor: Color(json['paymentWidgetColor'] ?? 0xFFFFFFFF),
      summaryWidgetColor: Color(json['summaryWidgetColor'] ?? 0xFFFFFFFF),
      itemsWidgetColor: Color(json['itemsWidgetColor'] ?? 0xFFFFFFFF),
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
      sideAdvertUrl: json['sideAdvertUrl'] ?? '',
      isSideAdvertContentFromInternet:
          json['isSideAdvertContentFromInternet'] ?? false,
      isDarkTheme: json['isDarkTheme'] ?? false,
      useAlternatingRowColors: json['useAlternatingRowColors'] ?? false,
      evenRowColor: Color(json['evenRowColor'] ?? 0xFFFFFFFF),
      oddRowColor: Color(json['oddRowColor'] ?? 0xFFF5F5F5),
      useCommonWidgetColor: json['useCommonWidgetColor'] ?? false,
      commonWidgetColor: Color(json['commonWidgetColor'] ?? 0xFFFFFFFF),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
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
      'sideAdvertType': sideAdvertType,
      'sideAdvertPath': sideAdvertPath,
      'sideAdvertVideoPath': sideAdvertType == 'video' ? sideAdvertPath : '',
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
      'sideAdvertUrl': sideAdvertUrl,
      'isSideAdvertContentFromInternet': isSideAdvertContentFromInternet,
      'isDarkTheme': isDarkTheme,
      'useAlternatingRowColors': useAlternatingRowColors,
      'evenRowColor': evenRowColor.value,
      'oddRowColor': oddRowColor.value,
      'useCommonWidgetColor': useCommonWidgetColor,
      'commonWidgetColor': commonWidgetColor.value,
    };

    log('Saving settings to JSON:');
    log('videoFilePath: ${data['videoFilePath']}');
    log('showAdvertWithoutSales: ${data['showAdvertWithoutSales']}');

    return data;
  }

  AppSettings copyWith({
    String? customFontPath,
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
    String? selectedResolution,
    String? sideAdvertType,
    String? sideAdvertPath,
    bool? isSideAdvertContentFromInternet,
    String? sideAdvertUrl,
    bool? isDarkTheme,
    bool? useAlternatingRowColors,
    Color? evenRowColor,
    Color? oddRowColor,
    bool? useCommonWidgetColor,
    Color? commonWidgetColor,
    bool? autoStart,
    bool? useInactivityTimer,
    int? inactivityTimeout,
    String? webSocketUrl,
    String? httpUrl,
    bool? isVersion85,
    int? webSocketPort,
    int? httpPort,
    bool? showLogo,
    bool? showPaymentQR,
    bool? showSummary,
    String? advertVideoPath,
    String? advertVideoUrl,
    bool? isAdvertFromInternet,
    Map<String, double>? logoPosition,
  }) {
    log('copyWith called with:');
    log('sideAdvertPath: $sideAdvertPath');
    log('sideAdvertVideoPath: $sideAdvertVideoPath');

    return AppSettings(
      customFontPath: customFontPath ?? this.customFontPath,
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
      isSideAdvertFromInternet:
          isSideAdvertFromInternet ?? this.isSideAdvertFromInternet,
      sideAdvertVideoPath: sideAdvertVideoPath ?? this.sideAdvertVideoPath,
      sideAdvertVideoUrl: sideAdvertVideoUrl ?? this.sideAdvertVideoUrl,
      widgetPositions: widgetPositions ?? this.widgetPositions,
      showAdvertWithoutSales:
          showAdvertWithoutSales ?? this.showAdvertWithoutSales,
      openSettingsHotkey: openSettingsHotkey ?? this.openSettingsHotkey,
      closeMainWindowHotkey:
          closeMainWindowHotkey ?? this.closeMainWindowHotkey,
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
      autoStart: autoStart ?? this.autoStart,
      useInactivityTimer: useInactivityTimer ?? this.useInactivityTimer,
      inactivityTimeout: inactivityTimeout ?? this.inactivityTimeout,
      showLogo: showLogo ?? this.showLogo,
      showPaymentQR: showPaymentQR ?? this.showPaymentQR,
      showSummary: showSummary ?? this.showSummary,
      webSocketUrl: webSocketUrl ?? this.webSocketUrl,
      httpUrl: httpUrl ?? this.httpUrl,
      isVersion85: isVersion85 ?? this.isVersion85,
      webSocketPort: webSocketPort ?? this.webSocketPort,
      httpPort: httpPort ?? this.httpPort,
      advertVideoPath: advertVideoPath ?? this.advertVideoPath,
      advertVideoUrl: advertVideoUrl ?? this.advertVideoUrl,
      isAdvertFromInternet: isAdvertFromInternet ?? this.isAdvertFromInternet,
      fontFamily: fontFamily ?? this.fontFamily,
      selectedResolution: selectedResolution ?? this.selectedResolution,
      sideAdvertType: sideAdvertType ?? this.sideAdvertType,
      sideAdvertPath: sideAdvertPath ?? this.sideAdvertPath,
      isSideAdvertContentFromInternet: isSideAdvertContentFromInternet ??
          this.isSideAdvertContentFromInternet,
      sideAdvertUrl: sideAdvertUrl ?? this.sideAdvertUrl,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      useAlternatingRowColors:
          useAlternatingRowColors ?? this.useAlternatingRowColors,
      evenRowColor: evenRowColor ?? this.evenRowColor,
      oddRowColor: oddRowColor ?? this.oddRowColor,
      useCommonWidgetColor: useCommonWidgetColor ?? this.useCommonWidgetColor,
      commonWidgetColor: commonWidgetColor ?? this.commonWidgetColor,
      logoPosition: logoPosition ?? this.logoPosition,
    );
  }

  static Future<String> _getAppDataPath() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];

      return '$appData\\SecondMonitor';
    } else {
      final home = Platform.environment['HOME'];

      return '$home/.secondmonitor';
    }
  }
}