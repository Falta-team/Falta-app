import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/presentation/screens/exam_units_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/past_exams_archive_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// شاشة الاختبارات — تبويبان: اختبارات تدريبية / أرشيف السنوات السابقة
class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});
  static const String routeName = '/exams';

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen>
    with SingleTickerProviderStateMixin {

  static const _subjects = [
    'الرياضيات',
    'الفيزياء',
    'الكيمياء',
    'اللغة العربية',
    'العلوم الحياتية',
  ];

  late final TabController _tabController;
  int _subjectIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'أسئلة الامتحانات',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.titleDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'اختبارات تدريبية'),
              Tab(text: 'أرشيف الاختبارات'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: اختبارات تدريبية (مواد + قائمة الاختبارات) ────────────
          Column(
            children: [
              // Subject chips
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: List.generate(_subjects.length, (i) {
                      final selected = _subjectIndex == i;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            _subjects[i],
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected ? AppColors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) => setState(() => _subjectIndex = i),
                          selectedColor: AppColors.primary,
                          backgroundColor: const Color(0xFFF5F5F5),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          showCheckmark: false,
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Exam list for selected subject
              Expanded(
                child: ExamUnitsScreen(
                  key: ValueKey(_subjectIndex),
                  subjectTitle: _subjects[_subjectIndex],
                  embeddedMode: true,
                ),
              ),
            ],
          ),

          // ── Tab 2: أرشيف السنوات السابقة ─────────────────────────────────
          const PastExamsArchiveScreen(),
        ],
      ),
    );
  }
}