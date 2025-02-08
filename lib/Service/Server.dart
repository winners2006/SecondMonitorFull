import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:second_monitor/Service/logger.dart';

/// Сервер для обработки HTTP-запросов от 1С.
/// 
/// Класс обеспечивает:
/// - Прием HTTP POST-запросов от 1С с данными о чеке, товарах и программе лояльности
/// - Режим совместимости с 1С 8.5 (отключение HTTP-сервера)
/// - Буферизацию полученных данных для последующей передачи через WebSocket
/// 
/// Пример использования:
/// ```dart
/// final server = Server();
/// server.setVersion85(false); // Использовать HTTP для версий младше 8.5
/// server.startServer('localhost', 4001);
/// ```
class Server {
  /// Буфер для хранения последних полученных данных от 1С
  String receivedDataFrom1C = '';
  
  /// Флаг режима совместимости с 1С 8.5
  bool _isVersion85 = false;

  HttpServer? _server;
  HttpServer? _wsServer;

  Server() {
    print('Server instance created');
  }

  /// Устанавливает режим совместимости с 1С 8.5
  /// 
  /// Если [value] = true, HTTP-сервер будет отключен
  void setVersion85(bool value) {
    _isVersion85 = value;
  }

  /// Запускает HTTP-сервер на указанном хосте и порту
  /// 
  /// [host] - адрес для прослушивания (например, 'localhost')
  /// [port] - порт для прослушивания (например, 4001)
  Future<void> startServer(String host, int port) async {
    if (_isVersion85) {
      print('HTTP server disabled in 1C 8.5 mode');
      return;
    }

    try {
      // Запускаем HTTP сервер
      _server = await HttpServer.bind(host, port);
      print('HTTP server started on $host:$port');

      // Запускаем WebSocket сервер
      _wsServer = await HttpServer.bind(
        InternetAddress.loopbackIPv4, 
        4002,
        shared: true  // Добавляем флаг shared
      );
      print('WebSocket server started on port 4002');

      // Обработка HTTP запросов
      _server!.listen(_handleRequest);

      // Обработка WebSocket подключений
      _wsServer!.listen((request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          print('Received WebSocket upgrade request');
          final socket = await WebSocketTransformer.upgrade(request);
          print('WebSocket client connected');
          _sendJsonData(socket);
        }
      });

    } catch (e) {
      print('Error starting servers: $e');
    }
  }

  /// Обрабатывает входящие HTTP-запросы
  /// 
  /// Принимает POST-запросы и сохраняет данные в [receivedDataFrom1C]
  void _handleRequest(HttpRequest request) async {
    try {
      if (request.method == 'POST') {
        final content = await utf8.decoder.bind(request).join();
        print('Raw POST content: $content');
        
        // Проверяем и форматируем JSON перед сохранением
        try {
          var jsonData = jsonDecode(content); // Проверяем, что это валидный JSON
          receivedDataFrom1C = jsonEncode(jsonData); // Переформатируем для гарантии чистоты
          print('Formatted JSON: $receivedDataFrom1C');
        } catch (e) {
          print('Invalid JSON received: $e');
          throw 'Invalid JSON format';
        }
      }

      request.response
        ..statusCode = HttpStatus.ok
        ..write('OK')
        ..close();
    } catch (e) {
      print('Request handling error: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error: $e')
        ..close();
    }
  }

  /// Отправляет накопленные данные через WebSocket-соединение
  /// 
  /// Периодически проверяет наличие новых данных в [receivedDataFrom1C]
  void _sendJsonData(WebSocket socket) async {
    try {
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (receivedDataFrom1C.isNotEmpty) {
          log('WebSocket sending data: $receivedDataFrom1C');
          socket.add(receivedDataFrom1C);
          receivedDataFrom1C = '';
        }

        if (socket.readyState != WebSocket.open) {
          timer.cancel();
        }
      });
    } catch (e) {
      log('WebSocket error sending data: $e');
      socket.close(WebSocketStatus.internalServerError, 'Ошибка сервера');
    }
  }

  /// Останавливает HTTP-сервер
  void stopServer() {
    _server?.close();
    _wsServer?.close();
  }
}

void main() async {
  final server = Server();
  await server.startServer('localhost', 4001);
}