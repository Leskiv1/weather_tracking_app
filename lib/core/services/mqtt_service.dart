import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String _server = 'test.mosquitto.org';
  final String _clientIdentifier =
      'nazar_iot_flutter_${DateTime.now().millisecondsSinceEpoch}';
  final String topic = 'weathertracker/nazar/sensor1';

  late MqttServerClient _client;

  final StreamController<String> _dataController =
      StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataController.stream;

  VoidCallback? onDisconnectedCallback;
  VoidCallback? onConnectedCallback; 
  
  Future<bool> connect() async {
    _client = MqttServerClient(_server, _clientIdentifier);
    _client.logging(on: false);
    _client.port = 1883;
    _client.keepAlivePeriod = 10;
    _client.disconnectOnNoResponsePeriod = 5;

    // --- МАГІЯ АВТОВІДНОВЛЕННЯ ---
    _client.autoReconnect = true; // Дозволяємо клієнту самому шукати інтернет
    _client.onAutoReconnected = _onAutoReconnected; // Що робити, коли знайшов

    _client.onDisconnected = _onDisconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client.connectionMessage = connMess;

    try {
      await _client.connect();
    } catch (e) {
      _client.disconnect();
      return false;
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT: Підключено успішно!');

      // Перша підписка при першому запуску
      _client.subscribe(topic, MqttQos.atMostOnce);

      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        _dataController.add(payload);
      });
      return true;
    } else {
      _client.disconnect();
      return false;
    }
  }

  // --- МЕТОД, ЯКИЙ РЯТУЄ СИТУАЦІЮ ПІСЛЯ ОБРИВУ ---
  void _onAutoReconnected() {
    debugPrint('MQTT: Автоматично перепідключено після обриву!');

    // НАЙГОЛОВНІШЕ: Підписуємось на топік заново!
    _client.subscribe(topic, MqttQos.atMostOnce);

    // Кажемо UI, щоб зробив крапочку знову зеленою
    Future.microtask(() {
      if (onConnectedCallback != null) {
        onConnectedCallback!();
      }
    });
  }

  void _onDisconnected() {
    debugPrint('MQTT: Відключено від брокера');
    Future.microtask(() {
      if (onDisconnectedCallback != null) {
        onDisconnectedCallback!();
      }
    });
  }

  void disconnect() {
    _client.disconnect();
  }
}
