import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_cards_screen.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:falta_app/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:falta_app/features/auth/data/auth_api_controller.dart';
import 'package:falta_app/features/home/presentation/screens/falta_bottom_nav.dart';
import 'package:falta_app/features/instructor/presentation/screens/create_instructor_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_courses_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_exams_screen.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminShellScreen extends StatelessWidget {
  const AdminShellScreen({super.key});

  static const String routeName = '/admin';

  @override
  Widget build(BuildContext context) {
    return FaltaBottomNavigationScreen(
      pages: [
        FaltaBottomNavigationData(
          title: 'لوحة الأدمن',
          screen: const AdminDashboardScreen(),
          icon: Image.asset(
            'icon_home.png'.icon_,
            color: AppColors.gray,
            height: 24,
            width: 24,
          ),
          selectedIcon: Image.asset(
            'icon_home.png'.icon_,
            color: AppColors.primary,
            height: 24,
            width: 24,
          ),
        ),
        FaltaBottomNavigationData(
          title: 'المستخدمون',
          screen: const AdminUsersScreen(),
          hideAppBar: true,
          icon: const Icon(Icons.people_outline, color: AppColors.gray),
          selectedIcon:
              const Icon(Icons.people_outline, color: AppColors.primary),
        ),
        FaltaBottomNavigationData(
          title: 'البطاقات',
          screen: const AdminCardsScreen(),
          hideAppBar: true,
          icon: const Icon(Icons.credit_card, color: AppColors.gray),
          selectedIcon:
              const Icon(Icons.credit_card, color: AppColors.primary),
        ),
        FaltaBottomNavigationData(
          title: 'حسابي',
          screen: const _AdminProfileTab(),
          hideAppBar: true,
          icon: Image.asset(
            'icon_profile.png'.icon_,
            color: AppColors.gray,
            height: 24,
            width: 24,
          ),
          selectedIcon: Image.asset(
            'icon_profile.png'.icon_,
            color: AppColors.primary,
            height: 24,
            width: 24,
          ),
        ),
      ],
    );
  }
}

class _AdminProfileTab extends StatelessWidget {
  const _AdminProfileTab();

  Future<void> _logout(BuildContext context) async {
    final pref = SharedPrefController();
    await AuthApiController().logout(
      accessToken: pref.accessToken,
      refreshToken: pref.refreshToken,
    );
    await pref.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final pref = SharedPrefController();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.bgLight,
              child: Text(
                pref.firstName.isNotEmpty ? pref.firstName[0] : 'أ',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              pref.fullName.isEmpty ? 'أدمن' : pref.fullName,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'أدمن',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            ListTile(
              leading: const Icon(Icons.person_add_alt, color: AppColors.primary),
              title: Text('إضافة مدرّس', style: GoogleFonts.inter()),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreateInstructorScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: AppColors.primary),
              title: Text('الكورسات', style: GoogleFonts.inter()),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const InstructorCoursesScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: AppColors.primary),
              title: Text('الامتحانات', style: GoogleFonts.inter()),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const InstructorExamsScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                'تسجيل الخروج',
                style: GoogleFonts.inter(color: AppColors.error),
              ),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
