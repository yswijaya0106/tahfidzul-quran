import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../application/assessment_providers.dart';
import '../domain/assessment.dart';

/// Line chart of a student's new-memorization achievement over time (linear
/// verse count reached, per assessment) against their daily target for the
/// same day, so progress relative to the 300-day schedule is visible at a
/// glance rather than only reached/not-reached per row.
class AchievementChart extends ConsumerWidget {
  final String studentId;

  const AchievementChart({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(assessmentChartHistoryProvider(studentId));

    return AsyncValueView(
      value: history,
      onRetry: () => ref.invalidate(assessmentChartHistoryProvider(studentId)),
      isEmpty: (data) => data.length < 2,
      empty: (_) => const AppCard(
        padding: EdgeInsets.all(16),
        child: Text('Belum cukup data setoran hafalan baru untuk menampilkan grafik.'),
      ),
      data: (context, data) => AppCard(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
        child: SizedBox(height: 220, child: _Chart(history: data)),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final List<MemorizationAssessment> history;

  const _Chart({required this.history});

  @override
  Widget build(BuildContext context) {
    final achievedSpots = <FlSpot>[];
    final targetSpots = <FlSpot>[];
    var maxY = 0.0;

    for (var i = 0; i < history.length; i++) {
      final entry = history[i];
      final x = (entry.dayNumber ?? i + 1).toDouble();
      final y = entry.achievedCumulativeVerses.toDouble();
      achievedSpots.add(FlSpot(x, y));
      if (y > maxY) maxY = y;

      final targetY = entry.targetCumulativeVerses?.toDouble();
      if (targetY != null) {
        targetSpots.add(FlSpot(x, targetY));
        if (targetY > maxY) maxY = targetY;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendDot(color: AppColors.deepGreen, label: 'Pencapaian'),
            const SizedBox(width: 16),
            if (targetSpots.isNotEmpty) _LegendDot(color: AppColors.gold, label: 'Target harian'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY <= 0 ? 10 : maxY * 1.15,
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'H${value.toInt()}',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map(
                        (spot) => LineTooltipItem(
                          '${spot.y.toInt()} ayat',
                          const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      )
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: achievedSpots,
                  isCurved: true,
                  color: AppColors.deepGreen,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.deepGreen.withValues(alpha: 0.08),
                  ),
                ),
                if (targetSpots.isNotEmpty)
                  LineChartBarData(
                    spots: targetSpots,
                    isCurved: true,
                    color: AppColors.gold,
                    barWidth: 2,
                    dashArray: [6, 4],
                    dotData: const FlDotData(show: false),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
