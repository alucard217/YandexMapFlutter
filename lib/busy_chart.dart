import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BusyChart extends StatelessWidget {
  final List<int> hourlyData;

  const BusyChart({required this.hourlyData, super.key});

  @override
  Widget build(BuildContext context) {
    final safeData = hourlyData.length == 24 ? hourlyData : List.filled(24, 0);

    return SizedBox(
      height: 220,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 700,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (safeData.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
              gridData: FlGridData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipMargin: 12,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final hour = group.x;
                    final count = rod.toY.toInt();
                    return BarTooltipItem(
                      '$count bookings\n${hour.toString().padLeft(2, '0')}:00',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),

              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    getTitlesWidget: (value, _) {
                      final hour = value.toInt();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(24, (i) {
                final y = safeData[i].toDouble();
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: y,
                      width: 12,
                      color: y > 0 ? Colors.blueAccent : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
