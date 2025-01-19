import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:tito_app/src/data/models/types.dart' as types;

final liveWebSocketProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});

class WebSocketService {
  late WebSocketChannel channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;
  Timer? _reconnectTimer;

  WebSocketService() {
    connect();
  }

  void connect() {
    if (_isConnected) return; // 중복 연결 방지
    try {
      channel = WebSocketChannel.connect(
          Uri.parse('wss://dev.tito.lat/ws/debate/realtime'));
      _isConnected = true;
      print('WebSocket connection established');

      channel.stream.listen((message) {
        try {
          print('Raw message received: $message');
          final decodedMessage = json.decode(message) as Map<String, dynamic>;
          _controller.sink.add(decodedMessage);
        } catch (e) {
          print('Error decoding message: $e');
          _controller.addError('Error decoding message: $e');
        }
      }, onError: (error) {
        print('Error in websocket connection: $error');
        _controller.addError('WebSocket error: $error');
        _reconnect(); // 재연결 시도
      }, onDone: () {
        print('WebSocket connection closed');

        _reconnect(); // 재연결 시도
      });
    } catch (e) {
      print('Error establishing WebSocket connection: $e');
      _controller.addError('Error establishing WebSocket connection: $e');
      _reconnect(); // 재연결 시도
    }
  }

  void _reconnect() {
    if (_isConnected) {
      _isConnected = false;
      channel.sink.close();
      print('Attempting to reconnect in 5 seconds...');
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(seconds: 5), () {
        connect();
      });
    }
  }

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  // messageStream 게터 추가
  Stream<List<types.Message>> get messageStream =>
      _controller.stream.map((data) {
        // 데이터를 Message 객체로 변환하는 로직 추가
        return (data['messages'] as List)
            .map((json) => types.Message.fromJson(json))
            .toList();
      });

  void sendMessage(String message) {
    if (_isConnected) {
      print('Sending message: $message');
      channel.sink.add(message);
    } else {
      print('WebSocket not connected. Cannot send message.');
    }
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _isConnected = false;

    channel.sink.close(status.goingAway);

    _controller.close();
  }
}
