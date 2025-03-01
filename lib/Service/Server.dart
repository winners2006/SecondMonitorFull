import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:second_monitor/Service/logger.dart';
import 'package:second_monitor/Service/AppSettings.dart';
import 'package:second_monitor/Service/WebSocketService.dart';

typedef DataCallback = void Function(dynamic data);

/// Сервер для обработки HTTP-запросов от 1С.
/// 
/// Класс обеспечивает:
/// - Прием HTTP POST-запросов от 1С с данными о чеке, товарах и программе лояльности
/// - Режим совместимости с 1С 8.5 (отключение HTTP-сервера)
/// - Буферизацию полученных данных для последующей передачи через WebSocket

class Server {
  /// Буфер для хранения последних полученных данных от 1С
  String receivedDataFrom1C = '';
  
  /// Флаг режима совместимости с 1С 8.5
  bool _isVersion85 = false;

  HttpServer? _server;
  HttpServer? _wsServer;

  final List<WebSocket> _connectedClients = [];  // Добавляем список клиентов
  final AppSettings settings;  // Добавляем поле для настроек

  DataCallback? _onDataReceived;

  static final WebSocketService _wsService = WebSocketService();

  Server(this.settings) {
    log('Server instance created');
  }

  /// Устанавливает режим совместимости с 1С 8.5
  /// 
  /// Если [value] = true, HTTP-сервер будет отключен
  void setVersion85(bool value) {
    _isVersion85 = value;
    log('Server mode set to: ${_isVersion85 ? "WebSocket only (1C 8.5)" : "HTTP + WebSocket"}');
  }

  /// Запускает HTTP-сервер на указанном хосте и порту
  /// 
  /// [host] - адрес для прослушивания (например, 'localhost')
  /// [port] - порт для прослушивания (например, 4001)
  Future<void> startServer(String host, int port) async {
    try {
      // Запускаем WebSocket сервер с параметрами из настроек
      _wsServer = await HttpServer.bind(
        settings.webSocketUrl,  // Используем URL из настроек
        settings.webSocketPort, // Используем порт из настроек
        shared: true
      );
      log('WebSocket server started on ${settings.webSocketUrl}:${settings.webSocketPort}');

      // Обработка WebSocket подключений
      _wsServer!.listen((request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          log('WebSocket upgrade request received');
          final socket = await WebSocketTransformer.upgrade(request);
          log('WebSocket client connected');
          
          _connectedClients.add(socket);
          
          socket.listen(
            (data) {
              log('WebSocket received data: $data');
              receivedDataFrom1C = data.toString();
              _broadcastData(data.toString());
            },
            onError: (error) {
              log('WebSocket error: $error');
              _connectedClients.remove(socket);
            },
            onDone: () {
              log('WebSocket connection closed');
              _connectedClients.remove(socket);
            },
          );
        }
      });

      // HTTP сервер использует свои параметры из настроек
      if (!_isVersion85) {
        _server = await HttpServer.bind(
          settings.httpUrl,   // Используем HTTP URL из настроек
          settings.httpPort   // Используем HTTP порт из настроек
        );
        log('HTTP server started on ${settings.httpUrl}:${settings.httpPort}');
        _server!.listen(_handleRequest);
      }

    } catch (e) {
      log('Error starting servers: $e');
      rethrow;
    }
  }

  /// Обрабатывает входящие HTTP-запросы
  /// 
  /// Принимает POST-запросы и сохраняет данные в [receivedDataFrom1C]
  void _handleRequest(HttpRequest request) async {
    if (request.method == 'POST') {
      try {
        final body = await utf8.decoder.bind(request).join();
        log('Received HTTP POST data: $body');
        
        if (_onDataReceived != null) {
          _onDataReceived!(body);
        }
        
        request.response
          ..statusCode = HttpStatus.ok
          ..write('OK')
          ..close();
      } catch (e) {
        log('Error handling request: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..close();
      }
    }
  }

  // Метод для рассылки данных всем подключенным клиентам
  void _broadcastData(String data) {
    log('Broadcasting data to ${_connectedClients.length} clients');
    for (var client in _connectedClients) {
      if (client.readyState == WebSocket.open) {
        try {
          client.add(data);
          log('Data sent to client');
        } catch (e) {
          log('Error sending data to client: $e');
        }
      }
    }
  }

  /// Останавливает HTTP-сервер
  void stopServer() {
    _server?.close();
    _wsServer?.close();
  }

  void setOnDataReceived(DataCallback callback) {
    _onDataReceived = callback;
  }

  static Future<void> initializeConnection() async {
    await _wsService.connect('ws://your-server:port');
    
    _wsService.messageStream.listen((message) {
      log('Received WebSocket message: $message');
    });
  }
  
  static void sendMessage(dynamic message) {
    _wsService.sendMessage(message);
  }
  
  static Future<void> dispose() async {
    await _wsService.dispose();
  }

  static void handleServerMessage(dynamic message) {
    try {
      log('Received WebSocket message: $message');
      // Обработка сообщения
      if (message is Map) {
        // Ваша логика обработки сообщений
      }
    } catch (e) {
      log('Error handling server message: $e');
    }
  }
}