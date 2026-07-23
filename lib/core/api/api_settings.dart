class ApiSettings {
  // ── Base ────────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://falta-api.onrender.com/api/v1';

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String register       = '$baseUrl/auth/register';
  static const String login          = '$baseUrl/auth/login';
  static const String verifyPhone    = '$baseUrl/auth/verify-phone';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword  = '$baseUrl/auth/reset-password';
  static const String refreshToken   = '$baseUrl/auth/refresh-token';
  static const String logout         = '$baseUrl/auth/logout';

  // ── Profile ─────────────────────────────────────────────────────────────────
  static const String profile        = '$baseUrl/users/profile';
  static const String changePassword = '$baseUrl/users/password';
  static const String profilePhoto   = '$baseUrl/users/profile-photo';
  static const String deleteAccount  = '$baseUrl/users/account';

  // ── Courses ─────────────────────────────────────────────────────────────────
  static const String courses        = '$baseUrl/courses';
  static String courseById(String id)      => '$courses/$id';
  static String coursesBySubject(String s) => '$courses/subject/$s';
  static String coursesByInstructor(String instructorId) =>
      '$courses/instructor/$instructorId';
  static String enrollCourse(String id)    => '$courses/$id/enroll';
  static String courseVideos(String id)    => '$courses/$id/videos';
  static String courseProgress(String id)  => '$courses/$id/progress';
  static String courseMaterials(String id) => '$courses/$id/materials';

  /// `GET /courses?search=&subject=&page=&limit=`
  static Uri coursesQuery({
    String? search,
    String? subject,
    int page = 1,
    int limit = 20,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (subject != null && subject.trim().isNotEmpty) 'subject': subject.trim(),
    };
    return Uri.parse(courses).replace(queryParameters: params);
  }

  // ── Videos / Comments ───────────────────────────────────────────────────────
  static const String videos        = '$baseUrl/videos';
  static String videoById(String videoId)     => '$videos/$videoId';
  static String videoStream(String videoId)   => '$videos/$videoId/stream';
  static String recordVideoView(String videoId) => '$videos/$videoId/view';
  static String videoComments(String videoId) => '$videos/$videoId/comments';
  static String videoComment(String videoId, String commentId) =>
      '$videos/$videoId/comments/$commentId';

  // ── Instructors ─────────────────────────────────────────────────────────────
  static const String instructors    = '$baseUrl/instructors';
  static String instructorById(String id)  => '$instructors/$id';
  static String instructorCourses(String id) => '$instructors/$id/courses';

  /// `GET /instructors?search=`
  static Uri instructorsQuery({String? search, int page = 1, int limit = 20}) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    return Uri.parse(instructors).replace(queryParameters: params);
  }

  // ── Exams ───────────────────────────────────────────────────────────────────
  static const String exams          = '$baseUrl/exams';
  static String examById(String id)        => '$exams/$id';
  static String examsBySubject(String s)   => '$exams/subject/$s';
  static String startExam(String id)       => '$exams/$id/start';
  static String submitExam(String id)      => '$exams/$id/submit';
  static String examResult(String examId, String attemptId) =>
      '$exams/$examId/results/$attemptId';
  static String saveExamAnswer(String attemptId) =>
      '$exams/$attemptId/answers';
  static const String examHistory          = '$baseUrl/exams/attempts/history';

  /// `GET /exams?subject=&page=&limit=`
  static Uri examsQuery({
    String? subject,
    int page = 1,
    int limit = 20,
  }) {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (subject != null && subject.trim().isNotEmpty) 'subject': subject.trim(),
    };
    return Uri.parse(exams).replace(queryParameters: params);
  }

  // ── Favorites ───────────────────────────────────────────────────────────────
  static const String favorites      = '$baseUrl/favorites';
  static String removeFavorite(String id)  => '$favorites/$id';

  // ── Notifications ────────────────────────────────────────────────────────────
  static const String notifications  = '$baseUrl/notifications';
  static String markRead(String id)        => '$notifications/$id/read';
  static const String markAllRead          = '$baseUrl/notifications/read-all';
  static String deleteNotification(String id) => '$notifications/$id';

  // ── AI ──────────────────────────────────────────────────────────────────────
  static const String aiAsk          = '$baseUrl/ai/ask';
  static const String aiSessions     = '$baseUrl/ai/sessions';
  static String aiSessionDetail(String id) => '$aiSessions/$id';
  static const String aiAnalyze      = '$baseUrl/ai/analyze-performance';
  static String aiRecommendation(String id) => '$baseUrl/ai/recommendations/$id';

  // ── Subscriptions ────────────────────────────────────────────────────────────
  static const String activateCard        = '$baseUrl/subscriptions/activate';
  static const String subscriptionStatus  = '$baseUrl/subscriptions/status';
  static const String subscriptionHistory = '$baseUrl/subscriptions/history';
  static const String subscriptionPlans   = '$baseUrl/subscriptions/plans';
  static const String createCards         = '$baseUrl/subscriptions/cards';

  // ── AI (instructor) ─────────────────────────────────────────────────────────
  static const String aiGenerateQuestions = '$baseUrl/ai/generate-questions';

  // ── Admin ───────────────────────────────────────────────────────────────────
  static const String adminStats = '$baseUrl/admin/stats';
  static const String adminUsers = '$baseUrl/admin/users';
  static String adminUserRole(String userId) =>
      '$adminUsers/$userId/role';
  static String adminUserSubscription(String userId) =>
      '$adminUsers/$userId/subscription';

  // ── Headers ─────────────────────────────────────────────────────────────────
  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...jsonHeaders,
    'Authorization': 'Bearer $token',
  };

  // ── Status code helpers ──────────────────────────────────────────────────────
  static bool isSuccess(int code) => [200, 201, 202].contains(code);
  static bool isFailure(int code) => [400, 401, 403, 405, 500].contains(code);
}