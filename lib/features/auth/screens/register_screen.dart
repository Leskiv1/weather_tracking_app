import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/top_navigation.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../widgets/auth_header.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AuthHeader(
                          title: 'Створити акаунт',
                          subtitle: 'Приєднуйтесь до WeatherTracker сьогодні.',
                        ),
                        const SizedBox(height: 32),
                        const CustomTextField(
                          label: 'Ім\'я',
                          hint: 'Ваше ім\'я',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 24),
                        const CustomTextField(
                          label: 'Електронна пошта',
                          hint: 'name@example.com',
                          icon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 24),
                        const CustomTextField(
                          label: 'Пароль',
                          hint: 'Мінімум 8 символів',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Зареєструватися', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.check_circle_outline, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text('Вже маєте акаунт? ', style: TextStyle(color: AppColors.textGrey)),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                              child: const Text('Увійти', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('© 2026 WeatherTracker. Всі права захищені.', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}