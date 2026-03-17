import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B7AFA), Color(0xFF6B45FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainInfo(),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: _buildDetailsBox()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 3, child: _buildMainInfo()),
        const SizedBox(width: 32),
        Expanded(flex: 2, child: _buildDetailsBox()),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('Львів', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8),
        Text('Переважно сонячно', style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('24°', style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold, height: 1)),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('C', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: _WeatherDetail(icon: Icons.air, label: 'ВІТЕР', value: '4.2 м/с')),
              Expanded(child: _WeatherDetail(icon: Icons.water_drop_outlined, label: 'ВОЛОГІСТЬ', value: '58%')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: _WeatherDetail(icon: Icons.compress, label: 'ТИСК', value: '1012 гПа')),
              Expanded(child: _WeatherDetail(icon: Icons.wb_sunny_outlined, label: 'УФ ІНДЕКС', value: '4 (Сер)')),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetail({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}