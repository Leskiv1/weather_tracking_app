import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState {
  final bool isCelsius;
  final bool stormWarnings;
  final bool dailyForecast;

  SettingsState({
    this.isCelsius = true,
    this.stormWarnings = true,
    this.dailyForecast = false,
  });

  SettingsState copyWith({
    bool? isCelsius,
    bool? stormWarnings,
    bool? dailyForecast,
  }) {
    return SettingsState(
      isCelsius: isCelsius ?? this.isCelsius,
      stormWarnings: stormWarnings ?? this.stormWarnings,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState());

  void setUnit(bool isCelsius) => emit(state.copyWith(isCelsius: isCelsius));
  void toggleStormWarnings() =>
      emit(state.copyWith(stormWarnings: !state.stormWarnings));
  void toggleDailyForecast() =>
      emit(state.copyWith(dailyForecast: !state.dailyForecast));
}
