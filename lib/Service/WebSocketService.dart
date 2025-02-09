import 'dart:io';
import 'package:second_monitor/Service/logger.dart';
import 'dart:async';

/// Сервис WebSocket для обмена данными в реальном времени.
/// 
/// Класс обеспечивает:
/// - Установку WebSocket-соединения с сервером
/// - Автоматическое переподключение при обрыве связи
/// - Обработку входящих сообщений через callback-функцию
/// - Мониторинг состояния соединения
/// 
/// Пример использования:
/// ```dart
/// final ws = WebSocketService();
/// ws.setOnDataReceived((message) {
///   log('Получены данные: $message');
/// });
/// ws.connect('ws://localhost:4002/ws/');
/// ```
class WebSocketService {
  WebSocket? _socket;
  late Function(dynamic message) _onDataReceived;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  final Duration _reconnectDelay = const Duration(seconds: 5);

  /// Устанавливает callback-функцию для обработки входящих сообщений
  /// 
  /// [callback] - функция, которая будет вызываться при получении новых данных
  void setOnDataReceived(Function(dynamic message) callback) {
    _onDataReceived = callback;
  }

  /// Устанавливает WebSocket-соединение с сервером
  /// 
  /// [url] - адрес WebSocket-сервера (например, 'ws://localhost:4002/ws/')
  /// При обрыве соединения автоматически пытается переподключиться
  Future<void> connect(String url) async {
    try {
      log('Attempting to connect to WebSocket at $url');
      
      if (_socket != null) {
        await _socket!.close();
        _socket = null;
      }
      
      _socket = await WebSocket.connect(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log('WebSocket connection timeout');
          throw TimeoutException('Connection took too long');
        },
      );
      
      _isConnected = true;
      log('WebSocket client connected');
      
      _socket!.listen(
        (data) {
          // Обработка входящих сообщений
          log('Received WebSocket message: $data');
          try {
            _onDataReceived(data);
          } catch (e) {
            log('WebSocketService: Error processing message: $e');
          }
        },
        onError: (error) {
          log('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          log('WebSocket connection closed');
          _handleDisconnect();
        },
        cancelOnError: false,
      );
      
    } catch (e) {
      log('WebSocket connection error: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _socket = null;
    
    // Запускаем таймер переподключения
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isConnected) {
        connect('ws://localhost:4002/ws/');
      }
    });
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
    _isConnected = false;
  }

  /// Возвращает текущий статус подключения
  bool get isConnected => _isConnected;
}
