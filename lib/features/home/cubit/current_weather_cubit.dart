// lib/features/home/cubit/current_weather_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/mqtt_service.dart';

class CurrentWeatherState {
  final bool isLoadingWeather;
  final Map<String, dynamic>? weatherData;
  final bool isMqttConnected;
  final bool isConnecting;
  final String? mqttTemperature;

  CurrentWeatherState({
    this.isLoadingWeather = true,
    this.weatherData,
    this.isMqttConnected = false,
    this.isConnecting = true,
    this.mqttTemperature,
  });

  CurrentWeatherState copyWith({
    bool? isLoadingWeather,
    Map<String, dynamic>? weatherData,
    bool? isMqttConnected,
    bool? isConnecting,
    String? mqttTemperature,
  }) {
    return CurrentWeatherState(
      isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
      weatherData: weatherData ?? this.weatherData,
      isMqttConnected: isMqttConnected ?? this.isMqttConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      mqttTemperature: mqttTemperature ?? this.mqttTemperature,
    );
  }
}

class CurrentWeatherCubit extends Cubit<CurrentWeatherState> {
  final ApiService apiService;
  final MqttService mqttService;

  StreamSubscription? _internetSub;
  StreamSubscription? _mqttDataSub;

  CurrentWeatherCubit({required this.apiService, required this.mqttService})
    : super(
        CurrentWeatherState(
          // МИТТЄВО БЕРЕМО СТАН З ПАМ'ЯТІ СЕРВІСУ!
          isMqttConnected: mqttService.isConnected,
          mqttTemperature: mqttService.lastReceivedTemperature,
          isConnecting: !mqttService.isConnected,
        ),
      ) {
    _setupMqttAndInternet();
    fetchCurrentWeather();
  }

  void _setupMqttAndInternet() {
    mqttService.onDisconnectedCallback = () {
      if (!isClosed)
        emit(state.copyWith(isMqttConnected: false, isConnecting: false));
    };

    mqttService.onConnectedCallback = () {
      if (!isClosed)
        emit(state.copyWith(isMqttConnected: true, isConnecting: false));
    };

    _mqttDataSub = mqttService.dataStream.listen((temp) {
      if (!isClosed) emit(state.copyWith(mqttTemperature: temp));
    });

    _internetSub = InternetConnection().onStatusChange.listen((status) {
      if (isClosed) return;

      if (status == InternetStatus.disconnected) {
        emit(state.copyWith(isMqttConnected: false, isConnecting: false));
      } else if (status == InternetStatus.connected) {
        // Якщо інтернет є, а MQTT ще не підключений - стартуємо!
        if (!mqttService.isConnected) {
          emit(state.copyWith(isConnecting: true));
          _connectToBroker();
        }
        if (state.weatherData == null) fetchCurrentWeather();
      }
    });

    // Підключаємось одразу, якщо ще не підключені
    if (!mqttService.isConnected) {
      _connectToBroker();
    }
  }

  Future<void> fetchCurrentWeather() async {
    if (!isClosed) emit(state.copyWith(isLoadingWeather: true));
    final data = await apiService.getCurrentWeather();
    if (!isClosed)
      emit(state.copyWith(weatherData: data, isLoadingWeather: false));
  }

  Future<void> _connectToBroker() async {
    final connected = await mqttService.connect();
    if (!isClosed)
      emit(state.copyWith(isMqttConnected: connected, isConnecting: false));
  }

  @override
  Future<void> close() {
    _internetSub?.cancel();
    _mqttDataSub?.cancel();

    mqttService.onDisconnectedCallback = null;
    mqttService.onConnectedCallback = null;
    // БІЛЬШЕ НІКОЛИ НЕ ВБИВАЄМО MQTT ПРИ ЗМІНІ ВКЛАДОК!
    // mqttService.disconnect();

    return super.close();
  }
}
