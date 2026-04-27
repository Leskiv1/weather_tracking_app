// lib/features/home/cubit/forecast_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_service.dart';
import 'forecast_state.dart';

class ForecastCubit extends Cubit<ForecastState> {
  final ApiService apiService;

  ForecastCubit({required this.apiService}) : super(ForecastInitial());

  Future<void> loadForecast() async {
    // 1. Кажемо UI крутити лоадер
    emit(ForecastLoading());

    try {
      // 2. Робимо запит (ніяких викликів АПІ у віджетах!)
      final result = await apiService.getForecast();

      // 3. Аналізуємо відповідь
      if (result['success'] == true) {
        emit(ForecastLoaded(result['data']['forecast']));
      } else {
        emit(
          ForecastAuthError(
            result['error'] ?? 'Увійдіть, щоб побачити прогноз',
          ),
        );
      }
    } catch (e) {
      // Якщо сервер впав або немає інтернету
      emit(ForecastError('Помилка завантаження даних'));
    }
  }
}
