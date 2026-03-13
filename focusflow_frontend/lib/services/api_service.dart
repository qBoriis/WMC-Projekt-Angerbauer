import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/focus_session.dart';
import '../models/stats_summary.dart';

class ApiService {
  // Für Windows lokal / Web:
  static const String baseUrl = 'http://localhost:3000';

  // Für Android Emulator stattdessen:
  //static const String baseUrl = 'http://10.0.2.2:3000';

  Future<bool> health() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));
    return response.statusCode == 200;
  }

  Future<List<FocusSession>> getSessions({int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sessions?limit=$limit'),
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Laden der Sessions');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => FocusSession.fromJson(e)).toList();
  }

  Future<void> createSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMin,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'startedAt': startedAt.toUtc().toIso8601String(),
        'endedAt': endedAt.toUtc().toIso8601String(),
        'durationMin': durationMin,
        'note': note,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Fehler beim Speichern der Session');
    }
  }

  Future<void> deleteSession(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/sessions/$id'));

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Löschen der Session');
    }
  }

  Future<Map<String, String>> getSettings() async {
    final response = await http.get(Uri.parse('$baseUrl/settings'));

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Laden der Settings');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<void> putSetting(String key, String value) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings/$key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'value': value}),
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Speichern eines Settings');
    }
  }

  Future<StatsSummary> getSummary({String? from, String? to}) async {
    final uri = Uri.parse('$baseUrl/stats/summary').replace(
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Laden der Statistik');
    }

    return StatsSummary.fromJson(jsonDecode(response.body));
  }
}