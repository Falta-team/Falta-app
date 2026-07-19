import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/entities/video_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:falta_app/features/courses/domain/usecases/add_video_comment.dart';
import 'package:falta_app/features/courses/domain/usecases/enroll_course.dart';
import 'package:falta_app/features/courses/domain/usecases/get_course_details.dart';
import 'package:falta_app/features/courses/domain/usecases/get_course_videos.dart';
import 'package:falta_app/features/courses/domain/usecases/get_courses.dart';
import 'package:falta_app/features/courses/domain/usecases/get_video_comments.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ── Repository ────────────────────────────────────────────────────────────
final coursesRepositoryProvider = Provider<CoursesRepository>(
      (ref) => const CoursesRepositoryImpl(),
);

/// ── Get all courses (optionally filtered by subject) ────────────────────────
///
/// Replaces `FetchCoursesRequested` / `CoursesFetchSuccess` from the old
/// [CoursesBloc]. Call `ref.watch(coursesListProvider)` for the full
/// catalog, and `ref.read(coursesListProvider.notifier).refresh()` to
/// pull-to-refresh.
final coursesListProvider =
AsyncNotifierProvider<CoursesListNotifier, List<CoursesEntity>>(
  CoursesListNotifier.new,
);

class CoursesListNotifier extends AsyncNotifier<List<CoursesEntity>> {
  @override
  Future<List<CoursesEntity>> build() {
    return GetCourses(ref.read(coursesRepositoryProvider))();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => GetCourses(ref.read(coursesRepositoryProvider))(),
    );
  }
}

/// ── Get courses filtered by subject ──────────────────────────────────────
///
/// Used by `instructors_screen.dart`, which lists every course/instructor
/// under a chosen subject (`GET /courses/subject/{subject}`).
///
/// Riverpod 3.x removed `FamilyAsyncNotifier` — family notifiers now take
/// their argument through the constructor instead of a `build(arg)`
/// parameter (see https://riverpod.dev/docs/3.0_migration).
final coursesBySubjectProvider = AsyncNotifierProvider.family<
    CoursesBySubjectNotifier, List<CoursesEntity>, String>(
  CoursesBySubjectNotifier.new,
);

class CoursesBySubjectNotifier extends AsyncNotifier<List<CoursesEntity>> {
  CoursesBySubjectNotifier(this.subject);

  final String subject;

  @override
  Future<List<CoursesEntity>> build() {
    return GetCourses(ref.read(coursesRepositoryProvider))(subject: subject);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => GetCourses(ref.read(coursesRepositoryProvider))(subject: subject),
    );
  }
}

/// ── Get single course details ────────────────────────────────────────────
///
/// Replaces `FetchCourseDetailsRequested` / `CourseDetailsFetchSuccess`.
/// `course_detail_screen.dart` watches
/// `courseDetailsProvider(courseId)` instead of receiving a mock `Map`.
final courseDetailsProvider =
AsyncNotifierProvider.family<CourseDetailsNotifier, CoursesEntity, String>(
  CourseDetailsNotifier.new,
);

class CourseDetailsNotifier extends AsyncNotifier<CoursesEntity> {
  CourseDetailsNotifier(this.courseId);

  final String courseId;


  @override
  Future<CoursesEntity> build() {
    print('title2: $courseId');

    return GetCourseDetails(ref.read(coursesRepositoryProvider))(courseId);

  }
}

/// ── Get a course's videos ─────────────────────────────────────────────────
///
/// `course_detail_screen.dart` watches `courseVideosProvider(courseId)`
/// to show the real "الفيديوهات" tab (`GET /courses/{id}/videos`,
/// requires a Bearer token).
final courseVideosProvider =
AsyncNotifierProvider.family<CourseVideosNotifier, List<VideoEntity>, String>(
  CourseVideosNotifier.new,
);

class CourseVideosNotifier extends AsyncNotifier<List<VideoEntity>> {
  CourseVideosNotifier(this.courseId);

  final String courseId;

  @override
  Future<List<VideoEntity>> build() async {
    final token = SharedPrefController().accessToken;

    if (token.isEmpty) {
      throw const CoursesApiException('يجب تسجيل الدخول أولاً');
    }

    return GetCourseVideos(ref.read(coursesRepositoryProvider))(
      courseId,
      token,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = SharedPrefController().accessToken;
      if (token.isEmpty) {
        throw const CoursesApiException('يجب تسجيل الدخول أولاً');
      }
      return GetCourseVideos(ref.read(coursesRepositoryProvider))(
        courseId,
        token,
      );
    });
  }
}

/// ── Enroll in a course ───────────────────────────────────────────────────
///
/// Replaces `EnrollCourseRequested` / `EnrollSuccess`. `build()` is a
/// no-op — call `ref.read(courseEnrollmentProvider(courseId).notifier)
/// .enroll()` from a button handler, then watch the provider for
/// loading/error/success like any other [AsyncValue].
final courseEnrollmentProvider =
AsyncNotifierProvider.family<CourseEnrollmentNotifier, void, String>(
  CourseEnrollmentNotifier.new,
);

class CourseEnrollmentNotifier extends AsyncNotifier<void> {
  CourseEnrollmentNotifier(this.courseId);

  final String courseId;

  @override
  Future<void> build() async {
    // No request on build — enrollment only happens when `enroll()` is
    // called explicitly (e.g. from a button's onPressed).
  }

  Future<void> enroll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = SharedPrefController().accessToken;

      if (token.isEmpty) {
        throw const CoursesApiException('يجب تسجيل الدخول أولاً');
      }

      await EnrollCourse(ref.read(coursesRepositoryProvider))(
        id: courseId,
        token: token,
      );
    });
  }
}

/// ── Get / post a video's comments ────────────────────────────────────────
///
/// `course_detail_screen.dart` watches `videoCommentsProvider(videoId)` for
/// the real "التعليقات" tab (`GET /videos/{id}/comments`), and calls
/// `ref.read(videoCommentsProvider(videoId).notifier).addComment(text)` to
/// post a new one (`POST /videos/{id}/comments`) — the list updates
/// immediately on success rather than waiting for a manual refresh.
final videoCommentsProvider =
AsyncNotifierProvider.family<VideoCommentsNotifier, List<CommentEntity>, String>(
  VideoCommentsNotifier.new,
);

class VideoCommentsNotifier extends AsyncNotifier<List<CommentEntity>> {
  VideoCommentsNotifier(this.videoId);

  final String videoId;

  @override
  Future<List<CommentEntity>> build() {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) {
      throw const CoursesApiException('يجب تسجيل الدخول أولاً');
    }
    return GetVideoComments(ref.read(coursesRepositoryProvider))(
      videoId,
      token,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = SharedPrefController().accessToken;
      if (token.isEmpty) {
        throw const CoursesApiException('يجب تسجيل الدخول أولاً');
      }
      return GetVideoComments(ref.read(coursesRepositoryProvider))(
        videoId,
        token,
      );
    });
  }

  /// Posts [body] as a new comment and prepends it to the current list on
  /// success, so the UI refreshes immediately without a full re-fetch.
  Future<void> addComment(String body) async {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) {
      throw const CoursesApiException('يجب تسجيل الدخول أولاً');
    }

    final newComment = await AddVideoComment(ref.read(coursesRepositoryProvider))(
      videoId,
      token,
      body,
    );

    final current = state.asData?.value ?? const <CommentEntity>[];
    state = AsyncData([newComment, ...current]);
  }
}