import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceChart extends StatelessWidget {
  final String fieldId;

  AttendanceChart({required this.fieldId});

  final Map<String, List<double>> fieldAttendanceData = {
    'Баскетбольное поле в Ботаническом саду по улице Бухар Жырау': [0.2, 0.3, 0.25, 0.35, 0.5, 0.8, 0.75],
    'Баскетбольная площадка в Ботаническом саду по улице Орынбор №1': [0.15, 0.25, 0.2, 0.3, 0.45, 0.7, 0.65],
    'Баскетбольная площадка в Ботаническом саду по улице Орынбор №2': [0.1, 0.2, 0.15, 0.25, 0.4, 0.6, 0.55],
    'Теннисный корт в Ботаническом саду по улице Бухар Жырау': [0.25, 0.35, 0.3, 0.4, 0.55, 0.85, 0.8],
    'Тенисный корт в Ботаническом саду по улице Орынбор №2': [0.12, 0.22, 0.18, 0.28, 0.42, 0.65, 0.6],
    'Тенисный корт в Ботаническом саду по улице Орынбор №1': [0.3, 0.4, 0.35, 0.45, 0.6, 0.9, 0.85],
    'Футбольное поле в Ботаническом саду по улице Орынбор': [0.2, 0.25, 0.2, 0.3, 0.5, 0.75, 0.7],
    'Футбольное поле в Ботаническом саду по улице Бухар Жырау №1': [0.1, 0.15, 0.15, 0.2, 0.3, 0.55, 0.5],
    'Футбольное поле в Ботаническом саду по улице Бухар Жырау №2': [0.28, 0.32, 0.3, 0.38, 0.55, 0.82, 0.78],
    'Волейбольное поле в Ботаническом саду по улице Орынбор': [0.12, 0.18, 0.15, 0.22, 0.35, 0.6, 0.55],
    'Волейбольное поле в Ботаническом саду по улице Бухар Жырау №1': [0.2, 0.3, 0.25, 0.35, 0.5, 0.8, 0.75],
    'Волейбольное поле в Ботаническом саду по улице Бухар Жырау №2': [0.14, 0.22, 0.2, 0.26, 0.38, 0.65, 0.6],
  };



  @override
  Widget build(BuildContext context) {
    final data = fieldAttendanceData[fieldId] ?? List.filled(7, 0);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 1,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(
                  days[value.toInt() % 7],
                  style: TextStyle(fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                return Text('${(value * 100).round()}%', style: TextStyle(fontSize: 10));
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true),
          ),
        ],
      ),
    );

  }
}
