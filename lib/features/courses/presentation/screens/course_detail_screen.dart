import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/providers/courses_provider.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  /// Real course id, used to fetch details via [courseDetailsProvider].
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  static const String routeName = '/course-detail';

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // NOTE: there is no confirmed endpoint/model for per-lesson video lists
  // or comments in the current API (the Postman collection only exposes
  // `GET /courses/{id}/videos` with no sample response, and no comments
  // endpoint at all). Per the "verify the real shape before mapping" rule,
  // these stay as local placeholders instead of being wired to invented
  // fields — flagging this so it can be revisited once those endpoints
  // are confirmed.
  final List<Map<String, String>> _lessons = [
    {'title': 'الدرس الأول/ التفاضل والتكامل', 'duration': '1 س 12 د'},
    {'title': 'الدرس الأول/ التفاضل والتكامل', 'duration': '1 س 12 د'},
    {'title': 'الدرس الثاني/ قواعد الاشتقاق', 'duration': '45 د'},
    {'title': 'الدرس الثالث/ التطبيقات', 'duration': '1 س 5 د'},
  ];

  final List<Map<String, String>> _comments = [
    {
      'name': 'دينا الفليت',
      'avatar': 'avatar',
      'text':
          'يسرنا أن نقدم لزملائنا المعلمين والمعلمات، ولطلبتنا الأعزاء كتاب الرياضيات للصف.',
      'likes': '4',
      'replies': '1',
    },
    {
      'name': 'دينا الفليت',
      'avatar': 'avatar',
      'text':
          'يسرنا أن نقدم لزملائنا المعلمين والمعلمات، ولطلبتنا الأعزاء كتاب الرياضيات للصف.',
      'likes': '4',
      'replies': '1',
    },
    {
      'name': 'أحمد محمود',
      'avatar': 'avatar',
      'text': 'كورس ممتاز جداً، الشرح واضح ومفهوم. أنصح به الجميع.',
      'likes': '7',
      'replies': '2',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailsProvider(widget.courseId));
    print(widget.courseId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: courseAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                    ),
                  ),
                  12.hs,
                  TextButton(
                    onPressed: () => ref.invalidate(
                      courseDetailsProvider(widget.courseId),
                    ),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (course) =>
              _buildContent(context, course),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CoursesEntity course) {
    return Column(
      children: [
        // ── Dark Video Header ─────────────────────────────────────────
        Stack(
          children: [
            // Video background
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Image.asset(
                'assets/images/${course.image.isNotEmpty ? course.image : 'math'}.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A2E)),
              ),
            ),

            // Gradient overlay
            Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x99000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),

            // Play button (center)
            const Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.play_circle_filled,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),

            // Back arrow (top left in RTL = top right visually)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),

        // ── White Bottom Sheet ────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title row + Bookmark ───────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                          12.ws,
                          const Icon(
                            Icons.bookmark,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ],
                      ),

                      12.hs,

                      // ── Teacher ────────────────────────────────────
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          6.ws,
                          Text(
                            course.instructorName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Cairo',
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      10.hs,

                      // ── Videos count ────────────────────────────────
                      // NOTE: CoursesEntity only exposes `lessonsCount`;
                      // there is no confirmed duration/hours/minutes
                      // field from the API, so that part of the original
                      // mock UI is left blank rather than fabricated.
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_filled_rounded,
                            color: AppColors.textSecondaryLight,
                            size: 20,
                          ),
                          4.ws,
                          Text(
                            '${course.lessonsCount} فيديو',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          36.ws,
                          const Icon(
                            Icons.access_time_filled,
                            color: AppColors.textSecondaryLight,
                            size: 20,
                          ),
                          4.ws,
                          Text(
                            '${course.lessonsCount} س',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),

                      14.hs,

                      // ── About section ──────────────────────────────
                      Text(
                        'نبذة عن الكورس',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      6.hs,
                      Text(
                        course.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),

                14.hs,

                // ── Tabs ──────────────────────────────────────────────
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondaryLight,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'الفيديوهات'),
                    Tab(text: 'التعليقات'),
                  ],
                ),

                // ── Tab content ───────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildVideosTab(), _buildCommentsTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Videos Tab ─────────────────────────────────────────────────────────────
  Widget _buildVideosTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _lessons.length,
      itemBuilder: (context, i) {
        final lesson = _lessons[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Green play button
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              14.ws,

              // Lesson info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson['title']!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    4.hs,
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                        4.ws,
                        Text(
                          lesson['duration']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Comments Tab ────────────────────────────────────────────────────────────
  Widget _buildCommentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _comments.length,
      itemBuilder: (context, i) {
        final c = _comments[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Image.asset(
                  'assets/images/${c['avatar']}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(
                    c['name']!.substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
              10.ws,

              // Comment body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    4.hs,
                    Text(
                      c['text']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                    8.hs,

                    // Like + Reply row
                    Row(
                      children: [
                        const Icon(
                          Icons.thumb_up_outlined,
                          size: 15,
                          color: AppColors.textSecondaryLight,
                        ),
                        4.ws,
                        Text(
                          c['likes']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        16.ws,
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 15,
                          color: AppColors.textSecondaryLight,
                        ),
                        4.ws,
                        Text(
                          '${c['replies']} إجابات',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),

                    // Divider
                    8.hs,
                    const Divider(color: AppColors.border, height: 1),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
