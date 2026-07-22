import 'package:falta_app/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact performance visuals for the exam result screen.
class ExamPerformanceCharts extends StatelessWidget {
  const ExamPerformanceCharts({
    required this.correct,
    required this.incorrect,
    required this.unanswered,
    required this.percent,
    this.trendPercents = const [],
    super.key,
  });

  final int correct;
  final int incorrect;
  final int unanswered;
  final double percent;
  final List<double> trendPercents;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الأداء',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.titleDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 2,
                          centerSpaceRadius: 38,
                          sections: _pieSections(),
                        ),
                      ),
                      Text(
                        '${percent.round()}%',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.titleDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _LegendRow(
                        color: AppColors.optionCorrect,
                        label: 'صحيح',
                        value: '$correct',
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: AppColors.optionWrong,
                        label: 'خطأ',
                        value: '$incorrect',
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: AppColors.gray,
                        label: 'بدون إجابة',
                        value: '$unanswered',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'توزيع الإجابات',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  maxY: _barMaxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final labels = ['صحيح', 'خطأ', 'فارغ'];
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[i],
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _bar(0, correct.toDouble(), AppColors.optionCorrect),
                    _bar(1, incorrect.toDouble(), AppColors.optionWrong),
                    _bar(2, unanswered.toDouble(), AppColors.gray),
                  ],
                ),
              ),
            ),
            if (trendPercents.length >= 2) ...[
              const SizedBox(height: 8),
              Text(
                'منحنى التحسّن (آخر المحاولات)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 25,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            final i = value.toInt();
                            if (i < 0 || i >= trendPercents.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '${i + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < trendPercents.length; i++)
                            FlSpot(i.toDouble(), trendPercents[i].clamp(0, 100)),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          getDotPainter: (spot, _, __, ___) =>
                              FlDotCirclePainter(
                            radius: 3.5,
                            color: AppColors.primaryBright,
                            strokeWidth: 1.5,
                            strokeColor: AppColors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double get _barMaxY {
    final maxVal = [correct, incorrect, unanswered]
        .fold<int>(0, (a, b) => a > b ? a : b)
        .toDouble();
    return maxVal <= 0 ? 1 : maxVal * 1.25;
  }

  List<PieChartSectionData> _pieSections() {
    final total = correct + incorrect + unanswered;
    if (total <= 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: AppColors.border,
          radius: 18,
          showTitle: false,
        ),
      ];
    }
    return [
      if (correct > 0)
        PieChartSectionData(
          value: correct.toDouble(),
          color: AppColors.optionCorrect,
          radius: 18,
          showTitle: false,
        ),
      if (incorrect > 0)
        PieChartSectionData(
          value: incorrect.toDouble(),
          color: AppColors.optionWrong,
          radius: 18,
          showTitle: false,
        ),
      if (unanswered > 0)
        PieChartSectionData(
          value: unanswered.toDouble(),
          color: AppColors.gray,
          radius: 18,
          showTitle: false,
        ),
    ];
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textDark,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.titleDark,
          ),
        ),
      ],
    );
  }
}
