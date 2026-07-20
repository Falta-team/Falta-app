import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/history/domain/entities/history_entities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Correct / wrong toggle with counts (Figma nodes 1:24280, 1:24539).
class HistoryFilterToggle extends StatelessWidget {
  const HistoryFilterToggle({
    required this.filter,
    required this.correctCount,
    required this.wrongCount,
    required this.onChanged,
    super.key,
  });

  final HistoryQuestionFilter filter;
  final int correctCount;
  final int wrongCount;
  final ValueChanged<HistoryQuestionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final correctSelected = filter == HistoryQuestionFilter.correct;

    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: correctSelected
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(HistoryQuestionFilter.correct),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: correctSelected
                              ? AppColors.white
                              : Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'الأسئلة الصحيحة '),
                          TextSpan(
                            text: '($correctCount)',
                            style: TextStyle(
                              color: correctSelected
                                  ? const Color(0x80FFFFFF)
                                  : const Color(0x80000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(HistoryQuestionFilter.wrong),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: correctSelected
                              ? Colors.black
                              : AppColors.white,
                        ),
                        children: [
                          const TextSpan(text: 'الأسئلة الخاطئة '),
                          TextSpan(
                            text: '($wrongCount)',
                            style: TextStyle(
                              color: correctSelected
                                  ? const Color(0x80000000)
                                  : const Color(0x80FFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
