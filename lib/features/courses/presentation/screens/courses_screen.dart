import 'package:banner_image/banner_image.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/presentation/widgets/subject_card.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  static const String routeName = '/courses';

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int _bannerIndex = 0;

  // ── Banner images ──────────────────────────────────────────────────────────
  final List<String> _banners = [
    'img2banner.png'.image_,
    'img2banner.png'.image_,
    'img2banner.png'.image_,
  ];
  String _image = '';

  // ── Subjects grid ──────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _subjects = [
    {
      'label': 'العلوم الحياتية',
      'sub': '12 استاذ أحياء',
      'image': 'biology',
      'darkBg': true,
    },
    {
      'label': 'الرياضيات',
      'sub': '12 استاذ رياضيات',
      'image': 'math',
      'darkBg': false,
    },
    {
      'label': 'الكيمياء',
      'sub': '12 استاذ كيمياء',
      'image': 'chemistry',
      'darkBg': true,
    },
    {
      'label': 'لغة عربيه',
      'sub': '12 استاذ لغة عربية',
      'image': 'arabic',
      'darkBg': false,
    },
    {
      'label': 'الفيزياء',
      'sub': '12 استاذ فيزياء',
      'image': 'physics',
      'darkBg': false,
    },
    {
      'label': 'الرياضيات',
      'sub': '12 استاذ رياضيات',
      'image': 'math',
      'darkBg': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          toolbarHeight: 72,
          centerTitle: false,

          // Avatar (يسار)
          leading: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.bgLight,
              child: _image.isEmpty
                  ? const Icon(Icons.person, color: AppColors.primary, size: 24)
                  : ClipOval(
                      child: Image.network(
                        'https://falta.app/$_image',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
            ),
          ),
          leadingWidth: 60,

          // Name + subtitle
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الكورسات العلمية',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'مجموعة من الكورسات يقدمها افضل الاساتذة',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),

          // Notification button
          actions: [Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset('logo.png'.image_, height: 34, width: 45),
          )],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.hs,

              // ── Banner ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 180,
                    child: BannerImage(
                      itemLength: _banners.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _bannerIndex = index;
                        });
                      },

                      selectedIndicatorColor: Colors.green,
                      autoPlay: true,
                      borderRadius: BorderRadius.circular(8),
                      children: List.generate(
                        _banners.length,
                        (index) =>
                            Image.asset(_banners[index], fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
              ),

              10.hs,

              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _banners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _bannerIndex ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _bannerIndex
                          ? AppColors.primary
                          : AppColors.kBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),

              20.hs,

              // ── Section Title ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'كل الكورسات',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),

              12.hs,

              // ── Subjects Grid (dark image cards) ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: _subjects.length,
                  itemBuilder: (context, i) {
                    final s = _subjects[i];
                    return SubjectCard(
                      label: s['label'] as String,
                      sub: s['sub'] as String,
                      image: s['image'] as String,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/instructors',
                        arguments: s,
                      ),
                    );
                  },
                ),
              ),

              24.hs,
            ],
          ),
        ),
      ),
    );
  }
}


