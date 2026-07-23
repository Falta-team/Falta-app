import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';

/// Parses `POST /exams/{examId}/submit`.
///
/// Confirmed real shape (from a live device log):
/// ```
/// {
///   attemptId, examId, score, totalQuestions, correctAnswers,
///   incorrectAnswers, unanswered, percentage, performanceBadge,
///   questions: [
///     { id, questionText, optionA, optionB, optionC, optionD,
///       difficultyLevel, topicTag, correctAnswer, explanation,
///       userAnswer, isCorrect }
///   ],
///   submittedAt
/// }
/// ```
/// Each entry in `questions` is already fully self-contained (it repeats
/// the question text/options AND reveals `correctAnswer` + the student's
/// own `userAnswer`), so this is parsed directly instead of trying to
/// merge it into the pre-submit question list. A `results`-array shape
/// is kept as a legacy fallback in case a different endpoint ever
/// returns that instead.
class ExamResultModel {
  const ExamResultModel._();

  static ExamResultEntity fromJson(
      Map<String, dynamic> json, {
        required List<ExamQuestionEntity> answeredQuestions,
      }) {
    final attempt = json['attempt'] is Map<String, dynamic>
        ? json['attempt'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final questionsJson = json['questions'] as List<dynamic>? ?? const [];

    final mergedQuestions = questionsJson.isNotEmpty
        ? questionsJson
        .map((e) => _questionFromGraded(e as Map<String, dynamic>))
        .toList()
        : _mergeFromResultsArray(json, answeredQuestions);

    final total = (json['totalQuestions'] as num?)?.toInt() ??
        (json['total'] as num?)?.toInt() ??
        (attempt['totalQuestions'] as num?)?.toInt() ??
        mergedQuestions.length;
    final score = (json['score'] as num?)?.toInt() ??
        (json['correctAnswers'] as num?)?.toInt() ??
        (attempt['score'] as num?)?.toInt() ??
        mergedQuestions.where((q) => q.isCorrect).length;
    final message = json['message'] as String? ??
        json['performanceBadge'] as String? ??
        attempt['completionStatus']?.toString() ??
        _defaultMessage(score, total);

    return ExamResultEntity(
      score: score,
      total: total,
      message: message,
      questions: mergedQuestions,
      attemptId: json['attemptId']?.toString() ??
          attempt['id']?.toString() ??
          attempt['attemptId']?.toString(),
    );
  }

  /// Builds a fully-graded [ExamQuestionEntity] straight from one entry
  /// of the submit response's `questions` array (letter-option shape,
  /// same as the start-exam response, but now with `correctAnswer` and
  /// `userAnswer` revealed).
  static ExamQuestionEntity _questionFromGraded(Map<String, dynamic> q) {
    final correctAnswer = q['correctAnswer']?.toString();
    final userAnswer = q['userAnswer']?.toString();

    const letters = ['a', 'b', 'c', 'd'];
    const keys = ['optionA', 'optionB', 'optionC', 'optionD'];
    final options = <ExamOptionEntity>[
      for (var i = 0; i < letters.length; i++)
        if (q[keys[i]] != null)
          ExamOptionEntity(
            id: letters[i],
            text: q[keys[i]] as String? ?? '',
            isCorrect: letters[i] == correctAnswer,
          ),
    ];

    return ExamQuestionEntity(
      id: q['id']?.toString() ?? '',
      text: q['questionText'] as String? ?? q['text'] as String? ?? '',
      selectedOptionId: userAnswer,
      options: options,
    );
  }

  /// Legacy fallback: a `results: [{ questionId, correctAnswer }]` shape
  /// merged into the questions the student already answered client-side.
  static List<ExamQuestionEntity> _mergeFromResultsArray(
      Map<String, dynamic> json,
      List<ExamQuestionEntity> answeredQuestions,
      ) {
    final resultsJson = json['results'] as List<dynamic>? ?? const [];
    if (resultsJson.isEmpty) return answeredQuestions;

    final correctAnswerByQuestionId = <String, String>{};
    for (final raw in resultsJson) {
      if (raw is! Map<String, dynamic>) continue;
      final questionId =
          raw['questionId']?.toString() ?? raw['id']?.toString();
      final correctAnswer = raw['correctAnswer']?.toString();
      if (questionId != null && correctAnswer != null) {
        correctAnswerByQuestionId[questionId] = correctAnswer;
      }
    }

    return answeredQuestions.map((q) {
      final correctAnswer = correctAnswerByQuestionId[q.id];
      if (correctAnswer == null) return q;
      return ExamQuestionEntity(
        id: q.id,
        text: q.text,
        selectedOptionId: q.selectedOptionId,
        options: q.options
            .map(
              (o) => ExamOptionEntity(
            id: o.id,
            text: o.text,
            isCorrect: o.id == correctAnswer,
          ),
        )
            .toList(),
      );
    }).toList();
  }

  static String _defaultMessage(int score, int total) {
    final ratio = total == 0 ? 0.0 : score / total;
    if (ratio >= 0.7) return 'أحسنت';
    if (ratio >= 0.4) return 'جيد';
    return 'حاول مرة أخرى';
  }
}