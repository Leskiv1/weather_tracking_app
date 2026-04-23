// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ДОДАНО BLOC
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/top_navigation.dart';
import '../../../core/widgets/search_bar_widget.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/saved_locations_sidebar.dart';

// ПІДКЛЮЧАЄМО НАШ НОВИЙ CUBIT
import '../../../core/cubit/network_cubit.dart'; 

// ТЕПЕР ЦЕ STATELESS WIDGET!
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Огортаємо екран у BlocProvider, щоб він жив поки відкритий екран
    return BlocProvider(
      create: (context) => NetworkCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const TopNavigation(),

            // --- ПЛАШКА ВІДСУТНОСТІ ІНТЕРНЕТУ (СЛУХАЄ BLOC) ---
            BlocBuilder<NetworkCubit, bool>(
              builder: (context, hasInternet) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: hasInternet ? 0 : 40,
                  width: double.infinity,
                  color: Colors.red.shade600,
                  child: const Center(
                    child: Text(
                      'Немає з\'єднання з Інтернетом. Дані можуть бути неактуальними.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),

            // ------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      children: [
                        const SearchBarWidget(),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 800) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: const [
                                        CurrentWeatherCard(),
                                        SizedBox(height: 24),
                                        ForecastCard(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  const Expanded(
                                    flex: 1,
                                    child: SavedLocationsSidebar(),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: const [
                                CurrentWeatherCard(),
                                SizedBox(height: 24),
                                ForecastCard(),
                                SizedBox(height: 24),
                                SavedLocationsSidebar(),
                              ],
                            );
                          },
                        ),
                      ],
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
