import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // МАГІЧНА АДРЕСА: 10.0.2.2 для Android-емулятора (для iOS симулятора - 127.0.0.1, для реального телефону - IP комп'ютера в Wi-Fi мережі)
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  // Ключ для збереження токена
  static const String _tokenKey = 'jwt_token';

  // --- 1. АВТОРИЗАЦІЯ ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    // OAuth2 вимагає формат x-www-form-urlencoded (а не звичайний JSON)
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      // Зберігаємо токен у пам'ять телефону
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      return {'success': true};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['detail']};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['detail']};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey); // Просто видаляємо токен
  }

  // --- 2. РОБОТА З ДАНИМИ (ЗАХИЩЕНІ ЕНДПОІНТИ) ---

  Future<Map<String, dynamic>> getForecast() async {
    final url = Uri.parse('$_baseUrl/forecast');

    // Дістаємо токен із сейфа
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null) {
      return {
        'success': false,
        'error': 'Не авторизовано. Увійдіть в систему.',
      };
    }

    // Робимо запит і ПРИКРІПЛЯЄМО ТОКЕН у заголовок Authorization
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Ось наш "ключик" до замка!
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      ); // utf8.decode щоб українська мова ("Львів") відображалась коректно
      return {'success': true, 'data': data};
    } else if (response.statusCode == 401) {
      // Якщо токен прострочився
      await logout();
      return {'success': false, 'error': 'Сесія закінчилась. Увійдіть знову.'};
    } else {
      return {'success': false, 'error': 'Помилка завантаження даних'};
    }
  }

  Future<Map<String, dynamic>?> getCurrentWeather() async {
    final url = Uri.parse('$_baseUrl/current'); // Звертаємось на відкритий роут
    try {
      final response = await http.get(
        url,
      ); // Тут немає заголовка Authorization!
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
