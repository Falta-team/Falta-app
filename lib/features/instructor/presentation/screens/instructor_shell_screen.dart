import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/presentation/screens/ai_screen.dart';
import 'package:falta_app/features/auth/data/auth_api_controller.dart';
import 'package:falta_app/features/home/presentation/screens/falta_bottom_nav.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_courses_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_dashboard_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_exams_screen.dart';
import 'package:falta_app/features/instructor/presentation/screens/instructor_generate_screen.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom-nav shell for instructor role.
class InstructorShellScreen extends StatelessWidget {
  const InstructorShellScreen({super.key});

  static const String routeName = '/instructor';

  @override
  Widget build(BuildContext context) {
    return FaltaBottomNavigationScreen(
      pages: [
        FaltaBottomNavigationData(
          title: 'لوحة المعلم',
          screen: const InstructorDashboardScreen(),
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
          title: 'كورساتي',
          screen: const InstructorCoursesScreen(),
          hideAppBar: true,
          icon: Image.asset(
            'icon_courses.png'.icon_,
            color: AppColors.gray,
            height: 24,
            width: 24,
          ),
          selectedIcon: Image.asset(
            'icon_courses.png'.icon_,
            color: AppColors.primary,
            height: 24,
            width: 24,
          ),
        ),
        FaltaBottomNavigationData(
          title: 'الامتحانات',
          screen: const InstructorExamsScreen(),
          hideAppBar: true,
          icon: Image.asset(
            'icon_exams.png'.icon_,
            color: AppColors.gray,
            height: 24,
            width: 24,
          ),
          selectedIcon: Image.asset(
            'icon_exams.png'.icon_,
            color: AppColors.primary,
            height: 24,
            width: 24,
          ),
        ),
        FaltaBottomNavigationData(
          title: 'حسابي',
          screen: const _InstructorProfileTab(),
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

class _InstructorProfileTab extends StatelessWidget {
  const _InstructorProfileTab();

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
                pref.firstName.isNotEmpty ? pref.firstName[0] : 'م',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              pref.fullName.isEmpty ? 'معلم' : pref.fullName,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pref.role.labelAr,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: AppColors.primary),
              title: Text('توليد أسئلة بالذكاء الاصطناعي',
                  style: GoogleFonts.inter()),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InstructorGenerateScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.primary),
              title: Text('مساعد فلتا', style: GoogleFonts.inter()),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FaltaChatAIScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text('تسجيل الخروج',
                  style: GoogleFonts.inter(color: AppColors.error)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
