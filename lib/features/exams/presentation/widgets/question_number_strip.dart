import 'package:falta_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionNumberStrip extends StatelessWidget {
  const QuestionNumberStrip({
    required this.currentIndex,
    required this.total,
    required this.onSelect,
    required this.onPreviousPage,
    required this.onNextPage,
    super.key,
  });

  final int currentIndex;
  final int total;
  final ValueChanged<int> onSelect;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  @override
  Widget build(BuildContext context) {
    final windowStart =
        (currentIndex - 2).clamp(0, (total - 5).clamp(0, total));
    final indices = List<int>.generate(
      5.clamp(0, total),
      (i) => windowStart + i,
    ).where((i) => i < total).toList();

    // RTL: start(right)=التالي، end(left)=السابق
    return Row(
      children: [
        _ArrowButton(
          icon: Icons.chevron_right,
          onTap: onNextPage,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: indices.map((i) {
                  final selected = i == currentIndex;
                  return GestureDetector(
                    onTap: () => onSelect(i),
                    child: Container(
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
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : (currentIndex + 1) / total,
                  minHeight: 2,
                  backgroundColor: const Color(0xFFE0E0E0),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _ArrowButton(
          icon: Icons.chevron_left,
          onTap: onPreviousPage,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Icon(icon, size: 22, color: AppColors.titleDark),
      ),
    );
  }
}
