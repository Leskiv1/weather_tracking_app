import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/location_model.dart';
import '../../../core/data/locations_repository.dart';

class SavedLocationsSidebar extends StatefulWidget {
  const SavedLocationsSidebar({super.key});

  @override
  State<SavedLocationsSidebar> createState() => _SavedLocationsSidebarState();
}

class _SavedLocationsSidebarState extends State<SavedLocationsSidebar> {
  final _locationsRepo = LocationsRepositoryImpl();
  List<LocationModel> _locations = [];
  bool _isLoading = true;
  bool _isAdding = false; // Чи показувати зараз поле вводу
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  // Завантаження локацій
  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    final locations = await _locationsRepo.getLocations();
    setState(() {
      _locations = locations;
      _isLoading = false;
    });
  }

  // Додавання нової локації (з генерацією рандомних даних)
  Future<void> _addNewLocation(String cityName) async {
    if (cityName.trim().isEmpty) {
      setState(() => _isAdding = false);
      return;
    }

    final random = Random();
    final conditions = ['Сонячно', 'Хмарно', 'Легкий дощ'];

    // Тут легко можна буде вставити реальний запит до API замість рандому!
    final newLoc = LocationModel(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Генеруємо унікальний ID
      cityName: cityName.trim(),
      temperature: 15 + random.nextInt(16), // Рандомна температура від 15 до 30
      condition:
          conditions[random.nextInt(conditions.length)], // Рандомна погода
    );

    await _locationsRepo.addLocation(newLoc);
    _cityController.clear();
    setState(() => _isAdding = false);
    _loadLocations(); // Оновлюємо список
  }

  // Видалення локації
  Future<void> _deleteLocation(String id) async {
    await _locationsRepo.removeLocation(id);
    _loadLocations();
  }

  // Допоміжний метод для іконок
  IconData _getIconForCondition(String condition) {
    switch (condition) {
      case 'Сонячно':
        return Icons.wb_sunny_outlined;
      case 'Хмарно':
        return Icons.cloud_outlined;
      case 'Легкий дощ':
        return Icons.water_drop_outlined;
      default:
        return Icons.wb_cloudy_outlined;
    }
  }

  // Поп-ап (Dialog) для перегляду та видалення ВСІХ локацій
  void _showAllLocationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder потрібен, щоб оновлювати поп-ап при видаленні
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text(
                'Всі збережені локації',
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
                          'Немає збережених локацій',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _locations.length,
                        itemBuilder: (context, index) {
                          final loc = _locations[index];
                          return Card(
                            color: AppColors.cardWhite,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                _getIconForCondition(loc.condition),
                                color: AppColors.primaryBlue,
                              ),
                              title: Text(
                                loc.cityName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(loc.condition),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${loc.temperature}°',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await _deleteLocation(loc.id);
                                      // Оновлюємо і сам поп-ап
                                      setStateDialog(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
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
    // Беремо лише перші 3 локації для відображення на головному екрані
    final displayLocations = _locations.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Збережені локації',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _showAllLocationsDialog,
              child: const Text(
                'Переглянути всі',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          // Відображаємо Топ-3 локації
          ...displayLocations.map(
            (loc) => Container(
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
                      Icon(
                        _getIconForCondition(loc.condition),
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.cityName,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            loc.condition,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${loc.temperature}°',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textGrey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Кнопка додавання АБО поле вводу
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight,
                style: BorderStyle.solid,
              ),
            ),
            child: _isAdding
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _cityController,
                      autofocus: true, // Клавіатура з'явиться автоматично
                      decoration: InputDecoration(
                        hintText: 'Введіть назву міста...',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: AppColors.primaryBlue,
                          ),
                          onPressed: () =>
                              _addNewLocation(_cityController.text),
                        ),
                      ),
                      onSubmitted:
                          _addNewLocation, // Спрацьовує при натисканні Enter на клавіатурі
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
                          Text(
                            'Додати локацію',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}
