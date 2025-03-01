class Config {
  // Настройки сервера лицензирования
  static const String licenseServerUrl = 'http://31.31.207.104';
  static const int licenseServerPort = 8080;
  
  // Эндпоинты - они совпадают с серверными маршрутами
  static const String verifyEndpoint = '/api/license/verify';
  static const String activateEndpoint = '/api/license/activate';
  static const String validateEndpoint = '/api/license/validate';
  
  // Таймауты
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration offlinePeriod = Duration(hours: 24);
  
  // Пробный период
  static const Duration trialPeriod = Duration(days: 3);
} 