import 'package:banner_image/banner_image.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/presentation/screens/ai_screen.dart';
import 'package:falta_app/features/courses/presentation/screens/courses_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/exams_screen.dart';
import 'package:falta_app/features/home/presentation/screens/falta_bottom_nav.dart';
import 'package:falta_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

// ── Home Body  ─────────────────────
class HomeBodyScreen extends StatefulWidget {
  const HomeBodyScreen({super.key});


  static const List<Map<String, dynamic>> _subjects = [
    {'label': 'الرياضيات', 'image': 'math'},
    {'label': 'الفيزياء', 'image': 'physics'},
    {'label': 'اللغة العربية', 'image': 'arabic'},
    {'label': 'الكيمياء', 'image': 'chemistry'},
  ];

  @override
  State<HomeBodyScreen> createState() => _HomeBodyScreenState();
}

class _HomeBodyScreenState extends State<HomeBodyScreen> {
  final list = <String>[
    'image1banner.png'.image_,
    'image1banner.png'.image_,
    'image1banner.png'.image_,
    'image1banner.png'.image_,
    'image1banner.png'.image_,
    'image1banner.png'.image_,
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.hs,
          Container(
            height: 140,
            width: double.infinity,
            child: BannerImage(
              itemLength: list.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },

              selectedIndicatorColor: Colors.green,
              autoPlay: true,
              borderRadius: BorderRadius.circular(8),
              children: List.generate(
                list.length,
                (index) => Image.asset(list[index], fit: BoxFit.fill),
              ),
            ),
          ),
          12.hs,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              list.length,
              (i) => AnimatedContainer(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                  color: i == currentIndex
                      ? AppColors.primary
                      : AppColors.kBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ),
          16.hs,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'المواد الدراسية',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          16.hs,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
              ),
              itemCount: HomeBodyScreen._subjects.length,
              itemBuilder: (context, i) {
                final s = HomeBodyScreen._subjects[i];
                return GestureDetector(

                  onTap: () => Navigator.pushNamed(
                    context,
                    '/course-detail',
                    arguments: s['label'],
                  ),
                  child: Container(
                    width: 164,
                    height: 164,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.kBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/images/${s['image']}.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.primary,
                              size: 34,
                            ),
                          ),
                        ),
                        16.hs,
                        Text(
                          s['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
