class FocusSession {
  final int id;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMin;
  final String? note;
  final DateTime createdAt;

  FocusSession({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.durationMin,
    required this.note,
    required this.createdAt,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationMin: json['durationMin'] as int,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}