// lib/features/home/cubit/forecast_state.dart
abstract class ForecastState {}

class ForecastInitial extends ForecastState {}

class ForecastLoading extends ForecastState {}

class ForecastLoaded extends ForecastState {
  final List forecastList;
  ForecastLoaded(this.forecastList);
}

class ForecastError extends ForecastState {
  final String message;
  ForecastError(this.message);
}

// Окремий стан, якщо юзер не залогінений (щоб красиво показати текст)
class ForecastAuthError extends ForecastState {
  final String message;
  ForecastAuthError(this.message);
}
