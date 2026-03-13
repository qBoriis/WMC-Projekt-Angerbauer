class HeatmapDay {
  final String date;
  final int minutes;

  HeatmapDay({
    required this.date,
    required this.minutes,
  });

  factory HeatmapDay.fromJson(Map<String, dynamic> json) {
    return HeatmapDay(
      date: json['date'] as String,
      minutes: json['minutes'] as int,
    );
  }
}

class StatsSummary {
  final int totalMinutes;
  final List<HeatmapDay> dayTotals;
  final int currentStreak;
  final int bestStreak;

  StatsSummary({
    required this.totalMinutes,
    required this.dayTotals,
    required this.currentStreak,
    required this.bestStreak,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> json) {
    final streaks = json['streaks'] as Map<String, dynamic>;

    return StatsSummary(
      totalMinutes: json['totalMinutes'] as int,
      dayTotals: (json['dayTotals'] as List)
          .map((e) => HeatmapDay.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentStreak: streaks['current'] as int,
      bestStreak: streaks['best'] as int,
    );
  }
}