import 'package:flutter/material.dart';

void main() {
  runApp(const WeatherStationApp());
}

class WeatherStationApp extends StatelessWidget {
  const WeatherStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const WeatherControlPanel(),
    );
  }
}

class WeatherControlPanel extends StatefulWidget {
  const WeatherControlPanel({super.key});

  @override
  State<WeatherControlPanel> createState() => _WeatherControlPanelState();
}

class _WeatherControlPanelState extends State<WeatherControlPanel> {
  // Базова температура "датчика"
  double _baseTemperature = 22.0;
  // Стан системи
  String _systemStatus = "Чілим на вулиці";
  // Текст помилки для поля вводу
  String? _errorMessage;

  final TextEditingController _controller = TextEditingController();

  void _processInput(String value) {
    setState(() {
      // Скидаємо помилку при новій спробі
      _errorMessage = null;

      if (value.trim() == "Avada Kedavra") {
        _baseTemperature = 0.0;
        _systemStatus = "СИСТЕМУ СКИНУТО (Emergency)";
        _controller.clear();
      } else {
        // Намагаємося конвертувати текст у число
        final double? inputNumber = double.tryParse(value);

        if (inputNumber != null) {
          // Додаємо введене число до поточної температури
          _baseTemperature += inputNumber;

          // Обмежуємо температуру в межах від -50 до 50
          _baseTemperature = _baseTemperature.clamp(-50.0, 50.0);

          // Оновлюємо статус
          if (_baseTemperature == 50) {
            _systemStatus =
                "Більше не може бути! Якщо більше, то ядерна війна і нам всім капут!!!";
          } else if (_baseTemperature == -50) {
            _systemStatus =
                "Менше нема куда! Якщо менше, то передай привіт Сіду з Льoдовикового періоду!!!";
          } else if (_baseTemperature >= 30) {
            // Від 30 до 49.9
            _systemStatus = "Потрібно холодного пивка";
          } else if (_baseTemperature >= 10) {
            // Від 10 до 29.9
            _systemStatus = "Чілим на вулиці";
          } else if (_baseTemperature > -10) {
            // Від -14.9 до 9.9
            _systemStatus = "Чілим вдома";
          } else if (_baseTemperature > -50) {
            // Від -49.9 до -15
            _systemStatus = "Потрібно гарячого глінтвейну!";
          }

          _controller.clear(); // Очищаємо поле після успішного вводу
        } else if (value.trim().isNotEmpty) {
          // Якщо це не число і не порожній рядок (і не Avada Kedavra)
          _errorMessage = "Будь ласка, введіть цифри";
        }
      }
    });
  }

  Color _getWeatherColor() {
    if (_baseTemperature > 30) return Colors.orangeAccent;
    if (_baseTemperature < 0) return Colors.blue; // Додав синій для мінуса
    if (_baseTemperature < 10) return Colors.lightBlueAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Type your weather'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Віджет датчика"
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: _getWeatherColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getWeatherColor(), width: 3),
              ),
              child: Column(
                children: [
                  Icon(
                    _baseTemperature > 25 ? Icons.wb_sunny : Icons.ac_unit,
                    size: 80,
                    color: _getWeatherColor(),
                  ),
                  Text(
                    '${_baseTemperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Статус: $_systemStatus'),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Поле вводу
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                // Прибрали const, бо errorText змінюється
                border: const OutlineInputBorder(),
                labelText: 'Введіть температуру',
                hintText: 'Наприклад: 10 або Avada Kedavra',
                errorText: _errorMessage, // Відображення помилки
              ),
              onSubmitted:
                  _processInput, // Спрацьовує при натисканні Enter на клавіатурі
            ),
          ],
        ),
      ),
    );
  }
}
