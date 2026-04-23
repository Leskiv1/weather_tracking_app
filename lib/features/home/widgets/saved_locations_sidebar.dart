// lib/features/home/widgets/saved_locations_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ПІДКЛЮЧАЄМО BLOC
import '../../../core/theme/app_colors.dart';
import '../../../core/data/locations_repository.dart';

// ПІДКЛЮЧАЄМО НАШІ НОВІ ФАЙЛИ
import '../cubit/location_cubit.dart'; 

class SavedLocationsSidebar extends StatefulWidget {
  const SavedLocationsSidebar({super.key});

  @override
  State<SavedLocationsSidebar> createState() => _SavedLocationsSidebarState();
}

class _SavedLocationsSidebarState extends State<SavedLocationsSidebar> {
  bool _isAdding = false; // Суто UI стан (показувати поле чи кнопку)
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  IconData _getIconForCondition(String condition) {
    switch (condition) {
      case 'Сонячно': return Icons.wb_sunny_outlined;
      case 'Хмарно': return Icons.cloud_outlined;
      case 'Легкий дощ': return Icons.water_drop_outlined;
      default: return Icons.wb_cloudy_outlined;
    }
  }

  // Поп-ап для перегляду та видалення локацій
  void _showAllLocationsDialog(BuildContext parentContext) {
    // Зберігаємо посилання на існуючий Cubit
    final locationCubit = parentContext.read<LocationCubit>();

    showDialog(
      context: parentContext,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            'Всі збережені локації',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          content: SizedBox(
            width: 400,
            height: 400,
            // МАГІЯ: Використовуємо BlocBuilder замість StatefulBuilder!
            child: BlocBuilder<LocationCubit, LocationState>(
              bloc: locationCubit, // Передаємо наш Cubit прямо в поп-ап
              builder: (context, state) {
                if (state.locations.isEmpty) {
                  return const Center(
                    child: Text('Немає збережених локацій', style: TextStyle(color: AppColors.textGrey)),
                  );
                }
                
                return ListView.builder(
                  itemCount: state.locations.length,
                  itemBuilder: (context, index) {
                    final loc = state.locations[index];
                    return Card(
                      color: AppColors.cardWhite,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(_getIconForCondition(loc.condition), color: AppColors.primaryBlue),
                        title: Text(loc.cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(loc.condition),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${loc.temperature}°',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                // Просто кажемо Cubit-у видалити, і екран сам оновиться!
                                locationCubit.deleteLocation(loc.id);
                              },
                            ),
                          ],
                        ),
                      ),
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
    // 1. Огортаємо сайдбар у BlocProvider
    return BlocProvider(
      create: (context) => LocationCubit(
        repository: context.read<LocationsRepositoryImpl>(),
      ),
      
      // 2. Слухаємо зміни стану
      child: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          final displayLocations = state.locations.take(3).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Збережені локації',
                    style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _showAllLocationsDialog(context),
                    child: const Text('Переглянути всі', style: TextStyle(color: AppColors.primaryBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                // Відображаємо Топ-3 локації
                ...displayLocations.map((loc) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(_getIconForCondition(loc.condition), color: AppColors.primaryBlue),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.cityName, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(loc.condition, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${loc.temperature}°', style: const TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
                              const Icon(Icons.chevron_right, color: AppColors.textGrey),
                            ],
                          ),
                        ],
                      ),
                    )),

                // Кнопка додавання АБО поле вводу
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                  ),
                  child: _isAdding
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _cityController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Введіть назву міста...',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.check, color: AppColors.primaryBlue),
                                onPressed: () {
                                  // Передаємо додавання у Cubit
                                  context.read<LocationCubit>().addLocation(_cityController.text);
                                  _cityController.clear();
                                  setState(() => _isAdding = false);
                                },
                              ),
                            ),
                            onSubmitted: (val) {
                              context.read<LocationCubit>().addLocation(val);
                              _cityController.clear();
                              setState(() => _isAdding = false);
                            },
                          ),
                        )
                      : InkWell(
                          onTap: () => setState(() => _isAdding = true),
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: AppColors.textGrey),
                                SizedBox(width: 8),
                                Text('Додати локацію', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}