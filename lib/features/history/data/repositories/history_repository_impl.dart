import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/history/data/sources/history_local_data_source.dart';
import 'package:falta_app/features/history/domain/entities/history_entities.dart';
import 'package:falta_app/features/history/domain/repositories/history_repository.dart';
import 'package:http/http.dart' as http;

/// Prefers `GET /exams/attempts/history`, falls back to local mock data.
class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({
    HistoryLocalDataSource? local,
    SharedPrefController? pref,
  })  : _local = local ?? HistoryLocalDataSource(),
        _pref = pref ?? SharedPrefController();

  final HistoryLocalDataSource _local;
  final SharedPrefController _pref;

  @override
  Future<List<HistorySubjectEntity>> getSubjects() async {
    try {
      final attempts = await _fetchAttempts();
      if (attempts.isEmpty) return _local.fetchSubjects();
      final bySubject = <String, _Agg>{};
      for (final a in attempts) {
        final subject = (a['subject'] ?? a['subjectName'] ?? a['examSubject'] ?? 'عام')
            .toString();
        final id = subject.toLowerCase().replaceAll(' ', '_');
        final correct = (a['correctAnswers'] as num?)?.toInt() ??
            (a['score'] as num?)?.toInt() ??
            0;
        final total = (a['totalQuestions'] as num?)?.toInt() ??
            (a['total'] as num?)?.toInt() ??
            0;
        final wrong = (a['incorrectAnswers'] as num?)?.toInt() ??
            (total > correct ? total - correct : 0);
        final agg = bySubject.putIfAbsent(
          id,
          () => _Agg(id: id, name: subject),
        );
        agg.correct += correct;
        agg.wrong += wrong;
      }
      return bySubject.values
          .map(
            (a) => HistorySubjectEntity(
              id: a.id,
              name: a.name,
              image: 'assets/images/exam_year_card.png',
              correctCount: a.correct,
              wrongCount: a.wrong,
            ),
          )
          .toList();
    } catch (_) {
      return _local.fetchSubjects();
    }
  }

  @override
  Future<HistoryRecordEntity> getRecord(String subjectId) async {
    try {
      final attempts = await _fetchAttempts();
      final matched = attempts.where((a) {
        final subject =
            (a['subject'] ?? a['subjectName'] ?? a['examSubject'] ?? '')
                .toString()
                .toLowerCase()
                .replaceAll(' ', '_');
        return subject == subjectId ||
            a['examId']?.toString() == subjectId ||
            a['id']?.toString() == subjectId;
      }).toList();

      if (matched.isEmpty) return _local.fetchRecord(subjectId);

      final questions = <ExamQuestionEntity>[];
      for (final a in matched) {
        final qs = a['questions'] as List<dynamic>? ?? const [];
        for (final raw in qs) {
          if (raw is! Map<String, dynamic>) continue;
          questions.add(_questionFromJson(raw));
        }
      }
      if (questions.isEmpty) return _local.fetchRecord(subjectId);

      final name = matched.first['subject']?.toString() ??
          matched.first['subjectName']?.toString() ??
          subjectId;
      return HistoryRecordEntity(
        subjectId: subjectId,
        subjectName: name,
        questions: questions,
      );
    } catch (_) {
      return _local.fetchRecord(subjectId);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAttempts() async {
    final response = await http.get(
      Uri.parse(ApiSettings.examHistory),
      headers: ApiSettings.authHeaders(_pref.accessToken),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] ?? 'history failed');
    }
    final data = json['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      final list = data['attempts'] as List<dynamic>? ??
          data['history'] as List<dynamic>? ??
          data['items'] as List<dynamic>? ??
          const [];
      return list.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  ExamQuestionEntity _questionFromJson(Map<String, dynamic> q) {
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
    if (options.isEmpty) {
      final opts = q['options'] as List<dynamic>? ?? const [];
      for (final o in opts) {
        if (o is Map<String, dynamic>) {
          options.add(
            ExamOptionEntity(
              id: o['id']?.toString() ?? '',
              text: o['text']?.toString() ?? '',
              isCorrect: o['isCorrect'] == true ||
                  o['id']?.toString() == correctAnswer,
            ),
          );
        }
      }
    }
    return ExamQuestionEntity(
      id: q['id']?.toString() ?? '',
      text: q['questionText'] as String? ?? q['text'] as String? ?? '',
      options: options,
      selectedOptionId: userAnswer,
    );
  }

  @override
  Future<List<double>> getRecentPercentages({int limit = 7}) async {
    try {
      final attempts = await _fetchAttempts();
      if (attempts.isEmpty) return const [];
      final scores = <double>[];
      for (final a in attempts) {
        final pct = (a['percentage'] as num?)?.toDouble();
        if (pct != null) {
          scores.add(pct > 1 ? pct : pct * 100);
          continue;
        }
        final correct = (a['correctAnswers'] as num?)?.toDouble() ??
            (a['score'] as num?)?.toDouble();
        final total = (a['totalQuestions'] as num?)?.toDouble() ??
            (a['total'] as num?)?.toDouble();
        if (correct != null && total != null && total > 0) {
          scores.add((correct / total) * 100);
        }
      }
      if (scores.length <= limit) return scores;
      return scores.sublist(scores.length - limit);
    } catch (_) {
      return const [];
    }
  }
}

class _Agg {
  _Agg({required this.id, required this.name});
  final String id;
  final String name;
  int correct = 0;
  int wrong = 0;
}
