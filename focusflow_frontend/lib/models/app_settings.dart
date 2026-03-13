class AppSettings {
  final String theme;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final bool soundEnabled;

  const AppSettings({
    required this.theme,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.soundEnabled,
  });

  AppSettings copyWith({
    String? theme,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    bool? soundEnabled,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  static const defaults = AppSettings(
    theme: 'light',
    focusMinutes: 25,
    shortBreakMinutes: 5,
    longBreakMinutes: 25,
    soundEnabled: true,
  );
}