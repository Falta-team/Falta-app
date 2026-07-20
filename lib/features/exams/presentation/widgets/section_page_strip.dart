import 'package:falta_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pagination for sections — RTL: page 1 on the right.
class SectionPageStrip extends StatelessWidget {
  const SectionPageStrip({
    required this.currentIndex,
    required this.total,
    required this.onSelect,
    super.key,
  });

  final int currentIndex;
  final int total;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    // Build descending so with RTL first child (highest) is left... 
    // We want 1 on the right → first in RTL Row = index 0 (page 1)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final selected = i == currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFD4D4D4),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 46,
                  height: 2,
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
