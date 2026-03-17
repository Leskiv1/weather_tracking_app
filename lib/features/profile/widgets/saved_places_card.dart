import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SavedPlacesCard extends StatelessWidget {
  const SavedPlacesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.textGrey,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Збережені місця',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight, height: 1),
          _buildPlaceRow('Київ, Україна'),
          const Divider(color: AppColors.borderLight, height: 1),
          _buildPlaceRow('Львів, Україна'),
          const Divider(color: AppColors.borderLight, height: 1),
          _buildPlaceRow('Одеса, Україна'),
        ],
      ),
    );
  }

  Widget _buildPlaceRow(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Видалити',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
