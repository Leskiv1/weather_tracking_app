// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ДОДАЛИ BLOC
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/top_navigation.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/data/auth_repository.dart';
import '../widgets/auth_header.dart';
import 'login_screen.dart';
import '../../profile/screens/profile_screen.dart';

// ПІДКЛЮЧИЛИ НАШ CUBIT
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Видалили _isLoading та _authRepo!

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. ОГОРТАЄМО ЕКРАН У BLOC PROVIDER
    return BlocProvider(
      create: (context) => AuthCubit(
        authRepository: context.read<AuthRepositoryImpl>(), // Беремо з кошика
      ),
      child: Scaffold(
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

                            // --- ПОЛЯ ВВОДУ (Валідатори без змін) ---
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
                                if (!RegExp(r'^[A-ZА-ЯІЇЄҐ]').hasMatch(value)) {
                                  return 'Ім\'я має починатися з великої літери';
                                }
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
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введіть пароль';
                                }
                                if (value.length < 8) {
                                  return 'Мінімум 8 символів';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // 2. BLOC CONSUMER ДЛЯ КНОПКИ
                            SizedBox(
                              width: double.infinity,
                              child: BlocConsumer<AuthCubit, AuthState>(
                                listener: (context, state) {
                                  // Обробка помилок та успіху
                                  if (state is AuthError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          state.message,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else if (state is AuthSuccess) {
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
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileScreen(),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;

                                  return ElevatedButton(
                                    // Відключаємо кнопку під час завантаження
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // ВИКЛИКАЄМО ЛОГІКУ З CUBIT!
                                              context
                                                  .read<AuthCubit>()
                                                  .register(
                                                    _nameController.text.trim(),
                                                    _emailController.text
                                                        .trim(),
                                                    _passwordController.text,
                                                  );
                                            }
                                          },
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
                                    child: isLoading
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
                                  );
                                },
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
      ),
    );
  }
}
