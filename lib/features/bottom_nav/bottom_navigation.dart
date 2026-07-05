import 'package:banner_image/banner_image.dart';
import 'package:falta_app/features/ai/presentation/screens/ai_screen.dart';
import 'package:falta_app/features/courses/presentation/screens/courses_screen.dart';
import 'package:falta_app/features/exams/presentation/screens/exams_screen.dart';
import 'package:falta_app/features/home/presentation/screens/falta_bottom_nav.dart';
import 'package:falta_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const Color kGreen = Color(0xFF44AE02);
  static const Color kTextGray = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return FaltaBottomNavigationScreen(
      pages: [
        // ── الرئيسية ────────────────────────────────────────────────────────
        FaltaBottomNavigationData(
          title: 'الرئيسية',
          screen: const HomeBodyScreen(),
          icon: const Icon(Icons.home_outlined, color: kTextGray, size: 24),
          selectedIcon: const Icon(Icons.home_rounded, color: kGreen, size: 24),
        ),

        // ── الكورسات ────────────────────────────────────────────────────────
        FaltaBottomNavigationData(
          title: 'الكورسات',
          screen: const CoursesScreen(),
          icon: const Icon(
            Icons.play_circle_outline,
            color: kTextGray,
            size: 24,
          ),
          selectedIcon: const Icon(
            Icons.play_circle_rounded,
            color: kGreen,
            size: 24,
          ),
        ),

        // ── أسئلة الامتحانات ────────────────────────────────────────────────
        FaltaBottomNavigationData(
          title: 'أسئلة الامتحانات',
          screen: const ExamsScreen(),
          icon: const Icon(Icons.quiz_outlined, color: kTextGray, size: 24),
          selectedIcon: const Icon(Icons.quiz_rounded, color: kGreen, size: 24),
        ),

        // ── حسابي ───────────────────────────────────────────────────────────
        FaltaBottomNavigationData(
          title: 'حسابي',
          screen: const ProfileScreen(),
          hideAppBar: true,
          icon: const Icon(Icons.person_outline, color: kTextGray, size: 24),
          selectedIcon: const Icon(
            Icons.person_rounded,
            color: kGreen,
            size: 24,
          ),
        ),
      ],

      // ── FAB → FaltaChat ─────────────────────────────────────────────────
      fab: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FaltaChatAIScreen()),
        ),
        backgroundColor: kGreen,
        elevation: 4,
        child: const Icon(
          
          Icons.smart_toy_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ── Home Body (بدون AppBar لأن AppBar موجود بالـ wrapper) ─────────────────────
class HomeBodyScreen extends StatefulWidget {
  const HomeBodyScreen({super.key});

  static const Color kBg = Color(0xFFF3F9FF);
  static const Color kGreen = Color(0xFF44AE02);
  static const Color kGreenLight = Color(0xFFE8F5E2);
  static const Color kTextDark = Color(0xFF1A202C);
  static const Color kTextGray = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE2E8F0);
  static const Color kWhite = Color(0xFFFFFFFF);

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
    'assets/images/image1banner.png',
    'assets/images/image1banner.png',
    'assets/images/image1banner.png',
    'assets/images/image1banner.png',
    'assets/images/image1banner.png',
    'assets/images/image1banner.png',
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner ──────────────────────────────────────────────────────
          BannerImage(
            itemLength: list.length,
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            selectedIndicatorColor: Colors.green,
            autoPlay: true,
            borderRadius: BorderRadius.circular(8),
            onTap: (int index) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("AppText.on_tap" + index.toString())),
              );
            },
            children: List.generate(
              list.length,
                  (index) => Image.asset(list[index], fit: BoxFit.cover),
            ),
          ),

          24.hs,

          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              list.length,
                  (i) => AnimatedContainer(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == currentIndex ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == currentIndex
                      ? HomeBodyScreen.kGreen
                      : HomeBodyScreen.kBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Section Title ────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'المواد الدراسية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: HomeBodyScreen.kTextDark,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Subjects Grid ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
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
                    decoration: BoxDecoration(
                      color: HomeBodyScreen.kWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: HomeBodyScreen.kBorder),
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
                              color: HomeBodyScreen.kGreen,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s['label'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: HomeBodyScreen.kTextDark,
                            fontFamily: 'Cairo',
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
