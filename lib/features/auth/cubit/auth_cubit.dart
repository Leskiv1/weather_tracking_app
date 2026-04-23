// lib/features/auth/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/auth_repository.dart';
import '../../../core/services/network_service.dart';
import '../../../core/models/user_model.dart'; // Додали імпорт моделі
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepositoryImpl authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  // МЕТОД ДЛЯ ЛОГІНУ (Який ми вже писали)
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final hasInternet = await NetworkService.isConnected;
    if (!hasInternet) {
      emit(AuthError("Відсутнє з'єднання з Інтернетом!"));
      return;
    }

    final success = await authRepository.loginUser(email, password);
    if (success) {
      emit(AuthSuccess());
    } else {
      emit(AuthError("Невірна пошта або пароль!"));
    }
  }

  // НОВИЙ МЕТОД ДЛЯ РЕЄСТРАЦІЇ
  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading()); // Крутимо крутилку
    
    final hasInternet = await NetworkService.isConnected;
    if (!hasInternet) {
      emit(AuthError("Відсутнє з'єднання з Інтернетом!"));
      return;
    }

    final newUser = UserModel(
      name: name,
      email: email,
      password: password,
    );

    // Пробуємо зареєструвати
    final success = await authRepository.registerUser(newUser);

    if (!success) {
      emit(AuthError("Акаунт з такою поштою вже існує!"));
      return;
    }

    // Якщо реєстрація успішна - автоматично логінимо юзера!
    await authRepository.loginUser(email, password);
    emit(AuthSuccess()); // Кажемо UI, що все супер, можна переходити в профіль
  }
}