import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/history/domain/entities/history_entities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal subject tabs shown on the history detail screen (Figma 1:24406).
class HistorySubjectStrip extends StatelessWidget {
  const HistorySubjectStrip({
    required this.subjects,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<HistorySubjectEntity> subjects;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final selected = subject.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(subject.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                subject.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
