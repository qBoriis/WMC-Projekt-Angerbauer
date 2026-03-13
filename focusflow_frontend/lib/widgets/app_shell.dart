import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/progress_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sessions_screen.dart';
import '../screens/timer_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = Theme.of(context);

    final pages = const [
      TimerScreen(),
      ProgressScreen(),
      SessionsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: pages[app.currentTab],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              context,
              icon: Icons.timer_outlined,
              activeIcon: Icons.timer,
              label: 'Timer',
              selected: app.currentTab == 0,
              onTap: () => context.read<AppProvider>().setTab(0),
            ),
            _navItem(
              context,
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              label: 'Statistik',
              selected: app.currentTab == 1,
              onTap: () {
                if (app.timerRunning) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bitte konzentriere dich! ${app.settings.focusMinutes} Minuten Fokus.'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                  return;
                }
                context.read<AppProvider>().setTab(1);
              },
            ),
            _navItem(
              context,
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              label: 'Sessions',
              selected: app.currentTab == 2,
              onTap: () {
                if (app.timerRunning) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bitte konzentriere dich! ${app.settings.focusMinutes} Minuten Fokus.'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                  return;
                }
                context.read<AppProvider>().setTab(2);
              },
            ),
            _navItem(
              context,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'Einstellungen',
              selected: app.currentTab == 3,
              onTap: () {
                if (app.timerRunning) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bitte konzentriere dich! ${app.settings.focusMinutes} Minuten Fokus.'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                  return;
                }
                context.read<AppProvider>().setTab(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 74,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? theme.colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                selected ? activeIcon : icon,
                size: 24,
                color: selected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}