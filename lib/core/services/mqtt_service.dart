// lib/core/services/mqtt_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String _server = 'broker.emqx.io';
  final String topic = 'weathertracker/nazar/sensor1';

  MqttServerClient? _client; // Зробили nullable
  bool _isConnecting = false;

  // --- ДОДАЛИ ПАМ'ЯТЬ ДЛЯ UI ---
  String? lastReceivedTemperature;
  bool get isConnected =>
      _client != null &&
      _client!.connectionStatus!.state == MqttConnectionState.connected;

  final StreamController<String> _dataController =
      StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataController.stream;

  VoidCallback? onDisconnectedCallback;
  VoidCallback? onConnectedCallback;

  Future<bool> connect() async {
    // ЗАХИСТ ВІД ДУБЛЮВАННЯ: Якщо вже підключені - просто повертаємо true
    if (isConnected) return true;
    if (_isConnecting) return false;
    _isConnecting = true;

    final String clientIdentifier =
        'naz_app_${DateTime.now().millisecondsSinceEpoch % 100000}';

    _client = MqttServerClient(_server, clientIdentifier);
    _client!.logging(on: false); // Вимкнув логи, щоб не спамило в термінал

    _client!.port = 1883;
    _client!.secure = false;
    _client!.useWebSocket = false;

    _client!.keepAlivePeriod = 10;
    _client!.disconnectOnNoResponsePeriod = 5;
    _client!.autoReconnect = true;
    _client!.onAutoReconnected = _onAutoReconnected;
    _client!.onDisconnected = _onDisconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean();

    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      _client!.disconnect();
      _isConnecting = false;
      return false;
    }

    _isConnecting = false;

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('==== ✅ MQTT: ПІДКЛЮЧЕНО ДО БРОКЕРА! ====');

      _client!.subscribe(topic, MqttQos.atLeastOnce);

      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        debugPrint('==== 🔥 MQTT: ОТРИМАНО ДАНІ: $payload ====');

        // ЗБЕРІГАЄМО ОСТАННЄ ЗНАЧЕННЯ В ПАМ'ЯТЬ
        lastReceivedTemperature = payload;
        _dataController.add(payload);
      });
      return true;
    } else {
      _client!.disconnect();
      return false;
    }
  }

  void _onAutoReconnected() {
    _client?.subscribe(topic, MqttQos.atLeastOnce);
    Future.microtask(() => onConnectedCallback?.call());
  }

  void _onDisconnected() {
    Future.microtask(() => onDisconnectedCallback?.call());
  }

  void disconnect() {
    _client?.disconnect();
  }
}
