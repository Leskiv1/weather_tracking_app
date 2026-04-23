import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ПІДКЛЮЧАЄМО BLOC

// Імпортуємо всі наші сервіси та репозиторії
import 'core/services/api_service.dart';
import 'core/services/mqtt_service.dart';
import 'core/data/auth_repository.dart';
import 'core/data/locations_repository.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherTrackerApp());
}

class WeatherTrackerApp extends StatelessWidget {
  const WeatherTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. СТВОРЮЄМО MULTI REPOSITORY PROVIDER
    // Це наш "кошик" з Одинаками (Singletons)
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => ApiService()),
        RepositoryProvider(create: (context) => MqttService()),
        // AuthRepositoryImpl всередині себе використовує ApiService, тому це ОК
        RepositoryProvider(create: (context) => AuthRepositoryImpl()),
        RepositoryProvider(create: (context) => LocationsRepositoryImpl()), 
      ],
      child: MaterialApp(
        title: 'WeatherTracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
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
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 2. БЕРЕМО РЕПОЗИТОРІЙ З "КОШИКА" замість створення нового!
    // context.read - це магія flutter_bloc, яка знаходить потрібний клас у дереві
    final authRepo = context.read<AuthRepositoryImpl>();
    
    final user = await authRepo.getCurrentUser();
    
    // Перевіряємо чи віджет ще існує перед викликом setState
    if (mounted) {
      setState(() {
        _isLoggedIn = user != null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}