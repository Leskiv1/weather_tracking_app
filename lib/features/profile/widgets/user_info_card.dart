// lib/features/profile/widgets/user_info_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ПІДКЛЮЧАЄМО BLOC
import '../../../core/theme/app_colors.dart';

// ПІДКЛЮЧАЄМО CUBIT
import '../cubit/profile_cubit.dart';

// ТЕПЕР ЦЕ STATELESS WIDGET!
class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      // 1. ВИКОРИСТОВУЄМО BLOC BUILDER
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Якщо дані завантажились, показуємо їх
          return Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_outline,
                  size: 48,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.user?.name ?? 'Гість', // Беремо з Cubit-а
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.user?.email ?? 'Немає пошти', // Беремо з Cubit-а
                style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'PRO Акаунт',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
