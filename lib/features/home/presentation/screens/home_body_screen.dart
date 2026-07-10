import 'package:banner_image/banner_image.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:falta_app/features/home/domain/entities/home_entity.dart';
import 'package:falta_app/features/home/domain/providers/home_provider.dart';
import 'package:falta_app/features/home/presentation/widgets/home_card.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Real body of the "الرئيسية" (Home) tab.
///
/// Watches [homeDashboardProvider] and renders the featured courses
/// coming back from it using [HomeCard], on top of the existing banner +
/// subjects grid UI. The request fires automatically the first time the
/// provider is read — no manual dispatch needed on `initState` like the
/// old `HomeBloc` version.
class HomeBodyScreen extends ConsumerStatefulWidget {
  const HomeBodyScreen({super.key});

  static const List<Map<String, dynamic>> _subjects = [
    {'label': 'الرياضيات', 'image': 'math'},
    {'label': 'الفيزياء', 'image': 'physics'},
    {'label': 'اللغة العربية', 'image': 'arabic'},
    {'label': 'الكيمياء', 'image': 'chemistry'},
  ];

  @override
  ConsumerState<HomeBodyScreen> createState() => _HomeBodyScreenState();
}

class _HomeBodyScreenState extends ConsumerState<HomeBodyScreen> {
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
    final homeAsync = ref.watch(homeDashboardProvider);

    ref.listen(homeDashboardProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

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
                    '/instructors',
                    arguments: s,
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

          20.hs,

          // ── Featured Courses (wired to homeDashboardProvider) ────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'كورسات مميزة',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          12.hs,
          _buildFeaturedCourses(context, homeAsync),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourses(
      BuildContext context,
      AsyncValue<HomeEntity> homeAsync,
      ) {
    return homeAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          error.toString(),
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textSecondaryLight,
          ),
        ),
      ),
      data: (dashboard) {
        final courses = dashboard.featuredCourses;
        if (courses.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'لا توجد كورسات متاحة حالياً',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textSecondaryLight,
              ),
            ),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: courses.length,
            itemBuilder: (context, i) {
              final course = courses[i];
              return HomeCard(
                course: course,
                onTap: () => Navigator.pushNamed(
                  context,
                  CourseDetailScreen.routeName,
                  arguments: course.id,
                ),
              );
            },
          ),
        );
      },
    );
  }
}