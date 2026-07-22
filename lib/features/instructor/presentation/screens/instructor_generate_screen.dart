import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/data/sources/ai_remote_data_source.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructorGenerateScreen extends StatefulWidget {
  const InstructorGenerateScreen({super.key});

  static const String routeName = '/instructor-generate';

  @override
  State<InstructorGenerateScreen> createState() =>
      _InstructorGenerateScreenState();
}

class _InstructorGenerateScreenState extends State<InstructorGenerateScreen> {
  final _topic = TextEditingController();
  final _subject = TextEditingController(text: 'math');
  final _count = TextEditingController(text: '3');
  final _examId = TextEditingController();
  final _ai = AiRemoteDataSource();

  String _difficulty = 'medium';
  bool _loading = false;
  List<Map<String, dynamic>> _questions = const [];

  @override
  void dispose() {
    _topic.dispose();
    _subject.dispose();
    _count.dispose();
    _examId.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_topic.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل الموضوع')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final list = await _ai.generateQuestions(
        subject: _subject.text.trim(),
        topic: _topic.text.trim(),
        count: int.tryParse(_count.text) ?? 3,
        difficultyLevel: _difficulty,
        examId: _examId.text.trim().isEmpty ? null : _examId.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _questions = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'توليد أسئلة AI'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_subject, 'المادة (math / arabic / ...)'),
          const SizedBox(height: 12),
          _field(_topic, 'الموضوع'),
          const SizedBox(height: 12),
          _field(_count, 'عدد الأسئلة', keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _field(_examId, 'معرّف امتحان (اختياري)'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _difficulty,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(value: 'easy', child: Text('سهل')),
              DropdownMenuItem(value: 'medium', child: Text('متوسط')),
              DropdownMenuItem(value: 'hard', child: Text('صعب')),
            ],
            onChanged: (v) => setState(() => _difficulty = v ?? 'medium'),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'توليد',
            isLoading: _loading,
            onPressed: _generate,
          ),
          if (_questions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'الأسئلة المولّدة (${_questions.length})',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ..._questions.asMap().entries.map((entry) {
              final q = entry.value;
              final text = q['questionText']?.toString() ??
                  q['text']?.toString() ??
                  q['question']?.toString() ??
                  'سؤال ${entry.key + 1}';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(text, style: GoogleFonts.inter(height: 1.4)),
              );
            }),
          ],
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
