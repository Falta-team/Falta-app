import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/instructor/data/instructor_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddExamQuestionsScreen extends StatefulWidget {
  const AddExamQuestionsScreen({
    required this.examId,
    required this.examTitle,
    super.key,
  });

  final String examId;
  final String examTitle;

  @override
  State<AddExamQuestionsScreen> createState() => _AddExamQuestionsScreenState();
}

class _AddExamQuestionsScreenState extends State<AddExamQuestionsScreen> {
  final _api = InstructorApiController();
  final _question = TextEditingController();
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _c = TextEditingController();
  final _d = TextEditingController();
  final _explanation = TextEditingController();
  final _topic = TextEditingController();
  String _correct = 'a';
  bool _loading = false;
  int _added = 0;

  @override
  void dispose() {
    _question.dispose();
    _a.dispose();
    _b.dispose();
    _c.dispose();
    _d.dispose();
    _explanation.dispose();
    _topic.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_question.text.trim().isEmpty ||
        _a.text.trim().isEmpty ||
        _b.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل نص السؤال والخيارات')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.addExamQuestion(
        examId: widget.examId,
        questionText: _question.text.trim(),
        optionA: _a.text.trim(),
        optionB: _b.text.trim(),
        optionC: _c.text.trim(),
        optionD: _d.text.trim(),
        correctAnswer: _correct,
        explanation: _explanation.text.trim(),
        topicTag: _topic.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _added++;
        _loading = false;
        _question.clear();
        _a.clear();
        _b.clear();
        _c.clear();
        _d.clear();
        _explanation.clear();
        _topic.clear();
        _correct = 'a';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة السؤال ($_added)'),
          backgroundColor: AppColors.primary,
        ),
      );
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
      appBar: ExamAppBar(title: 'أسئلة: ${widget.examTitle}'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'أسئلة مضافة: $_added',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _field(_question, 'نص السؤال', maxLines: 3),
          const SizedBox(height: 10),
          _field(_a, 'الخيار A'),
          const SizedBox(height: 10),
          _field(_b, 'الخيار B'),
          const SizedBox(height: 10),
          _field(_c, 'الخيار C'),
          const SizedBox(height: 10),
          _field(_d, 'الخيار D'),
          const SizedBox(height: 10),
          Text('الإجابة الصحيحة', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _correct,
            decoration: _decoration(),
            items: const [
              DropdownMenuItem(value: 'a', child: Text('A')),
              DropdownMenuItem(value: 'b', child: Text('B')),
              DropdownMenuItem(value: 'c', child: Text('C')),
              DropdownMenuItem(value: 'd', child: Text('D')),
            ],
            onChanged: (v) => setState(() => _correct = v ?? 'a'),
          ),
          const SizedBox(height: 10),
          _field(_topic, 'الوسم / الموضوع (اختياري)'),
          const SizedBox(height: 10),
          _field(_explanation, 'الشرح (اختياري)', maxLines: 2),
          const SizedBox(height: 20),
          CustomButton(
            text: 'إضافة السؤال',
            isLoading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, _added > 0),
            child: Text('إنهاء', style: GoogleFonts.inter()),
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
