import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/subscriptions/data/sources/subscription_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  static const String routeName = '/subscriptions';

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final _codeCtrl = TextEditingController();
  final _api = SubscriptionRemoteDataSource();

  SubscriptionStatus? _status;
  List<Map<String, dynamic>> _history = const [];
  bool _loading = true;
  bool _activating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await _api.getStatus();
      await SharedPrefController().setSubscriptionActive(status.active);
      List<Map<String, dynamic>> history = const [];
      try {
        history = await _api.getHistory();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _status = status;
        _history = history;
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

  Future<void> _activate() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز البطاقة')),
      );
      return;
    }
    setState(() => _activating = true);
    try {
      final status = await _api.activateCard(code);
      await SharedPrefController().setSubscriptionActive(status.active);
      if (!mounted) return;
      setState(() {
        _status = status;
        _activating = false;
      });
      _codeCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تفعيل البطاقة بنجاح'),
          backgroundColor: AppColors.primary,
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _activating = false);
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
      appBar: const ExamAppBar(title: 'البطاقات والاشتراك'),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: GoogleFonts.inter(color: AppColors.error),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _StatusCard(status: _status),
                  const SizedBox(height: 20),
                  Text(
                    'تفعيل بطاقة',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.titleDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _codeCtrl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'مثال: FALTA-XXXX',
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'تفعيل',
                    isLoading: _activating,
                    onPressed: _activate,
                  ),
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'سجل الاشتراكات',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.titleDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._history.map((item) {
                      final title = item['subscriptionType']?.toString() ??
                          item['type']?.toString() ??
                          item['cardCode']?.toString() ??
                          'اشتراك';
                      final date = item['createdAt']?.toString() ??
                          item['activatedAt']?.toString() ??
                          item['expiresAt']?.toString() ??
                          '';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              date.length > 10 ? date.substring(0, 10) : date,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final SubscriptionStatus? status;

  @override
  Widget build(BuildContext context) {
    final active = status?.active == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            active ? 'الاشتراك نشط' : 'لا يوجد اشتراك نشط',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.primary : AppColors.titleDark,
            ),
          ),
          if (status?.type != null) ...[
            const SizedBox(height: 6),
            Text(
              'النوع: ${status!.type}',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ],
          if (status?.expiresAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'ينتهي: ${status!.expiresAt}',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
