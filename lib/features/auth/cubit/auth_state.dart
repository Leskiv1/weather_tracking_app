// lib/features/auth/cubit/auth_state.dart
abstract class AuthState {}

class AuthInitial extends AuthState {} // Початковий стан (нічого не відбувається)

class AuthLoading extends AuthState {} // Крутиться крутилка

class AuthSuccess extends AuthState {} // Успішний вхід!

class AuthError extends AuthState { // Помилка (немає інтернету або невірний пароль)
  final String message;
  AuthError(this.message);
}