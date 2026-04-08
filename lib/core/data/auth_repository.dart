import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// 1. Наша абстракція (Інтерфейс)
abstract class IAuthRepository {
  Future<bool> registerUser(UserModel user); // Змінили void на bool
  Future<bool> loginUser(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

// 2. Реалізація за допомогою SharedPreferences
class AuthRepositoryImpl implements IAuthRepository {
  // Ключ для збереження email поточного залогованого користувача
  static const String _keyCurrentUserEmail = 'current_user_email';

  @override
  Future<bool> registerUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    // ПЕРЕВІРКА: чи існує вже пароль для цієї пошти?
    final existingPassword = prefs.getString('password_${user.email}');
    if (existingPassword != null) {
      // Якщо так, значить користувач з таким email вже є
      return false;
    }

    // Якщо ні — спокійно зберігаємо нові дані
    await prefs.setString('name_${user.email}', user.name);
    await prefs.setString('password_${user.email}', user.password);
    return true; // Реєстрація успішна
  }

  @override
  Future<bool> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Шукаємо пароль збережений саме для цього email
    final savedPassword = prefs.getString('password_$email');

    // Якщо пароль існує і співпадає з введеним
    if (savedPassword != null && savedPassword == password) {
      // Запам'ятовуємо, що цей користувач тепер залогований
      await prefs.setString(_keyCurrentUserEmail, email);
      return true;
    }
    return false;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    // Дізнаємося, хто зараз залогований
    final currentEmail = prefs.getString(_keyCurrentUserEmail);

    if (currentEmail == null) return null; // Ніхто не залогований

    // Дістаємо дані саме для цього email
    final name = prefs.getString('name_$currentEmail');
    final password = prefs.getString('password_$currentEmail');

    if (name != null && password != null) {
      return UserModel(name: name, email: currentEmail, password: password);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Видаляємо запис про те, що хтось залогований (але самі акаунти залишаються в пам'яті!)
    await prefs.remove(_keyCurrentUserEmail);
  }
}
