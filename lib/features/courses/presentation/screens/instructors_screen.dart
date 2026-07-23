import 'dart:async';

import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/providers/courses_provider.dart';
import 'package:falta_app/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:falta_app/features/courses/presentation/widgets/course_filter_sheet.dart';
import 'package:falta_app/features/courses/presentation/widgets/instructor_card.dart';
import 'package:falta_app/features/favorites/domain/providers/favorites_provider.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructorsScreen extends ConsumerStatefulWidget {
  /// Display label shown in the AppBar title (e.g. "الرياضيات").
  final String? subjectLabel;

  /// Real API subject slug used for `GET /courses/subject/{subject}`
  /// (e.g. "math"). Falls back to [subjectLabel] if not provided.
  final String? subjectSlug;

  const InstructorsScreen({super.key, this.subjectLabel, this.subjectSlug});

  static const String routeName = '/instructors';

  @override
  ConsumerState<InstructorsScreen> createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends ConsumerState<InstructorsScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  CourseSortOption _sort = CourseSortOption.none;
  CourseDifficultyFilter _difficulty = CourseDifficultyFilter.all;

  bool get _hasActiveFilter =>
      _sort != CourseSortOption.none ||
      _difficulty != CourseDifficultyFilter.all;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value, String subjectSlug) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = value.trim();
      final notifier =
          ref.read(coursesBySubjectProvider(subjectSlug).notifier);
      if (q.isEmpty) {
        notifier.refresh();
      } else {
        notifier.search(q);
      }
    });
  }

  Future<void> _openFilter() async {
    final result = await showCourseFilterSheet(
      context,
      currentSort: _sort,
      currentDifficulty: _difficulty,
    );
    if (result == null || !mounted) return;
    setState(() {
      _sort = result.sort;
      _difficulty = result.difficulty;
    });
  }

  List<CoursesEntity> _applyFilters(List<CoursesEntity> courses) {
    var list = List<CoursesEntity>.from(courses);

    if (_difficulty != CourseDifficultyFilter.all) {
      final key = switch (_difficulty) {
        CourseDifficultyFilter.easy => 'easy',
        CourseDifficultyFilter.medium => 'medium',
        CourseDifficultyFilter.hard => 'hard',
        CourseDifficultyFilter.all => '',
      };
      list = list.where((c) {
        final level = c.difficultyLevel.toLowerCase().trim();
        return level == key ||
            level.contains(key) ||
            (_difficulty == CourseDifficultyFilter.easy &&
                (level.contains('سهل') || level == 'beginner')) ||
            (_difficulty == CourseDifficultyFilter.medium &&
                (level.contains('متوسط') || level == 'intermediate')) ||
            (_difficulty == CourseDifficultyFilter.hard &&
                (level.contains('صعب') || level == 'advanced'));
      }).toList();
    }

    switch (_sort) {
      case CourseSortOption.none:
        break;
      case CourseSortOption.ratingDesc:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case CourseSortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case CourseSortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case CourseSortOption.nameAsc:
        list.sort((a, b) => a.instructorName.compareTo(b.instructorName));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String subjectLabel = widget.subjectLabel ??
        routeArgs?['label'] as String? ??
        'الكورسات';
    final String subjectSlug = widget.subjectSlug ??
        routeArgs?['image'] as String? ??
        subjectLabel;

    final coursesAsync = ref.watch(coursesBySubjectProvider(subjectSlug));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundAppColor,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            subjectLabel,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.textDark,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.hs,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Material(
                    color: _hasActiveFilter
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _openFilter,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _hasActiveFilter
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: _hasActiveFilter
                              ? AppColors.primary
                              : AppColors.textSecondaryLight,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  12.ws,
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        textDirection: TextDirection.rtl,
                        onChanged: (v) => _onSearchChanged(v, subjectSlug),
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Cairo',
                          color: AppColors.textDark,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'بحث',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          suffixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondaryLight,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            16.hs,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'كل المدرسين',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            12.hs,
            Expanded(
              child: coursesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        12.hs,
                        TextButton(
                          onPressed: () => ref
                              .read(coursesBySubjectProvider(subjectSlug)
                                  .notifier)
                              .refresh(),
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (courses) {
                  final filtered = _applyFilters(courses);
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final course = filtered[i];
                      final favoritesAsync = ref.watch(favoritesListProvider);
                      final favNotifier =
                          ref.read(favoritesListProvider.notifier);
                      final instructorMap = <String, dynamic>{
                        'fullName': course.instructorName,
                        'desc': course.description,
                        'rating': course.rating,
                        'price': course.price,
                        'image': course.image,
                        'saved': favNotifier.isFavorited('course', course.id),
                      };
                      return InstructorCard(
                        name: course.instructorName,
                        instructor: instructorMap,
                        onSave: favoritesAsync.isLoading ||
                                favNotifier.isPending('course', course.id)
                            ? () {}
                            : () async {
                                try {
                                  await favNotifier.toggle(
                                    itemType: 'course',
                                    itemId: course.id,
                                    title: course.title,
                                    subtitle: course.instructorName,
                                    image: course.image,
                                    meta: course.subject,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                        onTap: () => Navigator.pushNamed(
                          context,
                          CourseDetailScreen.routeName,
                          arguments: course.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
