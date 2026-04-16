import 'package:flutter/material.dart';
import '../../../core/services/mqtt_service.dart';
import '../../../core/services/api_service.dart'; // ПІДКЛЮЧАЄМО АПІ
import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class CurrentWeatherCard extends StatefulWidget {
  const CurrentWeatherCard({super.key});

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> {
  final MqttService _mqttService = MqttService();
  final ApiService _apiService = ApiService(); // Сервіс для погоди
  
  bool _isMqttConnected = false;
  bool _isConnecting = true;
  StreamSubscription? _internetSubscription;

  // Змінні для зберігання даних з АПІ
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _setupMqttAndInternet();
    _fetchCurrentWeather(); // Завантажуємо погоду при старті
  }

  // Виніс налаштування MQTT в окремий метод для чистоти коду
  void _setupMqttAndInternet() {
    _mqttService.onDisconnectedCallback = () {
      if (mounted) setState(() { _isMqttConnected = false; _isConnecting = false; });
    };

    _mqttService.onConnectedCallback = () {
      if (mounted) setState(() { _isMqttConnected = true; _isConnecting = false; });
    };

    _internetSubscription = InternetConnection().onStatusChange.listen((status) {
      if (mounted) {
        if (status == InternetStatus.disconnected) {
          setState(() { _isMqttConnected = false; _isConnecting = false; });
        } else if (status == InternetStatus.connected) {
          if (!_isMqttConnected) {
            setState(() => _isConnecting = true);
            _connectToBroker();
          }
          // Якщо інтернет з'явився, а погоди ще немає - пробуємо знову
          if (_weatherData == null) _fetchCurrentWeather(); 
        }
      }
    });

    _connectToBroker();
  }

  // Метод для походу на наш Python-сервер
  Future<void> _fetchCurrentWeather() async {
    setState(() => _isLoadingWeather = true);
    final data = await _apiService.getCurrentWeather();
    
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _connectToBroker() async {
    final connected = await _mqttService.connect();
    if (mounted) setState(() { _isMqttConnected = connected; _isConnecting = false; });
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    _mqttService.disconnect();
    super.dispose();
  }

  // Хелпер для перетворення weather_code в текст
  String _getWeatherDescription(int? code) {
    if (code == null) return 'Дані відсутні';
    if (code == 0) return 'Ясно';
    if (code >= 1 && code <= 3) return 'Хмарно';
    if (code >= 51 && code <= 67) return 'Дощ';
    if (code >= 71 && code <= 77) return 'Сніг';
    if (code >= 95 && code <= 99) return 'Гроза';
    return 'Переважно сонячно';
  }

  @override
  Widget build(BuildContext context) {
    // Дістаємо дані або ставимо заглушки, якщо АПІ ще вантажиться
    final temp = _weatherData?['temp']?.toString() ?? '--';
    final desc = _getWeatherDescription(_weatherData?['code']);
    final wind = _weatherData?['wind']?.toString() ?? '--';
    final humidity = _weatherData?['humidity']?.toString() ?? '--';
    final pressure = _weatherData?['pressure']?.toString() ?? '--';

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
                // --- ЛІВА ПОЛОВИНА (АПІ ПОГОДА) ---
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
                                Icon(Icons.location_on, color: Colors.white, size: 20),
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
                            // Показуємо крутилку або текст опису
                            _isLoadingWeather 
                              ? const SizedBox(
                                  height: 16, width: 16, 
                                  child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2)
                                )
                              : Text(
                                  desc,
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '$temp°C', // РЕАЛЬНА ТЕМПЕРАТУРА
                          style: const TextStyle(
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
                                Icon(Icons.sensors, color: Colors.white, size: 20),
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
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isConnecting ? Colors.orange : (_isMqttConnected ? Colors.greenAccent : Colors.redAccent),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isConnecting ? 'Підключення...' : (_isMqttConnected ? 'Підключено' : 'Немає з\'єднання'),
                                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_isMqttConnected)
                          StreamBuilder<String>(
                            stream: _mqttService.dataStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text('--°C', style: TextStyle(color: Colors.white54, fontSize: 56, fontWeight: FontWeight.bold, height: 1));
                              }
                              return Text(snapshot.data!, style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold, height: 1));
                            },
                          )
                        else
                          const Text('--°C', style: TextStyle(color: Colors.white38, fontSize: 56, fontWeight: FontWeight.bold, height: 1)),
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

          // НИЖНЯ ЧАСТИНА (Деталі з АПІ)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail(Icons.air, 'ВІТЕР', '$wind м/с'),
              _buildWeatherDetail(Icons.water_drop_outlined, 'ВОЛОГІСТЬ', '$humidity%'),
              _buildWeatherDetail(Icons.compress, 'ТИСК', '$pressure гПа'),
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
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
            ),
            // Показуємо крутилку або текст
            _isLoadingWeather 
              ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5))
              : Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
          ],
        ),
      ],
    );
  }
}