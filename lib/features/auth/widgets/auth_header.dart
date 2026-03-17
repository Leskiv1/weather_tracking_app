import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}