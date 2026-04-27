import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // <--- ДОДАЛИ ДЛЯ kIsWeb
import 'package:flashlight_plugin/flashlight_plugin.dart';

class FlashlightHelper {
  static Future<void> toggleFlashlight(BuildContext context) async {
    // 1. Спочатку безпечно перевіряємо, чи це бразуер (Web) АБО не Android
    if (kIsWeb || !Platform.isAndroid) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Упс! 😅'),
            content: const Text(
              'Цей секретний функціонал (ліхтарик) підтримується лише на Android-пристроях.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Зрозуміло'),
              ),
            ],
          ),
        );
      }
      return;
    }

    try {
      await FlashlightPlugin.onLight();
    } catch (e) {
      debugPrint('Помилка ліхтарика: $e');
    }
  }
}
