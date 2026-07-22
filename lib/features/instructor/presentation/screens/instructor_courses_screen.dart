import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/instructor/data/instructor_api_controller.dart';
import 'package:falta_app/features/instructor/presentation/screens/upload_video_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({super.key});

  @override
  State<InstructorCoursesScreen> createState() =>
      _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen> {
  final _api = InstructorApiController();
  List<Map<String, dynamic>> _courses = const [];
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
      final list = await _api.listCourses();
      if (!mounted) return;
      setState(() {
        _courses = list;
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
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const _CreateCourseScreen()),
    );
    if (created == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'كورساتي'),
      floatingActionButton: FloatingActionButton(
        heroTag: 'instructor_courses_fab',
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
                  : _courses.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                'لا توجد كورسات بعد',
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: _courses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final c = _courses[i];
                            final id = c['id']?.toString() ?? '';
                            final title = c['title']?.toString() ??
                                c['name']?.toString() ??
                                'كورس';
                            final subject = c['subject']?.toString() ?? '';
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
                                      fontSize: 15,
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
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: TextButton.icon(
                                      onPressed: id.isEmpty
                                          ? null
                                          : () => Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      UploadVideoScreen(
                                                    courseId: id,
                                                    courseTitle: title,
                                                  ),
                                                ),
                                              ),
                                      icon: const Icon(
                                        Icons.upload,
                                        color: AppColors.primary,
                                      ),
                                      label: Text(
                                        'رفع فيديو',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primary,
                                        ),
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

class _CreateCourseScreen extends StatefulWidget {
  const _CreateCourseScreen();

  @override
  State<_CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<_CreateCourseScreen> {
  final _title = TextEditingController();
  final _subject = TextEditingController(text: 'math');
  final _desc = TextEditingController();
  final _api = InstructorApiController();
  String _track = 'scientific';
  String _difficulty = 'medium';
  String? _instructorId;
  List<Map<String, dynamic>> _instructors = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  Future<void> _loadInstructors() async {
    try {
      final list = await _api.listInstructors();
      if (!mounted) return;
      setState(() {
        _instructors = list;
        if (list.isNotEmpty) {
          _instructorId = list.first['id']?.toString();
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await _api.createCourse(
        title: _title.text.trim(),
        subject: _subject.text.trim(),
        description: _desc.text.trim(),
        academicTrack: _track,
        difficultyLevel: _difficulty,
        instructorId: _instructorId,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
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
      appBar: const ExamAppBar(title: 'إنشاء كورس'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_title, 'عنوان الكورس'),
          const SizedBox(height: 12),
          _field(_subject, 'المادة (مثل math)'),
          const SizedBox(height: 12),
          _field(_desc, 'الوصف', maxLines: 4),
          const SizedBox(height: 12),
          Text('المسار الأكاديمي',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _track,
            decoration: _decoration(),
            items: const [
              DropdownMenuItem(value: 'scientific', child: Text('علمي')),
              DropdownMenuItem(value: 'literary', child: Text('أدبي')),
            ],
            onChanged: (v) => setState(() => _track = v ?? 'scientific'),
          ),
          const SizedBox(height: 12),
          Text('مستوى الصعوبة',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _difficulty,
            decoration: _decoration(),
            items: const [
              DropdownMenuItem(value: 'easy', child: Text('سهل')),
              DropdownMenuItem(value: 'medium', child: Text('متوسط')),
              DropdownMenuItem(value: 'hard', child: Text('صعب')),
            ],
            onChanged: (v) => setState(() => _difficulty = v ?? 'medium'),
          ),
          if (_instructors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('المدرّس',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _instructorId,
              decoration: _decoration(),
              items: _instructors
                  .map(
                    (i) => DropdownMenuItem(
                      value: i['id']?.toString(),
                      child: Text(
                        i['fullName']?.toString() ??
                            i['name']?.toString() ??
                            'مدرّس',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _instructorId = v),
            ),
          ],
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

  Widget _field(TextEditingController c, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: _decoration(hint: hint),
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
