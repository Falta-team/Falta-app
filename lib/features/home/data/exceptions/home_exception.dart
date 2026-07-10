class HomeApiException implements Exception {
  final String message;
  final int?   statusCode;

  const HomeApiException(this.message, {this.statusCode});

  @override
  String toString() => 'HomeApiException: $message (code: $statusCode)';
}

