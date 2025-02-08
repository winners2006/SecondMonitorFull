import 'dart:io';
import 'package:intl/intl.dart';

class Logger {
  static File? _logFile;
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  
  // Приватный конструктор
  Logger._();
  
  // Синхронная инициализация
  static void _initializeSync() {
    if (_logFile != null) return;
    
    try {
      // Создаем файл в корне приложения
      const fileName = 'app_log.txt';
      _logFile = File(fileName);
      
      // Создаем файл, если его нет
      if (!_logFile!.existsSync()) {
        _logFile!.createSync();
      }

      // Пишем информацию о запуске
      final timestamp = _dateFormat.format(DateTime.now());
      _logFile?.writeAsStringSync(
        '[$timestamp] ====== Application Started ======\n',
        mode: FileMode.append,
        flush: true,
      );
      
      print('Log file created at: ${_logFile?.absolute.path}');
    } catch (e) {
      print('Logger initialization error: $e');
      print('Current directory: ${Directory.current.path}');
    }
  }
  
  // Синхронная запись лога
  static void logSync(String message) {
    try {
      _initializeSync();
      
      final timestamp = _dateFormat.format(DateTime.now());
      final logMessage = '[$timestamp] $message\n';
      
      _logFile?.writeAsStringSync(
        logMessage,
        mode: FileMode.append,
        flush: true,
      );
      
      // Дублируем в консоль для отладки
      print(logMessage);
    } catch (e) {
      print('Logging error: $e');
    }
  }

  // Получить путь к файлу лога
  static String? getLogPath() {
    return _logFile?.path;
  }
}

// Глобальная функция для удобного доступа к логгеру
void log(String message) {
  Logger.logSync(message);
}