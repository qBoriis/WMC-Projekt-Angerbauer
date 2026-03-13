import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/heatmap_widget.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final stats = app.stats;
    final theme = Theme.of(context);

    final todayMinutes = stats.dayTotals.isNotEmpty ? stats.dayTotals.last.minutes : 0;
    final totalHours = stats.totalMinutes / 60.0;
    final weekMinutes = _calculateWeekMinutes(stats.dayTotals);
    final monthMinutes = stats.totalMinutes;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: app.refreshAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
            children: [
              const SizedBox(height: 4),
              Text(
                'Statistik',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deine Lernfortschritte im Überblick.',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              _buildStreakCard(
                context: context,
                currentStreak: stats.currentStreak,
                bestStreak: stats.bestStreak,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      context: context,
                      title: 'HEUTE',
                      value: '${todayMinutes}m',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMiniStatCard(
                      context: context,
                      title: 'WOCHE',
                      value: '${weekMinutes}m',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildMiniStatCard(
                      context: context,
                      title: 'MONAT',
                      value: '${monthMinutes}m',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMiniStatCard(
                      context: context,
                      title: 'GESAMT',
                      value: '${totalHours.toStringAsFixed(1)}h',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktivität (Letzte 10 Wochen)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 18),
                      HeatmapWidget(data: stats.dayTotals),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateWeekMinutes(List<dynamic> dayTotals) {
    final today = DateTime.now();
    int total = 0;

    for (final item in dayTotals) {
      final date = DateTime.tryParse(item.date);
      if (date == null) continue;

      final diff = today.difference(date).inDays;
      if (diff >= 0 && diff < 7) {
        total += (item.minutes as int);
      }
    }

    return total;
  }

  Widget _buildStreakCard({
    required BuildContext context,
    required int currentStreak,
    required int bestStreak,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStreakInfo(
              context: context,
              title: 'Aktueller Streak',
              value: '$currentStreak Tage',
              emoji: '🔥',
              alignEnd: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStreakInfo(
              context: context,
              title: 'Bester Streak',
              value: '$bestStreak Tage',
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakInfo({
    required BuildContext context,
    required String title,
    required String value,
    String? emoji,
    required bool alignEnd,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onPrimary.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            if (emoji != null) ...[
              const SizedBox(width: 6),
              Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}