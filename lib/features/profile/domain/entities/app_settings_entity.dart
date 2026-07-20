/// Exam questions difficulty level, selectable from the settings screen.
enum ExamDifficulty {
  easy('سهل', 30),
  medium('متوسط', 60),
  hard('صعب', 90);

  const ExamDifficulty(this.label, this.secondsPerQuestion);

  final String label;
  final int secondsPerQuestion;

  String get description => 'كل تمرين لمدة $secondsPerQuestion ثانية';
}

/// App-level preferences shown in the settings screen.
class AppSettingsEntity {
  const AppSettingsEntity({
    required this.difficulty,
    required this.notificationsEnabled,
    required this.soundEnabled,
  });

  final ExamDifficulty difficulty;
  final bool notificationsEnabled;
  final bool soundEnabled;

  AppSettingsEntity copyWith({
    ExamDifficulty? difficulty,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return AppSettingsEntity(
      difficulty: difficulty ?? this.difficulty,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
