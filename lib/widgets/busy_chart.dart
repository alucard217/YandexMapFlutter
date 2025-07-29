import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BusyChart extends StatelessWidget {
  final List<int> hourlyData; // Массив из 24 чисел — от 0 до 23

  const BusyChart({required this.hourlyData, super.key});

  @override
  Widget build(BuildContext context) {
    // Гарантируем, что массив из 24 значений
    final safeData = hourlyData.length == 24 ? hourlyData : List.filled(24, 0);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipMargin: 12,
              tooltipHorizontalAlignment: FLHorizontalAlignment.center,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final hour = group.x;
                final count = rod.toY.toInt();
                return BarTooltipItem(
                  '$count брони\n${hour.toString().padLeft(2, '0')}:00',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center, // ✅ центрируем текст
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4,
                getTitlesWidget: (value, _) {
                  final hour = value.toInt();
                  return Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(24, (i) {
            final value = safeData[i].toDouble();
            final validY = value.isFinite ? value : 0.0;

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: validY,
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.blue.withOpacity(0.7),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
