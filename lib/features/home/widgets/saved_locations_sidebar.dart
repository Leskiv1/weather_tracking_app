import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'location_list_item.dart';

class SavedLocationsSidebar extends StatelessWidget {
  const SavedLocationsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Збережені локації',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Переглянути всі',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const LocationListItem(
          city: 'Київ',
          condition: 'Хмарно',
          temp: '21°',
          icon: Icons.cloud_outlined,
        ),
        const LocationListItem(
          city: 'Одеса',
          condition: 'Сонячно',
          temp: '26°',
          icon: Icons.wb_sunny_outlined,
        ),
        const LocationListItem(
          city: 'Харків',
          condition: 'Легкий дощ',
          temp: '23°',
          icon: Icons.water_drop_outlined,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: const [
              Icon(Icons.add, color: AppColors.textGrey),
              SizedBox(height: 8),
              Text(
                'Додати локацію',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
