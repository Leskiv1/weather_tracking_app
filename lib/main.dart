import 'package:flutter/material.dart';
import 'core/data/auth_repository.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  // Обов'язково додаємо цей рядок для роботи з SharedPreferences до запуску додатку
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherTrackerApp());
}

class WeatherTrackerApp extends StatelessWidget {
  const WeatherTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', // Або будь-який інший стандартний шрифт
        useMaterial3: true,
      ),
      // Замість жорстко заданого HomeScreen викликаємо нашу розумну обгортку
      home: const AuthWrapper(),
    );
  }
}

// "Розумна" обгортка, яка перевіряє статус логіну
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authRepo = AuthRepositoryImpl();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await _authRepo.getCurrentUser();
    setState(() {
      // Якщо юзер є в базі, значить він залогований
      _isLoggedIn = user != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Поки перевіряємо сховище — показуємо екран завантаження
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    // Якщо залогований — пускаємо на головну, якщо ні — на екран логіну
    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
