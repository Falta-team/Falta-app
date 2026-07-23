import 'package:falta_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CourseSortOption {
  none,
  ratingDesc,
  priceAsc,
  priceDesc,
  nameAsc,
}

enum CourseDifficultyFilter {
  all,
  easy,
  medium,
  hard,
}

class CourseFilterResult {
  const CourseFilterResult({
    required this.sort,
    required this.difficulty,
  });

  final CourseSortOption sort;
  final CourseDifficultyFilter difficulty;
}

Future<CourseFilterResult?> showCourseFilterSheet(
  BuildContext context, {
  required CourseSortOption currentSort,
  required CourseDifficultyFilter currentDifficulty,
}) {
  return showModalBottomSheet<CourseFilterResult>(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => _CourseFilterSheet(
      currentSort: currentSort,
      currentDifficulty: currentDifficulty,
    ),
  );
}

class _CourseFilterSheet extends StatefulWidget {
  const _CourseFilterSheet({
    required this.currentSort,
    required this.currentDifficulty,
  });

  final CourseSortOption currentSort;
  final CourseDifficultyFilter currentDifficulty;

  @override
  State<_CourseFilterSheet> createState() => _CourseFilterSheetState();
}

class _CourseFilterSheetState extends State<_CourseFilterSheet> {
  late CourseSortOption _sort = widget.currentSort;
  late CourseDifficultyFilter _difficulty = widget.currentDifficulty;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 20),
              Text(
                'تصفية وترتيب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'الترتيب',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleDark,
                ),
              ),
              const SizedBox(height: 8),
              _option(
                label: 'بدون ترتيب',
                selected: _sort == CourseSortOption.none,
                onTap: () => setState(() => _sort = CourseSortOption.none),
              ),
              _option(
                label: 'الأعلى تقييمًا',
                selected: _sort == CourseSortOption.ratingDesc,
                onTap: () => setState(() => _sort = CourseSortOption.ratingDesc),
              ),
              _option(
                label: 'السعر: من الأقل للأعلى',
                selected: _sort == CourseSortOption.priceAsc,
                onTap: () => setState(() => _sort = CourseSortOption.priceAsc),
              ),
              _option(
                label: 'السعر: من الأعلى للأقل',
                selected: _sort == CourseSortOption.priceDesc,
                onTap: () => setState(() => _sort = CourseSortOption.priceDesc),
              ),
              _option(
                label: 'الاسم أبجديًا',
                selected: _sort == CourseSortOption.nameAsc,
                onTap: () => setState(() => _sort = CourseSortOption.nameAsc),
              ),
              const SizedBox(height: 16),
              Text(
                'مستوى الصعوبة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in CourseDifficultyFilter.values)
                    ChoiceChip(
                      label: Text(_difficultyLabel(d)),
                      selected: _difficulty == d,
                      onSelected: (_) => setState(() => _difficulty = d),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: GoogleFonts.cairo(
                        color: _difficulty == d
                            ? AppColors.primary
                            : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: _difficulty == d
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      backgroundColor: AppColors.white,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _sort = CourseSortOption.none;
                          _difficulty = CourseDifficultyFilter.all;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('إعادة تعيين', style: GoogleFonts.cairo()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          CourseFilterResult(
                            sort: _sort,
                            difficulty: _difficulty,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('تطبيق', style: GoogleFonts.cairo()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.titleDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _difficultyLabel(CourseDifficultyFilter d) {
    return switch (d) {
      CourseDifficultyFilter.all => 'الكل',
      CourseDifficultyFilter.easy => 'سهل',
      CourseDifficultyFilter.medium => 'متوسط',
      CourseDifficultyFilter.hard => 'صعب',
    };
  }
}
