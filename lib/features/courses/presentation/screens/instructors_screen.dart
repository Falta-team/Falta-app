import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/bloc/courses_bloc.dart';
import 'package:falta_app/features/courses/domain/bloc/courses_event.dart';
import 'package:falta_app/features/courses/domain/bloc/courses_state.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:falta_app/features/courses/presentation/widgets/instructor_card.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructorsScreen extends StatefulWidget {
  final dynamic subject;

  const InstructorsScreen({super.key, this.subject});

  static const String routeName = '/instructors';

  @override
  State<InstructorsScreen> createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Locally remembers which course cards the user bookmarked (the API has
  // no "save instructor" endpoint in this feature's scope).
  final Set<String> _savedCourseIds = {};

  String? _subjectArg;
  bool _dispatched = false;

  // ── Adapt a [CoursesEntity] to the Map shape [InstructorCard] expects ──────
  Map<String, dynamic> _courseToInstructorMap(CoursesEntity c) {
    return <String, dynamic>{
      'courseId': c.id,
      'name': c.instructorName.isEmpty ? c.title : c.instructorName,
      'desc': c.title,
      'rating': c.rating,
      'price': c.price,
      'image': c.image,
      'saved': _savedCourseIds.contains(c.id),
    };
  }

  List<Map<String, dynamic>> _filtered(List<CoursesEntity> courses) {
    final mapped = courses.map(_courseToInstructorMap).toList();
    if (_query.isEmpty) return mapped;
    return mapped
        .where(
          (i) =>
      (i['name'] as String).contains(_query) ||
          (i['desc'] as String).contains(_query),
    )
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject =
        widget.subject ??
            (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?)?['label'] ??
            'الكورسات';

    // Dispatch once, as soon as we know the subject to filter by.
    if (!_dispatched) {
      _dispatched = true;
      _subjectArg = subject.toString();
      context
          .read<CoursesBloc>()
          .add(FetchCoursesRequested(subject: _subjectArg));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundAppColor,

        // ── AppBar ──────────────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            '$subject',
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

            // ── Search Bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Filter icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.textSecondaryLight,
                      size: 22,
                    ),
                  ),
                  12.ws,

                  // Search field
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
                        onChanged: (v) => setState(() => _query = v),
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

            // ── Section title ──────────────────────────────────────────────
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

            // ── Grid (wired to CoursesBloc) ─────────────────────────────────
            Expanded(
              child: BlocBuilder<CoursesBloc, CoursesState>(
                builder: (context, state) {
                  if (state is CoursesLoading || state is CoursesInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is CoursesFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  }

                  final List<CoursesEntity> courses =
                  state is CoursesFetchSuccess ? state.courses : const [];
                  final filtered = _filtered(courses);

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
                    itemBuilder: (context, i) => InstructorCard(
                      instructor: filtered[i],
                      onSave: () => setState(() {
                        final id = filtered[i]['courseId'] as String;
                        if (_savedCourseIds.contains(id)) {
                          _savedCourseIds.remove(id);
                        } else {
                          _savedCourseIds.add(id);
                        }
                      }),
                      onTap: () => Navigator.pushNamed(
                        context,
                        CourseDetailScreen.routeName,
                        arguments: filtered[i]['courseId'] as String,
                      ),
                    ),
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