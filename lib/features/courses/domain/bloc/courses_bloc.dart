import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:falta_app/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:falta_app/features/courses/domain/bloc/courses_event.dart';
import 'package:falta_app/features/courses/domain/bloc/courses_state.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:falta_app/features/courses/domain/usecases/get_courses.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final GetCourses _getCourses;
  final GetCourseDetails _getCourseDetails;
  final EnrollCourse _enrollCourse;

  // Same SharedPreferences key AuthBloc saves the access token under.
  static const String _keyAccessToken = 'access_token';

  CoursesBloc({CoursesRepository? repository})
      : _getCourses = GetCourses(repository ?? const CoursesRepositoryImpl()),
        _getCourseDetails =
        GetCourseDetails(repository ?? const CoursesRepositoryImpl()),
        _enrollCourse =
        EnrollCourse(repository ?? const CoursesRepositoryImpl()),
        super(const CoursesInitial()) {
    on<FetchCoursesRequested>(_onFetchCourses);
    on<FetchCourseDetailsRequested>(_onFetchCourseDetails);
    on<EnrollCourseRequested>(_onEnrollCourse);
  }

  // ── Fetch all / by-subject ──────────────────────────────────────────────
  Future<void> _onFetchCourses(
      FetchCoursesRequested event, Emitter<CoursesState> emit) async {
    emit(const CoursesLoading());
    try {
      final courses = await _getCourses(subject: event.subject);
      emit(CoursesFetchSuccess(courses));
    } catch (e) {
      emit(CoursesFailure(e.toString()));
    }
  }

  // ── Fetch course details ────────────────────────────────────────────────
  Future<void> _onFetchCourseDetails(
      FetchCourseDetailsRequested event, Emitter<CoursesState> emit) async {
    emit(const CoursesLoading());
    try {
      final course = await _getCourseDetails(event.courseId);
      emit(CourseDetailsFetchSuccess(course));
    } catch (e) {
      emit(CoursesFailure(e.toString()));
    }
  }

  // ── Enroll ───────────────────────────────────────────────────────────────
  Future<void> _onEnrollCourse(
      EnrollCourseRequested event, Emitter<CoursesState> emit) async {
    emit(const CoursesLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyAccessToken);

      if (token == null || token.isEmpty) {
        emit(const CoursesFailure('يجب تسجيل الدخول أولاً'));
        return;
      }

      await _enrollCourse(id: event.courseId, token: token);
      emit(EnrollSuccess(event.courseId));
    } catch (e) {
      emit(CoursesFailure(e.toString()));
    }
  }
}




