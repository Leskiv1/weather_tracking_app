import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/top_navigation.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/data/auth_repository.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/auth_header.dart';
import 'register_screen.dart';
import '../../../core/services/network_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authRepo = AuthRepositoryImpl();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final hasInternet = await NetworkService.isConnected;
      if (!hasInternet) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Відсутнє з\'єднання з Інтернетом!', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Зупиняємо виконання, далі не йдемо
      }

      // Спроба логіну через репозиторій
      final success = await _authRepo.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          // Успіх: перекидаємо в профіль
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Успішний вхід!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else {
          // Провал: показуємо помилку
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Невірна пошта або пароль!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const TopNavigation(activeTab: 'Увійти'),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      // Додали Form для валідації
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AuthHeader(
                            title: 'З поверненням!',
                            subtitle:
                                'Увійдіть, щоб переглянути свої збережені локації.',
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Електронна пошта',
                            hint: 'name@example.com',
                            icon: Icons.mail_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введіть пошту';
                              }
                              // Та сама перевірка, що і при реєстрації
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return 'Введіть коректну електронну пошту';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Пароль',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введіть пароль';
                              }
                              return null;
                            },
                            trailing: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Забули пароль?',
                                style: TextStyle(color: AppColors.primaryBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Увійти',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'Немає акаунту? ',
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Зареєструватися',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '© 2026 WeatherTracker. Всі права захищені.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
