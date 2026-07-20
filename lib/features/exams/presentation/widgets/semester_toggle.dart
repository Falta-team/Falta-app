import 'package:falta_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SemesterToggle extends StatelessWidget {
  const SemesterToggle({
    required this.selectedSemester,
    required this.onChanged,
    super.key,
  });

  final int selectedSemester;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      // RTL: first child sits on the right (الفصل الأول as in Figma).
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: 'الفصل الأول',
              selected: selectedSemester == 1,
              onTap: () => onChanged(1),
            ),
          ),
          Expanded(
            child: _Tab(
              label: 'الفصل الثاني',
              selected: selectedSemester == 2,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : AppColors.titleDark,
          ),
        ),
      ),
    );
  }
}
