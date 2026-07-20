import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultFilterChips extends StatelessWidget {
  const ResultFilterChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ExamResultFilter selected;
  final ValueChanged<ExamResultFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    // RTL: first chip is on the right — الكل | الصحيحة | الخاطئة
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Chip(
          label: 'الكل',
          selected: selected == ExamResultFilter.all,
          onTap: () => onChanged(ExamResultFilter.all),
        ),
        const SizedBox(width: 12),
        _Chip(
          label: 'الصحيحة',
          selected: selected == ExamResultFilter.correct,
          icon: Icons.check,
          onTap: () => onChanged(ExamResultFilter.correct),
        ),
        const SizedBox(width: 12),
        _Chip(
          label: 'الخاطئة',
          selected: selected == ExamResultFilter.incorrect,
          icon: Icons.close,
          onTap: () => onChanged(ExamResultFilter.incorrect),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 33,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBright : AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.white : AppColors.mutedLabel,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.white : AppColors.mutedLabel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
