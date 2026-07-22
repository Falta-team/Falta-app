import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/admin/data/admin_api_controller.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCardsScreen extends StatefulWidget {
  const AdminCardsScreen({super.key});

  static const String routeName = '/admin-cards';

  @override
  State<AdminCardsScreen> createState() => _AdminCardsScreenState();
}

class _AdminCardsScreenState extends State<AdminCardsScreen> {
  final _api = AdminApiController();
  final _countCtrl = TextEditingController(text: '3');
  final _daysCtrl = TextEditingController(text: '30');
  String _type = 'standard';
  bool _loading = false;
  List<dynamic> _created = const [];

  @override
  void dispose() {
    _countCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      final result = await _api.createCards(
        count: int.tryParse(_countCtrl.text) ?? 3,
        subscriptionType: _type,
        durationDays: int.tryParse(_daysCtrl.text) ?? 30,
      );
      if (!mounted) return;
      final cards = result['cards'] as List<dynamic>? ??
          result['items'] as List<dynamic>? ??
          const [];
      setState(() {
        _created = cards;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء البطاقات'),
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
      appBar: const ExamAppBar(title: 'بطاقات الاشتراك'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'عدد البطاقات',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _countCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: _decoration(),
          ),
          const SizedBox(height: 14),
          Text(
            'مدة الاشتراك (أيام)',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _daysCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: _decoration(),
          ),
          const SizedBox(height: 14),
          Text(
            'نوع الاشتراك',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: _decoration(),
            items: const [
              DropdownMenuItem(value: 'standard', child: Text('قياسي')),
              DropdownMenuItem(value: 'premium', child: Text('مميز')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'standard'),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'إنشاء البطاقات',
            isLoading: _loading,
            onPressed: _create,
          ),
          if (_created.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'البطاقات المنشأة',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ..._created.map((c) {
              final map = c is Map<String, dynamic> ? c : <String, dynamic>{};
              final code = map['cardCode']?.toString() ??
                  map['code']?.toString() ??
                  c.toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  code,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
