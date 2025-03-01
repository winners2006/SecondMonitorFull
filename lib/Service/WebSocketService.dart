import 'dart:io';
import 'package:second_monitor/Service/logger.dart';
import 'dart:async';
import 'dart:isolate';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  final Duration _pingInterval = const Duration(seconds: 30);
  final Duration _reconnectDelay = const Duration(seconds: 5);
  final StreamController<dynamic> _messageController = StreamController.broadcast();
  
  bool _isConnected = false;
  String? _serverUrl;
  
  // Отдельный поток для обработки WebSocket сообщений
  Isolate? _wsIsolate;
  ReceivePort? _receivePort;

  Stream<dynamic> get messageStream => _messageController.stream;

  /// Устанавливает callback-функцию для обработки входящих сообщений
  /// 
  /// [callback] - функция, которая будет вызываться при получении новых данных
  void setOnDataReceived(Function(dynamic message) callback) {
    _messageController.stream.listen(callback);
  }

  /// Устанавливает WebSocket-соединение с сервером
  /// 
  /// [url] - URL WebSocket-сервера
  /// При обрыве соединения автоматически пытается переподключиться
  Future<void> connect(String url) async {
    _serverUrl = url;
    await _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    try {
      await _dispose();
      
      _receivePort = ReceivePort();
      _wsIsolate = await Isolate.spawn(
        _handleWebSocket,
        _WSIsolateParams(
          serverUrl: _serverUrl!,
          sendPort: _receivePort!.sendPort,
        ),
      );

      _receivePort!.listen((message) {
        if (message is Map && message['type'] == 'connection_status') {
          _isConnected = message['connected'];
        } else {
          _messageController.add(message);
        }
      });

      _startPingTimer();
    } catch (e) {
      print('Ошибка подключения WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isConnected) {
        sendMessage({'type': 'ping'});
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isConnected && _serverUrl != null) {
        _initializeWebSocket();
      }
    });
  }

  void sendMessage(dynamic message) {
    if (_receivePort != null) {
      _receivePort!.sendPort.send({
        'type': 'send_message',
        'message': message,
      });
    }
  }

  Future<void> _dispose() async {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _wsIsolate?.kill();
    _receivePort?.close();
    _isConnected = false;
  }

  Future<void> dispose() async {
    await _dispose();
    await _messageController.close();
  }

  // Обработка WebSocket в отдельном изоляте
  static void _handleWebSocket(_WSIsolateParams params) {
    WebSocketChannel? channel;
    Timer? pingTimer;

    try {
      channel = WebSocketChannel.connect(Uri.parse(params.serverUrl));
      params.sendPort.send({'type': 'connection_status', 'connected': true});

      channel.stream.listen(
        (message) {
          params.sendPort.send(message);
        },
        onError: (error) {
          params.sendPort.send({'type': 'connection_status', 'connected': false});
          channel?.sink.close();
        },
        onDone: () {
          params.sendPort.send({'type': 'connection_status', 'connected': false});
          channel?.sink.close();
        },
      );

      // Обработка сообщений от основного изолята
      final receivePort = ReceivePort();
      params.sendPort.send({'type': 'isolate_port', 'port': receivePort.sendPort});

      receivePort.listen((message) {
        if (message is Map && message['type'] == 'send_message') {
          channel?.sink.add(message['message']);
        }
      });

    } catch (e) {
      params.sendPort.send({'type': 'connection_status', 'connected': false});
    }
  }
}

class _WSIsolateParams {
  final String serverUrl;
  final SendPort sendPort;

  _WSIsolateParams({
    required this.serverUrl,
    required this.sendPort,
  });
}