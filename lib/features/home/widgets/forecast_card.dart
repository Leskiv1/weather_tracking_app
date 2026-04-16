import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
// ПІДКЛЮЧАЄМО НАШ СЕРВІС
import '../../../core/services/api_service.dart'; 

class ForecastCard extends StatefulWidget {
  const ForecastCard({super.key});

  @override
  State<ForecastCard> createState() => _ForecastCardState();
}

class _ForecastCardState extends State<ForecastCard> {
  // Змінна, яка триматиме наш "потік" з майбутніми даними
  late Future<Map<String, dynamic>> _forecastFuture;

  @override
  void initState() {
    super.initState();
    // При запуску віджета ОДИН РАЗ викликаємо метод сервера
    _forecastFuture = ApiService().getForecast();
  }

  // --- ХЕЛПЕР 1: Перетворює дату з АПІ у гарний текст ---
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

  // --- ХЕЛПЕР 2: Перетворює weather_code з АПІ на іконку ---
  IconData _getWeatherIcon(int code) {
    // Коди за стандартом WMO (World Meteorological Organization)
    if (code == 0) return Icons.wb_sunny_outlined; // Ясно
    if (code >= 1 && code <= 3) return Icons.cloud_outlined; // Хмарно
    if (code >= 51 && code <= 67) return Icons.water_drop_outlined; // Дощ
    if (code >= 71 && code <= 77) return Icons.ac_unit; // Сніг
    if (code >= 95 && code <= 99) return Icons.flash_on; // Гроза
    return Icons.cloud_queue; // За замовчуванням
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
          
          // ВПРОВАДЖУЄМО FUTURE BUILDER
          FutureBuilder<Map<String, dynamic>>(
            future: _forecastFuture,
            builder: (context, snapshot) {
              // Стан 1: Дані ще вантажаться (показуємо крутилку)
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.textDark),
                );
              }

              // Стан 2: Сталася помилка мережі (сервер впав тощо)
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Помилка завантаження даних', style: TextStyle(color: Colors.red)),
                );
              }

              // Стан 3: Сервер відповів, перевіряємо чи успішно
              final result = snapshot.data!;
              if (result['success'] == false) {
                // Найімовірніше, юзер не залогінений (немає токена)
                return Center(
                  child: Text(
                    result['error'] ?? 'Увійдіть, щоб побачити прогноз',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              // Стан 4: ВСЕ УСПІШНО! Малюємо прогноз
              final List forecastList = result['data']['forecast'];

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // Генеруємо віджети динамічно з масиву АПІ
                        children: List.generate(forecastList.length, (index) {
                          final dayData = forecastList[index];
                          
                          // Парсимо дані
                          final String dayName = _formatDayName(dayData['date']);
                          final IconData dayIcon = _getWeatherIcon(dayData['weather_code']);
                          final String maxTemp = '${dayData['max_temp']}°'; // Беремо макс. температуру
                          
                          // Віджет дня
                          Widget item = _ForecastItem(
                            day: dayName,
                            icon: dayIcon,
                            temp: maxTemp,
                          );

                          // Додаємо відступи між елементами, крім останнього
                          if (index < forecastList.length - 1) {
                            return Row(
                              children: [item, const SizedBox(width: 16)],
                            );
                          }
                          return item;
                        }),
                      ),
                    ),
                  );
                },
              );
            },
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

  const _ForecastItem({
    required this.day,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Icon(icon, color: AppColors.textDark, size: 32),
        const SizedBox(height: 12),
        Text(
          temp,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
