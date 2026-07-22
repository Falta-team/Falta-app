import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  static const String routeName = '/change-password';

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final token = SharedPrefController().accessToken;
      final response = await http.put(
        Uri.parse(ApiSettings.changePassword),
        headers: ApiSettings.authHeaders(token),
        body: jsonEncode({
          'currentPassword': _currentCtrl.text,
          'newPassword': _newCtrl.text,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (ApiSettings.isSuccess(response.statusCode)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير كلمة المرور'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] as String? ?? 'فشل التغيير'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الاتصال: $e'),
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
      appBar: const ExamAppBar(title: 'تغيير كلمة المرور'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'كلمة المرور الحالية',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _currentCtrl,
              hintText: 'كلمة المرور الحالية',
              obscureText: true,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            Text(
              'كلمة المرور الجديدة',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _newCtrl,
              hintText: 'كلمة المرور الجديدة',
              obscureText: true,
              validator: (v) {
                if (v == null || v.length < 6) {
                  return '6 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'تأكيد كلمة المرور',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _confirmCtrl,
              hintText: 'تأكيد كلمة المرور',
              obscureText: true,
              validator: (v) {
                if (v != _newCtrl.text) return 'غير متطابقة';
                return null;
              },
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'حفظ',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
