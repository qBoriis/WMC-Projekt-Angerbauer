import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/timer_display.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                'Focus',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 38),
              TimerDisplay(
                focusMinutes: app.settings.focusMinutes,
                shortBreakMinutes: app.settings.shortBreakMinutes,
                longBreakMinutes: app.settings.longBreakMinutes,
                onComplete: (duration, mode) async {
                  if (mode == 'focus') {
                    await app.addSession(
                      startedAt: DateTime.now().toUtc().subtract(Duration(minutes: duration)),
                      endedAt: DateTime.now().toUtc(),
                      durationMin: duration,
                      note: 'Focus Session',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}