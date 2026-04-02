import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/location_model.dart';
import '../../../core/data/locations_repository.dart';

class ProfileSavedLocationsCard extends StatefulWidget {
  const ProfileSavedLocationsCard({super.key});

  @override
  State<ProfileSavedLocationsCard> createState() =>
      _ProfileSavedLocationsCardState();
}

class _ProfileSavedLocationsCardState extends State<ProfileSavedLocationsCard> {
  final _locationsRepo = LocationsRepositoryImpl();
  List<LocationModel> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  // Завантаження локацій зі сховища
  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    final locations = await _locationsRepo.getLocations();
    setState(() {
      _locations = locations;
      _isLoading = false;
    });
  }

  // Видалення локації
  Future<void> _deleteLocation(String id) async {
    await _locationsRepo.removeLocation(id);
    _loadLocations(); // Оновлюємо список після видалення
  }

  // Поп-ап (Dialog) для перегляду та видалення ВСІХ локацій
  void _showAllLocationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text(
                'Усі збережені місця',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              content: SizedBox(
                width: 400,
                height: 400,
                child: _locations.isEmpty
                    ? const Center(
                        child: Text(
                          'Список порожній',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _locations.length,
                        itemBuilder: (context, index) {
                          final loc = _locations[index];
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${loc.cityName}, Україна',
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: TextButton(
                                  onPressed: () async {
                                    await _deleteLocation(loc.id);
                                    setStateDialog(() {}); // Оновлюємо поп-ап
                                  },
                                  child: const Text(
                                    'Видалити',
                                    style: TextStyle(color: AppColors.textGrey),
                                  ),
                                ),
                              ),
                              if (index < _locations.length - 1)
                                const Divider(
                                  color: AppColors.borderLight,
                                  height: 1,
                                ),
                            ],
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Закрити',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Беремо лише перші 3 локації для відображення
    final displayLocations = _locations.take(3).toList();

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
              Icon(
                Icons.location_on_outlined,
                color: AppColors.textGrey,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Збережені місця',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_locations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'У вас ще немає збережених локацій.',
                style: TextStyle(color: AppColors.textGrey),
              ),
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
                        Text(
                          '${loc.cityName}, Україна',
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _deleteLocation(loc.id),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            'Видалити',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Додаємо лінію-розділювач, якщо це не останній елемент у списку з 3-х
                  if (index < displayLocations.length - 1)
                    const Divider(color: AppColors.borderLight, height: 1),
                ],
              );
            }),

          const SizedBox(height: 16),
          // Кнопка "Усі місця" показується тільки якщо локацій більше ніж 0
          if (_locations.isNotEmpty)
            Center(
              child: TextButton(
                onPressed: _showAllLocationsDialog,
                child: const Text(
                  'Усі місця',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
