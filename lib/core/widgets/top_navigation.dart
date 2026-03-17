import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/auth/screens/login_screen.dart';

class TopNavigation extends StatelessWidget {
  final String activeTab;

  const TopNavigation({super.key, this.activeTab = 'Головна'});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.cloud_outlined,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                    if (!isMobile) const SizedBox(width: 8),
                    if (!isMobile)
                      const Text(
                        'WeatherTracker',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    _NavButton(
                      icon: Icons.home_outlined,
                      text: 'Головна',
                      isActive: activeTab == 'Головна',
                      isMobile: isMobile,
                      onTap: () {
                        if (activeTab != 'Головна') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: Icons.person_outline,
                      text: 'Профіль',
                      isActive: activeTab == 'Профіль',
                      isMobile: isMobile,
                      onTap: () {
                        if (activeTab != 'Профіль') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _NavButton(
                      icon: Icons.login_outlined,
                      text: 'Увійти',
                      isActive: activeTab == 'Увійти',
                      isMobile: isMobile,
                      onTap: () {
                        if (activeTab != 'Увійти') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final bool isMobile;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.text,
    this.isActive = false,
    this.isMobile = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryBlue : AppColors.textDark,
              size: 20,
            ),
            if (!isMobile) const SizedBox(width: 8),
            if (!isMobile)
              Text(
                text,
                style: TextStyle(
                  color: isActive ? AppColors.primaryBlue : AppColors.textDark,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
