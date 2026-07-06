import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/presentation/widgets/instructor_card.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
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

  // ── Mock instructors ───────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _instructors = List.generate(
    6,
    (_) => {
      'name': 'الأستاذ محمد اسماعيل',
      'desc': 'بكالوريس رياضيات خبره في مجال التدريس',
      'rating': 4,
      'price': 15,
      'image': 'teacher', // assets/images/teacher.png
      'saved': false,
    },
  );

  List<Map<String, dynamic>> get _filtered => _query.isEmpty
      ? _instructors
      : _instructors
            .where(
              (i) =>
                  (i['name'] as String).contains(_query) ||
                  (i['desc'] as String).contains(_query),
            )
            .toList();

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

            // ── Grid ───────────────────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) => InstructorCard(
                        instructor: _filtered[i],
                        onSave: () => setState(
                          () => _filtered[i]['saved'] =
                              !(_filtered[i]['saved'] as bool),
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/course-detail',
                          arguments: _filtered[i],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
