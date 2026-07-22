import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/admin/data/admin_api_controller.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_cards_screen.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/create_instructor_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_courses_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_exams_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_generate_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api = AdminApiController();
  Map<String, dynamic>? _stats;
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
      final stats = await _api.getStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Text(
                'لوحة الأدمن',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.titleDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'إدارة المستخدمين والبطاقات والمحتوى',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: GoogleFonts.inter(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ملاحظة: تحتاج حساب أدمن من السيرفر لعرض الإحصائيات.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                _StatsGrid(stats: _stats ?? const {}),
                const SizedBox(height: 20),
              ],
              _ActionCard(
                title: 'المستخدمون',
                subtitle: 'عرض وتغيير الرول والاشتراك',
                icon: Icons.people_outline,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminUsersScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'بطاقات الاشتراك',
                subtitle: 'إنشاء بطاقات تفعيل للطلاب',
                icon: Icons.credit_card,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminCardsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'الكورسات',
                subtitle: 'إنشاء وعرض الكورسات',
                icon: Icons.menu_book_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const InstructorCoursesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'الامتحانات',
                subtitle: 'إنشاء امتحانات وأسئلة',
                icon: Icons.quiz_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const InstructorExamsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'إضافة مدرّس',
                subtitle: 'إنشاء ملف مدرّس جديد',
                icon: Icons.person_add_alt_1_outlined,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreateInstructorScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'توليد أسئلة AI',
                subtitle: 'توليد أسئلة بالذكاء الاصطناعي',
                icon: Icons.auto_awesome,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const InstructorGenerateScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final entries = <MapEntry<String, String>>[
      MapEntry('المستخدمون', _pick(stats, ['usersCount', 'totalUsers', 'studentsCount'])),
      MapEntry('المعلمون', _pick(stats, ['instructorsCount', 'teachersCount', 'instructorCount'])),
      MapEntry('الكورسات', _pick(stats, ['coursesCount', 'totalCourses', 'courseCount'])),
      MapEntry('الامتحانات', _pick(stats, ['examsCount', 'totalExams', 'examCount'])),
    ];

    // Flatten known nested shapes like { totals: { users: 10 } }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const gap = 10.0;
        final itemWidth = (width - gap) / 2;
        const itemHeight = 96.0;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: entries
              .map(
                (e) => SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            e.value,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _pick(Map<String, dynamic> map, List<String> keys) {
    String? from(Map<String, dynamic> source) {
      for (final k in keys) {
        final v = source[k];
        if (v is num || v is String) return v.toString();
      }
      return null;
    }

    final direct = from(map);
    if (direct != null) return direct;

    for (final value in map.values) {
      if (value is Map<String, dynamic>) {
        final nested = from(value);
        if (nested != null) return nested;
      }
    }

    // Fallback: count list length if API returned collections
    for (final k in ['users', 'instructors', 'courses', 'exams']) {
      if (keys.any((key) => key.toLowerCase().contains(k.substring(0, 4)))) {
        final v = map[k];
        if (v is List) return '${v.length}';
        if (v is Map && v['count'] is num) return '${v['count']}';
      }
    }
    return '—';
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.gray),
            ],
          ),
        ),
      ),
    );
  }
}
