// lib/core/cubit/network_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../services/network_service.dart';

// Наш стан - це звичайний bool (true - є інтернет, false - немає)
class NetworkCubit extends Cubit<bool> {
  late StreamSubscription<InternetStatus> _subscription;

  // При створенні Cubit ми одразу підписуємося на інтернет
  NetworkCubit() : super(true) {
    _subscription = NetworkService.onStatusChange.listen((status) {
      // emit безпечно оновлює UI, не ламаючи рендеринг Flutter!
      emit(status == InternetStatus.connected);
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel(); // Очищаємо пам'ять
    return super.close();
  }
}
