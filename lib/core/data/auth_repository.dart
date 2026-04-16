import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart'; // Підключаємо наш новий сервіс!

// 1. Наша абстракція (Інтерфейс) залишається БЕЗ ЗМІН
abstract class IAuthRepository {
  Future<bool> registerUser(UserModel user);
  Future<bool> loginUser(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

// 2. РЕАЛЬНА реалізація через API + SharedPreferences
class AuthRepositoryImpl implements IAuthRepository {
  static const String _keyCurrentUserEmail = 'current_user_email';
  
  // Створюємо екземпляр нашого сервісу
  final ApiService _apiService = ApiService(); 

  @override
  Future<bool> registerUser(UserModel user) async {
    // Тепер ми не зберігаємо пароль локально!
    // Ми стукаємо на реальний Python-сервер
    final result = await _apiService.register(user.email, user.password);
    
    // Якщо сервер повернув success: true, значить все ок
    return result['success'] == true;
  }

  @override
  Future<bool> loginUser(String email, String password) async {
    // Стукаємо на сервер. Якщо логін успішний, ApiService сам збереже JWT-токен
    final result = await _apiService.login(email, password);

    if (result['success'] == true) {
      // Для того, щоб твій LocationsRepository знав, хто залогований,
      // ми залишаємо збереження email'а локально!
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentUserEmail, email);
      
      // Більше ніяких паролів у SharedPreferences! Тільки email і токен.
      return true;
    }
    return false;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final currentEmail = prefs.getString(_keyCurrentUserEmail);
    final token = prefs.getString('jwt_token'); // Перевіряємо, чи є токен від сервера

    // Автологін спрацює ТІЛЬКИ якщо є і email, і токен
    if (currentEmail != null && token != null) {
      // Повертаємо юзера. Пароль тепер неважливий, тому передаємо пустий рядок.
      // (На сервері пароль зашифрований, ми його не знаємо і нам він не потрібен)
      return UserModel(name: "User", email: currentEmail, password: "");
    }
    return null; // Якщо токена немає - викидаємо на екран логіну
  }

  @override
  Future<void> logout() async {
    // 1. Видаляємо токен (через ApiService)
    await _apiService.logout(); 
    
    // 2. Видаляємо прив'язку до локацій
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserEmail);
  }
}