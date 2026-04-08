import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import 'auth_repository.dart'; // Нам потрібен AuthRepo, щоб дізнатися, хто зараз залогований

// 1. Наша абстракція (Інтерфейс) - якщо потім підключиш API, просто створиш ApiLocationsRepositoryImpl
abstract class ILocationsRepository {
  Future<List<LocationModel>> getLocations();
  Future<void> addLocation(LocationModel location);
  Future<void> removeLocation(String id);
}

// 2. Реалізація через SharedPreferences
class LocationsRepositoryImpl implements ILocationsRepository {
  final _authRepo = AuthRepositoryImpl();

  // Допоміжний метод: генерує унікальний ключ для кожного користувача
  Future<String?> _getUserKey() async {
    final user = await _authRepo.getCurrentUser();
    if (user == null) return null;
    return 'locations_${user.email}'; // Наприклад: locations_test@gmail.com
  }

  @override
  Future<List<LocationModel>> getLocations() async {
    final key = await _getUserKey();
    if (key == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final locationsJson = prefs.getStringList(key) ?? [];

    // Перетворюємо список рядків JSON назад у список об'єктів LocationModel
    return locationsJson
        .map((jsonStr) => LocationModel.fromJson(jsonStr))
        .toList();
  }

  @override
  Future<void> addLocation(LocationModel location) async {
    final key = await _getUserKey();
    if (key == null) return;

    final prefs = await SharedPreferences.getInstance();
    final locations = await getLocations();

    // Додаємо нову локацію НА ПОЧАТОК списку
    locations.insert(0, location);

    // Зберігаємо оновлений список
    final locationsJson = locations.map((loc) => loc.toJson()).toList();
    await prefs.setStringList(key, locationsJson);
  }

  @override
  Future<void> removeLocation(String id) async {
    final key = await _getUserKey();
    if (key == null) return;

    final prefs = await SharedPreferences.getInstance();
    final locations = await getLocations();

    // Видаляємо локацію за її ID
    locations.removeWhere((loc) => loc.id == id);

    final locationsJson = locations.map((loc) => loc.toJson()).toList();
    await prefs.setStringList(key, locationsJson);
  }
}
