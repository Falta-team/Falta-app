
import 'package:equatable/equatable.dart';

abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

// ── Fetch Courses (all, or filtered by subject) ─────────────────────────────
class FetchCoursesRequested extends CoursesEvent {
  final String? subject;

  const FetchCoursesRequested({this.subject});

  @override
  List<Object?> get props => [subject];
}

// ── Fetch Course Details ─────────────────────────────────────────────────────
class FetchCourseDetailsRequested extends CoursesEvent {
  final String courseId;

  const FetchCourseDetailsRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

// ── Enroll Course ─────────────────────────────────────────────────────────────
class EnrollCourseRequested extends CoursesEvent {
  final String courseId;

  const EnrollCourseRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}
