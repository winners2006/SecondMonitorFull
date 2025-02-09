import 'dart:io';


class Logger {
  static final Logger _instance = Logger._internal();
  late File _logFile;
  
  factory Logger() {
    return _instance;
  }
  
  Logger._internal() {
    final appDir = Directory(Platform.resolvedExecutable).parent;
    _logFile = File('${appDir.path}/app_log.txt');
  }
  
  Future<void> log(String message) async {
    final timestamp = DateTime.now().toString();
    final logMessage = '[$timestamp] $message\n';
    
    try {
      await _logFile.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      log('Error writing to log: $e');
    }
  }
}

// Глобальная функция для удобного доступа к логгеру
void log(String message) async {
  await Logger().log(message);
}