import 'dart:io';

import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/instructor/data/instructor_api_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({
    required this.courseId,
    required this.courseTitle,
    super.key,
  });

  final String courseId;
  final String courseTitle;

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final _api = InstructorApiController();
  final _title = TextEditingController();
  final _order = TextEditingController(text: '1');
  File? _file;
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _order.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    setState(() {
      _file = File(path);
      if (_title.text.trim().isEmpty) {
        _title.text = result.files.single.name;
      }
    });
  }

  Future<void> _upload() async {
    if (_file == null || _title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر فيديو وأدخل العنوان')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.uploadVideo(
        courseId: widget.courseId,
        title: _title.text.trim(),
        sequenceOrder: int.tryParse(_order.text) ?? 1,
        file: _file!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع الفيديو'),
          backgroundColor: AppColors.primary,
        ),
      );
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
      appBar: ExamAppBar(title: 'رفع فيديو'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.courseTitle,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.video_file, color: AppColors.primary),
            label: Text(
              _file == null ? 'اختيار فيديو' : _file!.path.split('/').last,
              style: GoogleFonts.inter(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _title,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'عنوان الدرس',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _order,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'ترتيب الدرس',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'رفع',
            isLoading: _loading,
            onPressed: _upload,
          ),
        ],
      ),
    );
  }
}
