import 'package:flutter/material.dart';
import '../../../core/data/auth_repository.dart';
import '../../auth/screens/login_screen.dart';

class SecurityCard extends StatelessWidget {
  const SecurityCard({super.key});

  // Метод, який показує діалог
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вихід з акаунта', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Ви впевнені, що хочете вийти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Просто закриваємо діалог
            child: const Text('Ні', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Закриваємо діалог
              
              // Робимо реальний вихід
              final authRepo = AuthRepositoryImpl();
              await authRepo.logout();
              
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Так, вийти', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFFDC2626), size: 20),
                    SizedBox(width: 8),
                    Text('Безпека', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 4),
                Text('Вийти з акаунта на цьому пристрої', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(context), // Викликаємо наш діалог
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Вийти'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFFECACA)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}