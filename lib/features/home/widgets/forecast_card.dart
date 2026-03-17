import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key});

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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _ForecastItem(
                        day: 'Сьогодні',
                        icon: Icons.wb_sunny_outlined,
                        temp: '24°',
                      ),
                      SizedBox(width: 16),
                      _ForecastItem(
                        day: 'Завтра',
                        icon: Icons.cloud_outlined,
                        temp: '22°',
                      ),
                      SizedBox(width: 16),
                      _ForecastItem(
                        day: 'Середа',
                        icon: Icons.cloudy_snowing,
                        temp: '19°',
                      ),
                      SizedBox(width: 16),
                      _ForecastItem(
                        day: 'Четвер',
                        icon: Icons.cloud_queue,
                        temp: '21°',
                      ),
                      SizedBox(width: 16),
                      _ForecastItem(
                        day: 'П\'ятниця',
                        icon: Icons.wb_sunny_outlined,
                        temp: '25°',
                      ),
                    ],
                  ),
                ),
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
