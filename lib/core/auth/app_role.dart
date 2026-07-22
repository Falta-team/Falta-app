/// Matches API values: `student`, `instructor`, `admin`.
enum AppRole {
  student,
  instructor,
  admin;

  bool get isInstructor => this == AppRole.instructor;
  bool get isAdmin => this == AppRole.admin;
  bool get isInstructorSide =>
      this == AppRole.instructor || this == AppRole.admin;

  static AppRole fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'instructor':
      case 'teacher':
        return AppRole.instructor;
      case 'admin':
      case 'administrator':
        return AppRole.admin;
      default:
        return AppRole.student;
    }
  }

  String get apiValue {
    switch (this) {
      case AppRole.student:
        return 'student';
      case AppRole.instructor:
        return 'instructor';
      case AppRole.admin:
        return 'admin';
    }
  }

  String get labelAr {
    switch (this) {
      case AppRole.student:
        return 'طالب';
      case AppRole.instructor:
        return 'معلم';
      case AppRole.admin:
        return 'أدمن';
    }
  }
}
