import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/instructor/data/instructor_api_controller.dart';
import 'package:falta_app/features/instructor/presentation/screens/add_exam_questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructorExamsScreen extends StatefulWidget {
  const InstructorExamsScreen({super.key});

  @override
  State<InstructorExamsScreen> createState() => _InstructorExamsScreenState();
}

class _InstructorExamsScreenState extends State<InstructorExamsScreen> {
  final _api = InstructorApiController();
  List<Map<String, dynamic>> _exams = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.listExams();
      if (!mounted) return;
      setState(() {
        _exams = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _openCreate() async {
    final result = await Navigator.of(context).push<Map<String, String>?>(
      MaterialPageRoute(builder: (_) => const _CreateExamScreen()),
    );
    if (!mounted) return;
    if (result != null) {
      final id = result['id'];
      final title = result['title'] ?? 'امتحان';
      if (id != null && id.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AddExamQuestionsScreen(
              examId: id,
              examTitle: title,
            ),
          ),
        );
      }
      await _load();
    }
  }

  Future<void> _openAddQuestions(Map<String, dynamic> exam) async {
    final id = exam['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final title =
        exam['title']?.toString() ?? exam['name']?.toString() ?? 'امتحان';
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddExamQuestionsScreen(
          examId: id,
          examTitle: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'امتحانات المعلم'),
      floatingActionButton: FloatingActionButton(
        heroTag: 'instructor_exams_fab',
        onPressed: _openCreate,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: _error != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(child: Text(_error!)),
                      ],
                    )
                  : _exams.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                'لا توجد امتحانات بعد',
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: _exams.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final e = _exams[i];
                            final title = e['title']?.toString() ??
                                e['name']?.toString() ??
                                'امتحان';
                            final subject = e['subject']?.toString() ?? '';
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (subject.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      subject,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => _openAddQuestions(e),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.primary,
                                    ),
                                    label: Text(
                                      'إضافة أسئلة',
                                      style: GoogleFonts.inter(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
    );
  }
}

class _CreateExamScreen extends StatefulWidget {
  const _CreateExamScreen();

  @override
  State<_CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<_CreateExamScreen> {
  final _title = TextEditingController();
  final _subject = TextEditingController(text: 'math');
  final _duration = TextEditingController(text: '30');
  final _count = TextEditingController(text: '10');
  final _api = InstructorApiController();
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _duration.dispose();
    _count.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final data = await _api.createExam(
        title: _title.text.trim(),
        subject: _subject.text.trim(),
        durationMinutes: int.tryParse(_duration.text) ?? 30,
        questionCount: int.tryParse(_count.text) ?? 10,
      );
      if (!mounted) return;
      final id = data['id']?.toString() ??
          data['examId']?.toString() ??
          '';
      Navigator.pop(context, {
        'id': id,
        'title': _title.text.trim(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'إنشاء امتحان'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_title, 'عنوان الامتحان'),
          const SizedBox(height: 12),
          _field(_subject, 'المادة'),
          const SizedBox(height: 12),
          _field(_duration, 'المدة بالدقائق',
              keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _field(_count, 'عدد الأسئلة', keyboard: TextInputType.number),
          const SizedBox(height: 24),
          CustomButton(
            text: 'إنشاء',
            isLoading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint, {
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
