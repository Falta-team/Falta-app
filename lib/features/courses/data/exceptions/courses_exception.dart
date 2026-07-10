class CoursesApiException implements Exception {
  final String message;
  final int?   statusCode;

  const CoursesApiException(this.message, {this.statusCode});

  @override
  String toString() => 'CoursesApiException: $message (code: $statusCode)';
}
