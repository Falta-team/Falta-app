import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:falta_app/features/profile/domain/usecases/get_favorites.dart';
import 'package:falta_app/features/profile/presentation/widgets/favorite_lesson_card.dart';
import 'package:falta_app/features/profile/presentation/widgets/favorite_teacher_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "المفضلة" screen with teachers grid / courses list tabs
/// (Figma nodes 1:24013 and 1:24164).
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  static const String routeName = '/favorites';

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

enum _FavoritesTab { teachers, courses }

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final ProfileRepositoryImpl _repository = ProfileRepositoryImpl();
  late final GetFavoriteTeachers _getTeachers =
      GetFavoriteTeachers(_repository);
  late final GetFavoriteLessons _getLessons = GetFavoriteLessons(_repository);

  _FavoritesTab _tab = _FavoritesTab.teachers;
  bool _loading = true;
  List<FavoriteTeacherEntity> _teachers = const [];
  List<FavoriteLessonEntity> _lessons = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait<Object>([
      _getTeachers(),
      _getLessons(),
    ]);
    if (!mounted) return;
    setState(() {
      _teachers = results[0] as List<FavoriteTeacherEntity>;
      _lessons = results[1] as List<FavoriteLessonEntity>;
      _loading = false;
    });
  }

  void _removeTeacher(String id) {
    setState(() {
      _teachers = _teachers.where((t) => t.id != id).toList();
    });
  }

  void _removeLesson(String id) {
    setState(() {
      _lessons = _lessons.where((l) => l.id != id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _tab == _FavoritesTab.teachers
                    ? _buildTeachersGrid()
                    : _buildLessonsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersGrid() {
    if (_teachers.isEmpty) return const _EmptyState();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 24,
        childAspectRatio: 165 / 169,
      ),
      itemCount: _teachers.length,
      itemBuilder: (context, i) {
        final teacher = _teachers[i];
        return FavoriteTeacherCard(
          teacher: teacher,
          onRemove: () => _removeTeacher(teacher.id),
        );
      },
    );
  }

  Widget _buildLessonsList() {
    if (_lessons.isEmpty) return const _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, i) {
        final lesson = _lessons[i];
        return FavoriteLessonCard(
          lesson: lesson,
          onRemove: () => _removeLesson(lesson.id),
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
