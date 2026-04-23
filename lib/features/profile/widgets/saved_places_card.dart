// lib/features/profile/widgets/saved_places_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import '../../../core/theme/app_colors.dart';
import '../../../core/data/locations_repository.dart';

// Підключаємо наш вже існуючий Cubit!
import '../../home/cubit/location_cubit.dart'; 

// STATELESS WIDGET!
class ProfileSavedLocationsCard extends StatelessWidget {
  const ProfileSavedLocationsCard({super.key});

  // Поп-ап (Dialog) для перегляду та видалення ВСІХ локацій
  void _showAllLocationsDialog(BuildContext parentContext) {
    final locationCubit = parentContext.read<LocationCubit>();

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            'Усі збережені місця',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          content: SizedBox(
            width: 400,
            height: 400,
            // ВИКОРИСТОВУЄМО BLOC BUILDER замість StatefulBuilder
            child: BlocBuilder<LocationCubit, LocationState>(
              bloc: locationCubit, 
              builder: (context, state) {
                if (state.locations.isEmpty) {
                  return const Center(
                    child: Text('Список порожній', style: TextStyle(color: AppColors.textGrey)),
                  );
                }
                return ListView.builder(
                  itemCount: state.locations.length,
                  itemBuilder: (context, index) {
                    final loc = state.locations[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${loc.cityName}, Україна',
                            style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500),
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              // Викликаємо видалення через Cubit
                              locationCubit.deleteLocation(loc.id);
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text('Видалити', style: TextStyle(color: AppColors.textGrey)),
                          ),
                        ),
                        if (index < state.locations.length - 1)
                          const Divider(color: AppColors.borderLight, height: 1),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрити', style: TextStyle(color: AppColors.primaryBlue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Огортаємо картку в BlocProvider і створюємо екземпляр Cubit
    return BlocProvider(
      create: (context) => LocationCubit(
        repository: context.read<LocationsRepositoryImpl>(),
      ),
      child: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          final displayLocations = state.locations.take(3).toList();

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
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppColors.textGrey, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Збережені місця',
                      style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state.locations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('У вас ще немає збережених локацій.', style: TextStyle(color: AppColors.textGrey)),
                  )
                else
                  ...displayLocations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final loc = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${loc.cityName}, Україна', style: const TextStyle(color: AppColors.textDark, fontSize: 14)),
                              TextButton(
                                onPressed: () => context.read<LocationCubit>().deleteLocation(loc.id),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                child: const Text('Видалити', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                        if (index < displayLocations.length - 1)
                          const Divider(color: AppColors.borderLight, height: 1),
                      ],
                    );
                  }),

                const SizedBox(height: 16),
                if (state.locations.isNotEmpty)
                  Center(
                    child: TextButton(
                      // Передаємо context, щоб дістати Cubit всередині діалогу
                      onPressed: () => _showAllLocationsDialog(context),
                      child: const Text('Усі місця', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
