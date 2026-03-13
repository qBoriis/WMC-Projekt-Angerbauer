import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);
    
    final todayMinutes = app.stats.dayTotals.isNotEmpty 
        ? app.stats.dayTotals.last.minutes 
        : 0;
    final goalMinutes = app.settings.dailyGoalMinutes;
    final progress = goalMinutes > 0 ? (todayMinutes / goalMinutes).clamp(0.0, 1.0) : 0.0;
    final isGoalReached = todayMinutes >= goalMinutes;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
          children: [
            const SizedBox(height: 4),
            Text(
              'Tagesziel',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dein Focus-Ziel für heute.',
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            
            Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(
                          isGoalReached 
                              ? const Color(0xFF40C463)
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isGoalReached) ...[
                          const Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Color(0xFF40C463),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          '${todayMinutes}',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'von $goalMinutes Min',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            if (isGoalReached)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF40C463).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF40C463).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Color(0xFF40C463),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ziel erreicht!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Super gemacht! Du hast dein Tagesziel erreicht.',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildGoalSelector(context, app, goalMinutes),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector(BuildContext context, AppProvider app, int currentGoal) {
    final theme = Theme.of(context);
    final presets = [30, 60, 90, 120, 180, 240];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ziel ändern',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: presets.map((minutes) {
            final isSelected = minutes == currentGoal;
            return GestureDetector(
              onTap: () => app.setDailyGoalMinutes(minutes),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${minutes} Min',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
