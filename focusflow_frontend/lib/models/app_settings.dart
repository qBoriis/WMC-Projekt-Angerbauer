class AppSettings {
  final String theme;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int dailyGoalMinutes;

  const AppSettings({
    required this.theme,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.dailyGoalMinutes,
  });

  AppSettings copyWith({
    String? theme,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? dailyGoalMinutes,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    );
  }

  static const defaults = AppSettings(
    theme: 'light',
    focusMinutes: 1,
    shortBreakMinutes: 5,
    longBreakMinutes: 25,
    dailyGoalMinutes: 120,
  );
}