import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsCard extends StatefulWidget {
  const SettingsCard({super.key});

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  bool isCelsius = true;
  bool stormWarnings = true;
  bool dailyForecast = false;

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
              Icon(Icons.settings_outlined, color: AppColors.primaryBlue),
              SizedBox(width: 12),
              Expanded(
                child: Text('Налаштування додатку', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 24),
          const Text('Одиниці вимірювання', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildRadio(isCelsius, 'Градуси Цельсія (°C)', () => setState(() => isCelsius = true)),
              _buildRadio(!isCelsius, 'Фаренгейти (°F)', () => setState(() => isCelsius = false)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: const [
              Icon(Icons.notifications_none, color: AppColors.textGrey, size: 20),
              SizedBox(width: 8),
              Text('Сповіщення', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSwitchRow('Штормові попередження', stormWarnings, () => setState(() => stormWarnings = !stormWarnings)),
          const SizedBox(height: 16),
          _buildSwitchRow('Щоденний прогноз зранку', dailyForecast, () => setState(() => dailyForecast = !dailyForecast)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Зберегти зміни'),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Скасувати'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadio(bool selected, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.primaryBlue : AppColors.textGrey,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.textDark))),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 24,
            decoration: BoxDecoration(
              color: value ? AppColors.primaryBlue : AppColors.borderLight,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            padding: const EdgeInsets.all(2),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ],
    );
  }
}