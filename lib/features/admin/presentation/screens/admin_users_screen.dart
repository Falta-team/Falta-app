import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/admin/data/admin_api_controller.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  static const String routeName = '/admin-users';

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _api = AdminApiController();
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _users = const [];
  bool _loading = true;
  String? _error;
  String? _roleFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await _api.getUsers(
        role: _roleFilter,
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _users = users;
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

  Future<void> _changeRole(Map<String, dynamic> user) async {
    final userId = user['id']?.toString();
    if (userId == null || userId.isEmpty) return;
    final current = user['role']?.toString() ?? 'student';
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'تغيير الرول',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
              for (final role in ['student', 'instructor', 'admin'])
                ListTile(
                  title: Text(
                    role == 'student'
                        ? 'طالب'
                        : role == 'instructor'
                            ? 'معلم'
                            : 'أدمن',
                    style: GoogleFonts.inter(),
                  ),
                  trailing: current == role
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, role),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked == null || picked == current) return;
    try {
      await _api.updateUserRole(userId: userId, role: picked);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الرول'),
          backgroundColor: AppColors.primary,
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _changeSubscription(Map<String, dynamic> user) async {
    final userId = user['id']?.toString();
    if (userId == null || userId.isEmpty) return;
    final current = user['subscriptionStatus']?.toString() ?? 'none';
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'تحديث الاشتراك',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
              for (final status in ['none', 'active', 'expired'])
                ListTile(
                  title: Text(
                    status == 'none'
                        ? 'بدون'
                        : status == 'active'
                            ? 'نشط'
                            : 'منتهي',
                    style: GoogleFonts.inter(),
                  ),
                  trailing: current == status
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, status),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked == null || picked == current) return;
    try {
      await _api.updateUserSubscription(
        userId: userId,
        subscriptionStatus: picked,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الاشتراك'),
          backgroundColor: AppColors.primary,
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
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
      appBar: const ExamAppBar(title: 'المستخدمون'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'بحث...',
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.search, color: AppColors.primary),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: _roleFilter == null,
                  onTap: () {
                    setState(() => _roleFilter = null);
                    _load();
                  },
                ),
                _FilterChip(
                  label: 'طلاب',
                  selected: _roleFilter == 'student',
                  onTap: () {
                    setState(() => _roleFilter = 'student');
                    _load();
                  },
                ),
                _FilterChip(
                  label: 'معلمون',
                  selected: _roleFilter == 'instructor',
                  onTap: () {
                    setState(() => _roleFilter = 'instructor');
                    _load();
                  },
                ),
                _FilterChip(
                  label: 'أدمن',
                  selected: _roleFilter == 'admin',
                  onTap: () {
                    setState(() => _roleFilter = 'admin');
                    _load();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: AppColors.error),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _load,
                        child: _users.isEmpty
                            ? ListView(
                                children: [
                                  const SizedBox(height: 80),
                                  Center(
                                    child: Text(
                                      'لا يوجد مستخدمون',
                                      style: GoogleFonts.inter(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                itemCount: _users.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final u = _users[i];
                                  final name =
                                      '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'
                                          .trim();
                                  final phone =
                                      u['phoneNumber']?.toString() ?? '';
                                  final role = u['role']?.toString() ?? '';
                                  final sub =
                                      u['subscriptionStatus']?.toString() ?? '';
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name.isEmpty ? 'مستخدم' : name,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          phone,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _Badge(
                                              label: role == 'instructor'
                                                  ? 'معلم'
                                                  : role == 'admin'
                                                      ? 'أدمن'
                                                      : 'طالب',
                                            ),
                                            const SizedBox(width: 8),
                                            _Badge(
                                              label: sub == 'active'
                                                  ? 'اشتراك نشط'
                                                  : sub == 'expired'
                                                      ? 'منتهي'
                                                      : 'بدون اشتراك',
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              tooltip: 'تغيير الرول',
                                              onPressed: () => _changeRole(u),
                                              icon: const Icon(
                                                Icons.manage_accounts,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'الاشتراك',
                                              onPressed: () =>
                                                  _changeSubscription(u),
                                              icon: const Icon(
                                                Icons.credit_card,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.titleDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
