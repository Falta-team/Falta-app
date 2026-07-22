import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/favorites/domain/entities/favorite_entry_entity.dart';
import 'package:falta_app/features/favorites/domain/providers/favorites_provider.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:falta_app/features/profile/presentation/widgets/favorite_lesson_card.dart';
import 'package:falta_app/features/profile/presentation/widgets/favorite_teacher_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// "المفضلة" screen with teachers grid / courses list tabs
/// (Figma nodes 1:24013 and 1:24164).
///
/// Backed by the real `GET /favorites` API via [favoritesListProvider] —
/// the same provider every bookmark button in the app reads/writes, so
/// removing an item here also un-marks it wherever else it's shown.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  static const String routeName = '/favorites';

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

enum _FavoritesTab { teachers, courses }

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  _FavoritesTab _tab = _FavoritesTab.teachers;

  Future<void> _remove(FavoriteEntryEntity entry) async {
    try {
      await ref.read(favoritesListProvider.notifier).toggle(
            itemType: entry.itemType,
            itemId: entry.itemId,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'المفضلة'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tabs ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 22),
            child: Row(
              children: [
                _TabChip(
                  label: 'المدرسين',
                  selected: _tab == _FavoritesTab.teachers,
                  onTap: () =>
                      setState(() => _tab = _FavoritesTab.teachers),
                ),
                const SizedBox(width: 24),
                _TabChip(
                  label: 'الكورسات',
                  selected: _tab == _FavoritesTab.courses,
                  onTap: () => setState(() => _tab = _FavoritesTab.courses),
                ),
              ],
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: favoritesAsync.when(
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
                        style: GoogleFonts.cairo(color: AppColors.titleDark),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.read(favoritesListProvider.notifier).refresh(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (entries) {
                // Only `itemType: "course"` is confirmed by the API; any
                // `instructor` entries (if the backend ever adds that
                // type) land in the teachers tab, everything else in
                // courses.
                final teacherEntries =
                    entries.where((e) => e.itemType == 'instructor').toList();
                final courseEntries =
                    entries.where((e) => e.itemType != 'instructor').toList();

                return _tab == _FavoritesTab.teachers
                    ? _buildTeachersGrid(teacherEntries)
                    : _buildLessonsList(courseEntries);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersGrid(List<FavoriteEntryEntity> entries) {
    if (entries.isEmpty) return const _EmptyState();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 24,
        childAspectRatio: 165 / 169,
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        final teacher = FavoriteTeacherEntity(
          id: entry.itemId,
          name: entry.title,
          bio: entry.meta,
          price: 0,
          rating: 0,
          image: entry.image,
        );
        return FavoriteTeacherCard(
          teacher: teacher,
          onRemove: () => _remove(entry),
        );
      },
    );
  }

  Widget _buildLessonsList(List<FavoriteEntryEntity> entries) {
    if (entries.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, i) {
        final entry = entries[i];
        final lesson = FavoriteLessonEntity(
          id: entry.itemId,
          lessonTitle: entry.title,
          subject: entry.meta,
          teacherName: entry.subtitle,
          image: entry.image,
        );
        return FavoriteLessonCard(
          lesson: lesson,
          onTap: () => Navigator.pushNamed(
            context,
            CourseDetailScreen.routeName,
            arguments: entry.itemId,
          ),
          onRemove: () => _remove(entry),
        );
      },
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
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
        width: 79,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0x4DD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'لا توجد عناصر في المفضلة',
        style: TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
