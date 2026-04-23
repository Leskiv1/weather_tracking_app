// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Додали BLoC
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/top_navigation.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/data/auth_repository.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/auth_header.dart';
import 'register_screen.dart';

// Підключаємо наш Cubit
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // МИ ВИДАЛИЛИ ЗВІДСИ _authRepo ТА _isLoading!

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Огортаємо екран у BlocProvider, щоб він створив AuthCubit
    // і дістав репозиторій з нашого глобального "кошика"
    return BlocProvider(
      create: (context) =>
          AuthCubit(authRepository: context.read<AuthRepositoryImpl>()),
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
                                if (value == null || value.trim().isEmpty)
                                  return 'Введіть пошту';
                                final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(value))
                                  return 'Введіть коректну електронну пошту';
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
                                if (value == null || value.isEmpty)
                                  return 'Введіть пароль';
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
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // 2. BLOC CONSUMER - Магія стейт менеджменту!
                            // Він слухає Cubit і реагує на зміни
                            SizedBox(
                              width: double.infinity,
                              child: BlocConsumer<AuthCubit, AuthState>(
                                // СЛУХАЧ (Listener) - для навігації та Снекбарів (спрацьовує 1 раз)
                                listener: (context, state) {
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
                                          'Успішний вхід!',
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
                                // БУДІВЕЛЬНИК (Builder) - перемальовує кнопку
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;

                                  return ElevatedButton(
                                    // Якщо вантажиться - відключаємо кнопку
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // ВИКЛИКАЄМО ЛОГІКУ З CUBIT
                                              context.read<AuthCubit>().login(
                                                _emailController.text.trim(),
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
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Увійти',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward,
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
      ),
    );
  }
}
