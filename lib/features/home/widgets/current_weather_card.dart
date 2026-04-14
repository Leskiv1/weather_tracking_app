import 'package:flutter/material.dart';
import '../../../core/services/mqtt_service.dart';
import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class CurrentWeatherCard extends StatefulWidget {
  const CurrentWeatherCard({super.key});

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> {
  final MqttService _mqttService = MqttService();
  bool _isMqttConnected = false;
  bool _isConnecting = true;

  // ДОДАЄМО: Змінна для зберігання підписки на інтернет
  StreamSubscription? _internetSubscription;

  @override
  void initState() {
    super.initState();

    // 1. Коли MQTT сам розуміє, що відключився
    _mqttService.onDisconnectedCallback = () {
      if (mounted) {
        setState(() {
          _isMqttConnected = false;
          _isConnecting = false;
        });
      }
    };

    // 2. Коли MQTT сам відновив зв'язок
    _mqttService.onConnectedCallback = () {
      if (mounted) {
        setState(() {
          _isMqttConnected = true;
          _isConnecting = false;
        });
      }
    };

    // 3. ДОДАЄМО: Миттєва реакція на вмикання/вимикання Wi-Fi на телефоні
    _internetSubscription = InternetConnection().onStatusChange.listen((
      status,
    ) {
      if (mounted) {
        if (status == InternetStatus.disconnected) {
          // Якщо Wi-Fi вимкнули - миттєво ставимо червону крапку
          setState(() {
            _isMqttConnected = false;
            _isConnecting = false;
          });
        } else if (status == InternetStatus.connected) {
          // Якщо Wi-Fi увімкнули, а ми ще не підключені - форсуємо підключення
          if (!_isMqttConnected) {
            setState(() => _isConnecting = true);
            _connectToBroker();
          }
        }
      }
    });

    // Перше підключення при запуску
    _connectToBroker();
  }

  Future<void> _connectToBroker() async {
    final connected = await _mqttService.connect();
    if (mounted) {
      setState(() {
        _isMqttConnected = connected;
        _isConnecting = false;
      });
    }
  }

  @override
  void dispose() {
    // Обов'язково скасовуємо підписку, коли картка зникає!
    _internetSubscription?.cancel();
    _mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ЛІВА ПОЛОВИНА ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Львів',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Переважно сонячно',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        // ДОДАНО ГАРАНТОВАНИЙ ПРОПУСК
                        const SizedBox(height: 24),

                        const Text(
                          '24°C',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- ВЕРТИКАЛЬНИЙ РОЗДІЛЮВАЧ ---
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),

                // --- ПРАВА ПОЛОВИНА (MQTT) ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.sensors,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Датчик',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isConnecting
                                        ? Colors.orange
                                        : (_isMqttConnected
                                              ? Colors.greenAccent
                                              : Colors.redAccent),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isConnecting
                                        ? 'Підключення...'
                                        : (_isMqttConnected
                                              ? 'Підключено'
                                              : 'Немає з\'єднання'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // ТАКИЙ ЖЕ ПРОПУСК ДЛЯ СИМЕТРІЇ
                        const SizedBox(height: 24),

                        if (_isMqttConnected)
                          StreamBuilder<String>(
                            stream: _mqttService.dataStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text(
                                  '--°C',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                );
                              }
                              return Text(
                                snapshot.data!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              );
                            },
                          )
                        else
                          const Text(
                            '--°C',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- НИЖНІЙ ГОРИЗОНТАЛЬНИЙ РОЗДІЛЮВАЧ ---
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 24),

          // НИЖНЯ ЧАСТИНА (Деталі)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail(Icons.air, 'ВІТЕР', '4.2 м/с'),
              _buildWeatherDetail(
                Icons.water_drop_outlined,
                'ВОЛОГІСТЬ',
                '58%',
              ),
              _buildWeatherDetail(Icons.compress, 'ТИСК', '1012 гПа'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
