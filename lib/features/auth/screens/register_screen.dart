import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/top_navigation.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/data/auth_repository.dart';
import '../../../core/models/user_model.dart';
import '../widgets/auth_header.dart';
import 'login_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/services/network_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Ключ для управления формой
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authRepo = AuthRepositoryImpl(); // Экземпляр нашего репозитория
  bool _isLoading = false;

  @override
  void dispose() {
    // Обязательно очищаем контроллеры из памяти при закрытии экрана
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final hasInternet = await NetworkService.isConnected;
      if (!hasInternet) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Відсутнє з\'єднання з Інтернетом!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Зупиняємо виконання, далі не йдемо
      }

      final newUser = UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Спроба зберегти користувача (тепер повертає true або false)
      final success = await _authRepo.registerUser(newUser);

      if (!success) {
        // Якщо повернулося false — пошта вже зайнята
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Акаунт з такою поштою вже існує!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Зупиняємо виконання методу, далі не йдемо
      }

      // Якщо success == true, йдемо далі: автоматичний логін
      await _authRepo.loginUser(newUser.email, newUser.password);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Реєстрація успішна!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
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
                      // Обернули поля в Form
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AuthHeader(
                            title: 'Створити акаунт',
                            subtitle:
                                'Приєднуйтесь до WeatherTracker сьогодні.',
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            controller: _nameController,
                            label: 'Ім\'я',
                            hint: 'Ваше ім\'я',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введіть ім\'я';
                              }
                              if (value.trim().length < 2) {
                                return 'Ім\'я має містити мінімум 2 літери';
                              }
                              // Перевірка на велику літеру на початку
                              if (!RegExp(r'^[A-ZА-ЯІЇЄҐ]').hasMatch(value)) {
                                return 'Ім\'я має починатися з великої літери';
                              }
                              // Перевірка на відсутність цифр та спецсимволів (дозволяємо літери, пробіл, дефіс)
                              if (!RegExp(
                                r'^[A-ZА-ЯІЇЄҐa-zа-яіїєґ\s\-]+$',
                              ).hasMatch(value)) {
                                return 'Ім\'я може містити лише літери';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Електронна пошта',
                            hint: 'name@example.com',
                            icon: Icons.mail_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Введіть пошту';
                              }
                              // Надійний регулярний вираз для валідації пошти
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
                            hint: 'Мінімум 8 символів',
                            icon: Icons.lock_outline,
                            isPassword:
                                true, // Це тепер автоматично включить іконку "ока"
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введіть пароль';
                              }
                              if (value.length < 8) return 'Мінімум 8 символів';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
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
                                          'Зареєструватися',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'Вже маєте акаунт? ',
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                ),
                                child: const Text(
                                  'Увійти',
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
