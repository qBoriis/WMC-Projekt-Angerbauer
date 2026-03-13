import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'services/api_service.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(ApiService())..init(),
      child: const FocusFlowApp(),
    ),
  );
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A67F5),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F6FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF020617),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C93FF),
        secondary: Color(0xFF1E293B),
        surface: Color(0xFF0F172A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF020617),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  ThemeData _focusTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF03111A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00C896),
        secondary: Color(0xFF1E293B),
        surface: Color(0xFF0F172A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF03111A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  ThemeData _oceanTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF0F9FF),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0EA5E9),
        secondary: Color(0xFFBAE6FD),
        surface: Color(0xFFF0F9FF),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0F9FF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  ThemeData _sunsetTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFF7ED),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFF97316),
        secondary: Color(0xFFFED7AA),
        surface: Color(0xFFFFF7ED),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF7ED),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  ThemeData _currentTheme(String theme) {
    switch (theme) {
      case 'dark':
        return _darkTheme();
      case 'focus':
        return _focusTheme();
      case 'ocean':
        return _oceanTheme();
      case 'sunset':
        return _sunsetTheme();
      default:
        return _lightTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Flow',
      theme: _currentTheme(app.settings.theme),
      home: const AppShell(),
    );
  }
}