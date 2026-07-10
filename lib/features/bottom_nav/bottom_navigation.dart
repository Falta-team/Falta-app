import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/presentation/screens/ai_screen.dart';
import 'package:falta_app/features/courses/presentation/screens/courses_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/exams_screen.dart';
import 'package:falta_app/features/home/presentation/screens/falta_bottom_nav.dart';
import 'package:falta_app/features/home/presentation/screens/home_body_screen.dart';
import 'package:falta_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});



  @override
  Widget build(BuildContext context) {
    return FaltaBottomNavigationScreen(
      pages: [
        // ── الرئيسية ────────────────────────────────────────────────────────
        FaltaBottomNavigationData(
          title: 'الرئيسية',
          screen: const HomeBodyScreen(),
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

        // ── الكورسات ────────────────────────────────────────────────────────
        FaltaBottomNavigationData(
          title: 'الكورسات',
          screen: const CoursesScreen(),
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

        // ── أسئلة الامتحانات ────────────────────────────────────────────────
        FaltaBottomNavigationData(
          title: 'أسئلة الامتحانات',
          screen: const ExamsScreen(),

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

        // ── حسابي ───────────────────────────────────────────────────────────
        FaltaBottomNavigationData(
          title: 'حسابي',
          screen: const ProfileScreen(),
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

      // ── FAB → FaltaChat ─────────────────────────────────────────────────
      fab: Container(
        height: 60,
        width: 60,

        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FaltaChatAIScreen()),
          ),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(30),
            side: BorderSide(color: AppColors.white, width: 0.8),
          ),
          child: Image.asset('img_logo_btn.png'.image_),
        ),
      ),
    );
  }
}
