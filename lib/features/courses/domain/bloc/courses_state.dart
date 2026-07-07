
import 'package:equatable/equatable.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

// ── Initial / Loading ─────────────────────────────────────────────────────────
class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

// ── Fetch Courses ──────────────────────────────────────────────────────────────
class CoursesFetchSuccess extends CoursesState {
  final List<CoursesEntity> courses;

  const CoursesFetchSuccess(this.courses);

  @override
  List<Object?> get props => [courses];
}

// ── Fetch Course Details ─────────────────────────────────────────────────────
class CourseDetailsFetchSuccess extends CoursesState {
  final CoursesEntity course;

  const CourseDetailsFetchSuccess(this.course);

  @override
  List<Object?> get props => [course];
}

// ── Enroll ─────────────────────────────────────────────────────────────────────
class EnrollSuccess extends CoursesState {
  final String courseId;

  const EnrollSuccess(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

// ── Failure ────────────────────────────────────────────────────────────────────
class CoursesFailure extends CoursesState {
  final String message;

  const CoursesFailure(this.message);

  @override
  List<Object?> get props => [message];

}
