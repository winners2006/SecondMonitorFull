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
///   print('Получены данные: $message');
/// });
/// ws.connect('ws://localhost:4002/ws/');
/// ```
class WebSocketService {
  WebSocket? _webSocket;
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
  /// [host] - хост WebSocket-сервера
  /// [port] - порт WebSocket-сервера
  /// При обрыве соединения автоматически пытается переподключиться
  Future<void> connect(String host, int port) async {
    if (_isConnected) return;

    final wsUrl = 'ws://$host:4002/ws';
    try {
      log('Attempting to connect to WebSocket at $wsUrl');
      _webSocket = await WebSocket.connect(wsUrl);
      _isConnected = true;
      _listenToMessages();
      _reconnectTimer?.cancel();
      log('WebSocket connected successfully');
    } catch (e) {
      log('WebSocket connection error: $e');
      _scheduleReconnect(host, 4002);
    }
  }

  /// Планирует повторное подключение при обрыве связи
  /// 
  /// [host] - хост для переподключения
  /// [port] - порт для переподключения
  /// Пытается переподключиться каждые 5 секунд
  void _scheduleReconnect(String host, int port) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () => connect(host, port));
  }

  /// Настраивает прослушивание входящих сообщений
  /// 
  /// Обрабатывает входящие сообщения, ошибки и закрытие соединения
  void _listenToMessages() {
    _webSocket?.listen(
      (data) {
        log('WebSocket received data: $data');
        try {
          _onDataReceived(data);
        } catch (e) {
          log('WebSocketService: Error processing message: $e');
        }
      },
      onError: (error) => {
        log('WebSocket error: $error'),
        log('WebSocketService: WebSocket error: $error'),
        _isConnected = false
      },
      onDone: () => {
        log('WebSocket connection closed'),
        log('WebSocketService: WebSocket connection closed'),
        _isConnected = false
      },
    );
  }

  /// Закрывает WebSocket-соединение
  /// 
  /// Отменяет попытки переподключения и закрывает текущее соединение
  void disconnect() {
    _reconnectTimer?.cancel();
    _webSocket?.close();
    _isConnected = false;
  }

  /// Возвращает текущий статус подключения
  bool get isConnected => _isConnected;
}