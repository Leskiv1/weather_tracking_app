import 'dart:convert';

class LocationModel {
  final String id;
  final String cityName;
  final int temperature;
  final String condition; // 'Сонячно', 'Хмарно', 'Легкий дощ'

  LocationModel({
    required this.id,
    required this.cityName,
    required this.temperature,
    required this.condition,
  });

  // Перетворення об'єкта в Map (словник)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityName': cityName,
      'temperature': temperature,
      'condition': condition,
    };
  }

  // Створення об'єкта зі словника
  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'],
      cityName: map['cityName'],
      temperature: map['temperature'],
      condition: map['condition'],
    );
  }

  // Конвертація в JSON рядок для збереження в SharedPreferences
  String toJson() => json.encode(toMap());

  // Відновлення з JSON рядка
  factory LocationModel.fromJson(String source) =>
      LocationModel.fromMap(json.decode(source));
}
