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

class HomeBodyScreen extends ConsumerStatefulWidget {
  const HomeBodyScreen({super.key});

  // ✅ FIX: asset name per subject key returned by the API
  static const Map<String, String> _subjectAssets = {
    'math':      'math',
    'physics':   'physics',
    'arabic':    'arabic',
    'chemistry': 'chemistry',
    'biology':   'biology',
    'religion':  'religion',
  };

  // Arabic label per subject key
  static const Map<String, String> _subjectLabels = {
    'math':      'الرياضيات',
    'physics':   'الفيزياء',
    'arabic':    'اللغة العربية',
    'chemistry': 'الكيمياء',
    'biology':   'علم الأحياء',
    'religion':  'التربية الدينية',
  };

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

    ref.listen(homeDashboardProvider, (_, next) {
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

          // ── Banner (unchanged) ───────────────────────────────────────
          Container(
            height: 140,
            width: double.infinity,
            child: BannerImage(
              itemLength: list.length,
              onPageChanged: (int index) =>
                  setState(() => currentIndex = index),
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

          // Dots (unchanged)
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

          // ── Section: المواد الدراسية ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'المواد الدراسية',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          16.hs,

          // ✅ FIX: subjects grid from API (not static list)
          homeAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child:
              Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (_, __) => _SubjectsGrid(subjects: const []),
            data: (dashboard) => _SubjectsGrid(subjects: dashboard.subjects),
          ),

          20.hs,
        ],
      ),
    );
  }

}

// ── Subjects Grid Widget ────────────────────────────────────────────────────
class _SubjectsGrid extends StatelessWidget {
  final List<String> subjects;

  const _SubjectsGrid({required this.subjects});

  @override
  Widget build(BuildContext context) {
    // Fallback to known subjects if API returns empty (e.g. first load fails)
    final display = subjects.isEmpty
        ? const ['math', 'physics', 'arabic', 'chemistry']
        : subjects;

    return Padding(
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
        itemCount: display.length,
        itemBuilder: (context, i) {
          final subjectKey = display[i];
          final label = HomeBodyScreen._subjectLabels[subjectKey] ?? subjectKey;
          final asset = HomeBodyScreen._subjectAssets[subjectKey] ?? subjectKey;

          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/instructors',
              arguments: {
                'label':      label,
                'image':      asset,
                'apiSubject': subjectKey,
              },
            ),
            // ✅ Exact same Container/Column widget tree as before
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
                      'assets/images/$asset.png',
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
                    label,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}