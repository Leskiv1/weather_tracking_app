// lib/features/home/widgets/current_weather_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ПІДКЛЮЧАЄМО BLOC
import '../../../core/services/api_service.dart';
import '../../../core/services/mqtt_service.dart';
import '../cubit/current_weather_cubit.dart'; // ПІДКЛЮЧАЄМО НАШ CUBIT

// ТЕПЕР ЦЕ STATELESS WIDGET!
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key});

  // Хелпер залишається тут, бо це лише візуальне форматування
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
    // 1. СТВОРЮЄМО CUBIT, ПЕРЕДАЮЧИ СЕРВІСИ З "КОШИКА" MAIN.DART
    return BlocProvider(
      create: (context) => CurrentWeatherCubit(
        apiService: context.read<ApiService>(),
        mqttService: context.read<MqttService>(),
      ),
      // 2. ПІДПИСУЄМОСЬ НА ЗМІНИ СТАНУ
      child: BlocBuilder<CurrentWeatherCubit, CurrentWeatherState>(
        builder: (context, state) {
          
          // Дістаємо дані зі стану (замість локальних змінних)
          final temp = state.weatherData?['temp']?.toString() ?? '--';
          final desc = _getWeatherDescription(state.weatherData?['code']);
          final wind = state.weatherData?['wind']?.toString() ?? '--';
          final humidity = state.weatherData?['humidity']?.toString() ?? '--';
          final pressure = state.weatherData?['pressure']?.toString() ?? '--';

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
                                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  state.isLoadingWeather
                                      ? const SizedBox(
                                          height: 16, width: 16,
                                          child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
                                        )
                                      : Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '$temp°C',
                                style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold, height: 1),
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
                                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                                          color: state.isConnecting ? Colors.orange : (state.isMqttConnected ? Colors.greenAccent : Colors.redAccent),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          state.isConnecting ? 'Підключення...' : (state.isMqttConnected ? 'Підключено' : 'Немає з\'єднання'),
                                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // МАГІЯ: БІЛЬШЕ НЕМАЄ STREAM BUILDER! Беремо температуру прямо зі state
                              if (state.isMqttConnected && state.mqttTemperature != null)
                                Text(
                                  state.mqttTemperature!,
                                  style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold, height: 1),
                                )
                              else
                                const Text(
                                  '--°C',
                                  style: TextStyle(color: Colors.white38, fontSize: 56, fontWeight: FontWeight.bold, height: 1),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- НИЖНІЙ РОЗДІЛЮВАЧ ---
                Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 24),

                // НИЖНЯ ЧАСТИНА (Деталі з АПІ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeatherDetail(Icons.air, 'ВІТЕР', '$wind м/с', state.isLoadingWeather),
                    _buildWeatherDetail(Icons.water_drop_outlined, 'ВОЛОГІСТЬ', '$humidity%', state.isLoadingWeather),
                    _buildWeatherDetail(Icons.compress, 'ТИСК', '$pressure гПа', state.isLoadingWeather),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value, bool isLoading) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
            isLoading
                ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5))
                : Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
