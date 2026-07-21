import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:falta_app/features/exams/domain/entities/exam_attempt_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';
import 'package:falta_app/features/exams/domain/usecases/get_exams.dart';
import 'package:falta_app/features/exams/domain/usecases/start_exam.dart';
import 'package:falta_app/features/exams/domain/usecases/submit_exam.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ── Repository ────────────────────────────────────────────────────────────
final examsRepositoryProvider = Provider<ExamsRepository>(
      (ref) => const ExamsRepositoryImpl(),
);

/// ── Get exams catalog, optionally filtered by subject ───────────────────
///
/// `exam_units_screen.dart` watches `examsBySubjectProvider(subject)` to
/// list the exams available for the chosen subject (`GET /exams`).
final examsBySubjectProvider = AsyncNotifierProvider.family<
    ExamsBySubjectNotifier, List<ExamsEntity>, String>(
  ExamsBySubjectNotifier.new,
);

class ExamsBySubjectNotifier extends AsyncNotifier<List<ExamsEntity>> {
  ExamsBySubjectNotifier(this.subject);

  final String subject;

  @override
  Future<List<ExamsEntity>> build() {
    return GetExams(ref.read(examsRepositoryProvider))(subject: subject);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => GetExams(ref.read(examsRepositoryProvider))(subject: subject),
    );
  }
}

/// ── Start an exam attempt ────────────────────────────────────────────────
///
/// `exam_session_screen.dart` watches `examAttemptProvider(examId)` to
/// fetch the attempt id + question set (`POST /exams/{examId}/start`,
/// requires a Bearer token).
///
/// `.autoDispose` matters here: without it, this provider stays cached by
/// examId for the app's lifetime, so retaking the same exam would reuse
/// the previous (already-submitted) attemptId and fail on submit.
/// autoDispose drops the cached attempt once the session screen stops
/// watching it (on pop), so opening the exam again always triggers a
/// fresh `POST /start` — no manual `ref.invalidate()` needed.
final examAttemptProvider = AsyncNotifierProvider.autoDispose.family<
    ExamAttemptNotifier, ExamAttemptEntity, String>(
  ExamAttemptNotifier.new,
);

class ExamAttemptNotifier extends AsyncNotifier<ExamAttemptEntity> {
  ExamAttemptNotifier(this.examId);

  final String examId;

  @override
  Future<ExamAttemptEntity> build() async {
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) {
      throw const ExamsApiException('يجب تسجيل الدخول أولاً');
    }
    return StartExam(ref.read(examsRepositoryProvider))(
      examId: examId,
      token: token,
    );
  }
}

/// ── Submit an exam attempt ───────────────────────────────────────────────
///
/// `exam_session_screen.dart` calls
/// `ref.read(examSubmitProvider(examId).notifier).submit(...)` from the
/// "إنهاء" button, then watches the same provider for the graded
/// [ExamResultEntity] (`POST /exams/{examId}/submit`).
///
/// `.autoDispose` for the same reason as [examAttemptProvider] — no stale
/// "already submitted" result left over from a previous attempt.
final examSubmitProvider = AsyncNotifierProvider.autoDispose
    .family<ExamSubmitNotifier, ExamResultEntity?, String>(
  ExamSubmitNotifier.new,
);

class ExamSubmitNotifier extends AsyncNotifier<ExamResultEntity?> {
  ExamSubmitNotifier(this.examId);

  final String examId;

  @override
  Future<ExamResultEntity?> build() async => null;

  Future<ExamResultEntity> submit({
    required String attemptId,
    required int timeTakenSeconds,
    required List<ExamQuestionEntity> answeredQuestions,
  }) async {
    state = const AsyncLoading();
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) {
      final error = const ExamsApiException('يجب تسجيل الدخول أولاً');
      state = AsyncError(error, StackTrace.current);
      throw error;
    }

    try {
      final result = await SubmitExam(ref.read(examsRepositoryProvider))(
        examId: examId,
        attemptId: attemptId,
        timeTakenSeconds: timeTakenSeconds,
        answeredQuestions: answeredQuestions,
        token: token,
      );
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}