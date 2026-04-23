// lib/features/home/widgets/forecast_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Додаємо BLoC
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

// Підключаємо наші нові файли
import '../cubit/forecast_cubit.dart';
import '../cubit/forecast_state.dart';

// ТЕПЕР ЦЕ STATELESS WIDGET!
class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key});

  // Хелпери залишаємо тут, бо це суто візуальна логіка перетворення тексту
  String _formatDayName(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final differenceInDays = targetDate.difference(today).inDays;

    if (differenceInDays == 0) return 'Сьогодні';
    if (differenceInDays == 1) return 'Завтра';

    switch (date.weekday) {
      case 1: return 'Пн';
      case 2: return 'Вт';
      case 3: return 'Ср';
      case 4: return 'Чт';
      case 5: return 'Пт';
      case 6: return 'Сб';
      case 7: return 'Нд';
      default: return '';
    }
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code >= 1 && code <= 3) return Icons.cloud_outlined;
    if (code >= 51 && code <= 67) return Icons.water_drop_outlined;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 95 && code <= 99) return Icons.flash_on;
    return Icons.cloud_queue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Прогноз на 5 днів',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // 1. ОГОРТАЄМО У BLOC PROVIDER
          // Конструкція "..loadForecast()" означає: створити Cubit і ОДРАЗУ викликати метод завантаження
          BlocProvider(
            create: (context) => ForecastCubit(
              apiService: context.read<ApiService>(), // Беремо АПІ з "кошика"
            )..loadForecast(), 
            
            // 2. ВИКОРИСТОВУЄМО BLOC BUILDER ЗАМІСТЬ FUTURE BUILDER
            child: BlocBuilder<ForecastCubit, ForecastState>(
              builder: (context, state) {
                
                // Стан 1: Вантажимось
                if (state is ForecastLoading || state is ForecastInitial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.textDark));
                }

                // Стан 2: Немає токена (не залогінений)
                if (state is ForecastAuthError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Стан 3: Помилка сервера
                if (state is ForecastError) {
                  return Center(
                    child: Text(state.message, style: const TextStyle(color: Colors.red)),
                  );
                }

                // Стан 4: Успіх! Отримали дані
                if (state is ForecastLoaded) {
                  final forecastList = state.forecastList;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(forecastList.length, (index) {
                              final dayData = forecastList[index];
                              
                              Widget item = _ForecastItem(
                                day: _formatDayName(dayData['date']),
                                icon: _getWeatherIcon(dayData['weather_code']),
                                temp: '${dayData['max_temp']}°',
                              );

                              if (index < forecastList.length - 1) {
                                return Row(children: [item, const SizedBox(width: 16)]);
                              }
                              return item;
                            }),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox(); // На випадок непередбачених станів
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastItem extends StatelessWidget {
  final String day;
  final IconData icon;
  final String temp;

  const _ForecastItem({required this.day, required this.icon, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
        const SizedBox(height: 12),
        Icon(icon, color: AppColors.textDark, size: 32),
        const SizedBox(height: 12),
        Text(
          temp,
          style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}