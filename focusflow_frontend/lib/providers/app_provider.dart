import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/focus_session.dart';
import '../models/stats_summary.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService api;

  AppProvider(this.api);

  AppSettings settings = AppSettings.defaults;
  List<FocusSession> sessions = [];
  StatsSummary stats = StatsSummary(totalMinutes: 0, dayTotals: [], currentStreak: 0, bestStreak: 0);
  bool loading = false;

  int currentTab = 0;

  bool timerRunning = false;

  Future<void> init() async {
    await _loadLocalSettings();
    await syncSettingsFromBackend();
    await refreshAll();
  }

  void setTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();

    settings = settings.copyWith(
      theme: prefs.getString('theme') ?? settings.theme,
      focusMinutes: prefs.getInt('focusMinutes') ?? settings.focusMinutes,
      shortBreakMinutes: prefs.getInt('shortBreakMinutes') ?? settings.shortBreakMinutes,
      longBreakMinutes: prefs.getInt('longBreakMinutes') ?? settings.longBreakMinutes,
      soundEnabled: prefs.getBool('soundEnabled') ?? settings.soundEnabled,
    );

    notifyListeners();
  }

  Future<void> _saveLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', settings.theme);
    await prefs.setInt('focusMinutes', settings.focusMinutes);
    await prefs.setInt('shortBreakMinutes', settings.shortBreakMinutes);
    await prefs.setInt('longBreakMinutes', settings.longBreakMinutes);
    await prefs.setBool('soundEnabled', settings.soundEnabled);
  }

  Future<void> syncSettingsFromBackend() async {
    try {
      final remote = await api.getSettings();

      settings = settings.copyWith(
        theme: remote['theme'] ?? settings.theme,
        focusMinutes: int.tryParse(remote['focusMin'] ?? '') ?? settings.focusMinutes,
        shortBreakMinutes: int.tryParse(remote['shortBreakMin'] ?? '') ?? settings.shortBreakMinutes,
        longBreakMinutes: int.tryParse(remote['longBreakMin'] ?? '') ?? settings.longBreakMinutes,
        soundEnabled: (remote['soundEnabled'] ?? 'true') == 'true',
      );

      await _saveLocalSettings();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setTheme(String theme) async {
    settings = settings.copyWith(theme: theme);
    await _saveLocalSettings();
    notifyListeners();
    try {
      await api.putSetting('theme', theme);
    } catch (_) {}
  }

  Future<void> setFocusMinutes(int value) async {
    settings = settings.copyWith(focusMinutes: value);
    await _saveLocalSettings();
    notifyListeners();
    try {
      await api.putSetting('focusMin', value.toString());
    } catch (_) {}
  }

  Future<void> setShortBreakMinutes(int value) async {
    settings = settings.copyWith(shortBreakMinutes: value);
    await _saveLocalSettings();
    notifyListeners();
    try {
      await api.putSetting('shortBreakMin', value.toString());
    } catch (_) {}
  }

  Future<void> setLongBreakMinutes(int value) async {
    settings = settings.copyWith(longBreakMinutes: value);
    await _saveLocalSettings();
    notifyListeners();
    try {
      await api.putSetting('longBreakMin', value.toString());
    } catch (_) {}
  }

  Future<void> toggleSound(bool value) async {
    settings = settings.copyWith(soundEnabled: value);
    await _saveLocalSettings();
    notifyListeners();
    try {
      await api.putSetting('soundEnabled', value.toString());
    } catch (_) {}
  }

  Future<void> refreshAll() async {
    loading = true;
    notifyListeners();

    try {
      sessions = await api.getSessions(limit: 100);
      final newStats = await _loadCurrentMonthSummary();
      stats = newStats;
    } catch (e) {
      // behalte bestehende stats - kein fallback zu leeren
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStatsOnly() async {
    try {
      stats = await _loadCurrentMonthSummary();
      notifyListeners();
    } catch (_) {}
  }

  Future<StatsSummary> _loadCurrentMonthSummary() async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0);

    String format(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return api.getSummary(from: format(from), to: format(to));
  }

  Future<void> addSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMin,
    String? note,
  }) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await api.createSession(
          startedAt: startedAt,
          endedAt: endedAt,
          durationMin: durationMin,
          note: note,
        );
        await refreshAll();
        return;
      } catch (e) {
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }
  }

  Future<void> removeSession(int id) async {
    await api.deleteSession(id);
    await refreshAll();
  }
}