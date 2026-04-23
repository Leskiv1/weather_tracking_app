// lib/features/home/cubit/location_cubit.dart
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/location_model.dart';
import '../../../core/data/locations_repository.dart';

// 1. СТАН
class LocationState {
  final bool isLoading;
  final List<LocationModel> locations;

  LocationState({this.isLoading = true, this.locations = const []});
}

// 2. ЛОГІКА (Cubit)
class LocationCubit extends Cubit<LocationState> {
  final LocationsRepositoryImpl repository;

  // Одразу при створенні вантажимо список міст
  LocationCubit({required this.repository}) : super(LocationState()) {
    loadLocations();
  }

  // Завантаження локацій
  Future<void> loadLocations() async {
    emit(LocationState(isLoading: true, locations: state.locations));
    final locs = await repository.getLocations();
    emit(LocationState(isLoading: false, locations: locs));
  }

  // Додавання нової локації
  Future<void> addLocation(String cityName) async {
    if (cityName.trim().isEmpty) return;

    final random = Random();
    final conditions = ['Сонячно', 'Хмарно', 'Легкий дощ'];

    final newLoc = LocationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cityName: cityName.trim(),
      temperature: 15 + random.nextInt(16),
      condition: conditions[random.nextInt(conditions.length)],
    );

    await repository.addLocation(newLoc);
    await loadLocations(); // Оновлюємо список після додавання
  }

  // Видалення локації
  Future<void> deleteLocation(String id) async {
    await repository.removeLocation(id);
    await loadLocations(); // Оновлюємо список після видалення
  }
}