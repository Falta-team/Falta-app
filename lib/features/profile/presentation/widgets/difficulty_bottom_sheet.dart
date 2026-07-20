import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/profile/domain/entities/app_settings_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet that lets the user pick the exam questions difficulty.
///
/// Returns the chosen [ExamDifficulty], or null if dismissed.
Future<ExamDifficulty?> showDifficultyBottomSheet(
  BuildContext context, {
  required ExamDifficulty current,
}) {
  return showModalBottomSheet<ExamDifficulty>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => _DifficultySheet(current: current),
  );
}

class _DifficultySheet extends StatelessWidget {
  const _DifficultySheet({required this.current});

  final ExamDifficulty current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 57,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B9B9B),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'صعوبة الاسئلة',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.titleDark,
              ),
            ),
            const SizedBox(height: 14),
            for (final difficulty in ExamDifficulty.values) ...[
              _DifficultyOption(
                difficulty: difficulty,
                selected: difficulty == current,
                onTap: () => Navigator.of(context).pop(difficulty),
              ),
              if (difficulty != ExamDifficulty.values.last)
                const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  final ExamDifficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1A000000)),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              size: 24,
              color: selected ? AppColors.primary : const Color(0xFFBDBDBD),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difficulty.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.titleDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  difficulty.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0x80060606),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
