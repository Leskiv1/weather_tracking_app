// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ПІДКЛЮЧАЄМО BLOC
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/top_navigation.dart';
import '../../../core/data/auth_repository.dart';

import '../widgets/user_info_card.dart';
import '../widgets/saved_places_card.dart';
import '../widgets/settings_card.dart';
import '../widgets/security_card.dart';

// ПІДКЛЮЧАЄМО CUBIT
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    // 1. ОГОРТАЄМО ЕКРАН У BLOC PROVIDER
    return BlocProvider(
      create: (context) =>
          ProfileCubit(authRepository: context.read<AuthRepositoryImpl>()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const TopNavigation(activeTab: 'Профіль'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 800) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: const [
                                    UserInfoCard(),
                                    SizedBox(height: 24),
                                    ProfileSavedLocationsCard(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: const [
                                    SettingsCard(),
                                    SizedBox(height: 24),
                                    SecurityCard(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: const [
                            UserInfoCard(),
                            SizedBox(height: 24),
                            ProfileSavedLocationsCard(),
                            SizedBox(height: 24),
                            SettingsCard(),
                            SizedBox(height: 24),
                            SecurityCard(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '© 2026 WeatherTracker. Всі права захищені.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
