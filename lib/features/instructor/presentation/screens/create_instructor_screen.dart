import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/instructor/data/instructor_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateInstructorScreen extends StatefulWidget {
  const CreateInstructorScreen({super.key});

  @override
  State<CreateInstructorScreen> createState() => _CreateInstructorScreenState();
}

class _CreateInstructorScreenState extends State<CreateInstructorScreen> {
  final _api = InstructorApiController();
  final _name = TextEditingController();
  final _credentials = TextEditingController();
  final _expertise = TextEditingController();
  final _bio = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _credentials.dispose();
    _expertise.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await _api.createInstructor(
        fullName: _name.text.trim(),
        credentials: _credentials.text.trim(),
        expertiseAreas: _expertise.text.trim(),
        biography: _bio.text.trim(),
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
      appBar: const ExamAppBar(title: 'إضافة مدرّس'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_name, 'الاسم الكامل'),
          const SizedBox(height: 12),
          _field(_credentials, 'المؤهلات'),
          const SizedBox(height: 12),
          _field(_expertise, 'مجالات الخبرة'),
          const SizedBox(height: 12),
          _field(_bio, 'نبذة', maxLines: 4),
          const SizedBox(height: 24),
          CustomButton(
            text: 'حفظ',
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
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
