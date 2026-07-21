/// A single ready-made exam as returned by `GET /exams`.
///
/// Matches the real API shape used when an admin creates an exam
/// (`POST /exams`): title, subject, year, academicTrack,
/// totalQuestions, timeLimit (in minutes) and difficultyLevel.
class ExamsEntity {
  const ExamsEntity({
    required this.id,
    required this.title,
    required this.subject,
    required this.year,
    required this.academicTrack,
    required this.totalQuestions,
    required this.timeLimit,
    required this.difficultyLevel,
  });

  final String id;
  final String title;
  final String subject;
  final String year;
  final String academicTrack;
  final int totalQuestions;

  /// Exam duration in **minutes**, as returned by the API.
  final int timeLimit;
  final String difficultyLevel;
}
