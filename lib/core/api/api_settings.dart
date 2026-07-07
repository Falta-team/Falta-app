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

  // ── Courses ─────────────────────────────────────────────────────────────────
  static const String courses        = '$baseUrl/courses';
  static String courseById(String id)      => '$courses/$id';
  static String coursesBySubject(String s) => '$courses/subject/$s';
  static String enrollCourse(String id)    => '$courses/$id/enroll';
  static String courseVideos(String id)    => '$courses/$id/videos';
  static String courseProgress(String id)  => '$courses/$id/progress';

  // ── Instructors ─────────────────────────────────────────────────────────────
  static const String instructors    = '$baseUrl/instructors';
  static String instructorById(String id)  => '$instructors/$id';

  // ── Exams ───────────────────────────────────────────────────────────────────
  static const String exams          = '$baseUrl/exams';
  static String startExam(String id)       => '$exams/$id/start';
  static String submitExam(String id)      => '$exams/$id/submit';
  static const String examHistory          = '$baseUrl/exams/attempts/history';

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
  static const String activateCard   = '$baseUrl/subscriptions/activate';
  static const String subscriptionStatus  = '$baseUrl/subscriptions/status';

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