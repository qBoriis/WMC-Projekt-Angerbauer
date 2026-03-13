import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final settings = app.settings;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
          children: [
            const SizedBox(height: 4),
            Text(
              'Einstellungen',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Passe dein Focus-Erlebnis an.',
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            _sectionCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erscheinungsbild',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wähle das Theme, das zu dir passt.',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _themeTile(
                        context: context,
                        label: 'Light',
                        icon: Icons.wb_sunny_outlined,
                        selected: settings.theme == 'light',
                        onTap: () => app.setTheme('light'),
                      ),
                      _themeTile(
                        context: context,
                        label: 'Dark',
                        icon: Icons.dark_mode_outlined,
                        selected: settings.theme == 'dark',
                        onTap: () => app.setTheme('dark'),
                      ),
                      _themeTile(
                        context: context,
                        label: 'Focus',
                        icon: Icons.monitor_outlined,
                        selected: settings.theme == 'focus',
                        onTap: () => app.setTheme('focus'),
                      ),
                      _themeTile(
                        context: context,
                        label: 'Ocean',
                        icon: Icons.water_drop_outlined,
                        selected: settings.theme == 'ocean',
                        onTap: () => app.setTheme('ocean'),
                      ),
                      _themeTile(
                        context: context,
                        label: 'Sunset',
                        icon: Icons.wb_twilight_outlined,
                        selected: settings.theme == 'sunset',
                        onTap: () => app.setTheme('sunset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer Dauer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Passe die Länge deiner Sitzungen an (Minuten).',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),

                  _sliderBlock(
                    context: context,
                    title: 'Fokus Dauer',
                    value: settings.focusMinutes.toDouble(),
                    label: '${settings.focusMinutes} min',
                    min: 1,
                    max: 90,
                    divisions: 89,
                    onChanged: (v) => app.setFocusMinutes(v.round()),
                  ),

                  const SizedBox(height: 18),

                  _sliderBlock(
                    context: context,
                    title: 'Kurze Pause',
                    value: settings.shortBreakMinutes.toDouble(),
                    label: '${settings.shortBreakMinutes} min',
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (v) => app.setShortBreakMinutes(v.round()),
                  ),

                  const SizedBox(height: 18),

                  _sliderBlock(
                    context: context,
                    title: 'Lange Pause',
                    value: settings.longBreakMinutes.toDouble(),
                    label: '${settings.longBreakMinutes} min',
                    min: 5,
                    max: 60,
                    divisions: 11,
                    onChanged: (v) => app.setLongBreakMinutes(v.round()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionCard(
              context: context,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Ton',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Ton abspielen wenn der Timer endet.',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                value: settings.soundEnabled,
                activeColor: theme.colorScheme.primary,
                onChanged: app.toggleSound,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required BuildContext context, required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? theme.colorScheme.outline.withOpacity(0.3) : const Color(0xFFE4E8F1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _themeTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 86,
        height: 106,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderBlock({
    required BuildContext context,
    required String title,
    required double value,
    required String label,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withOpacity(0.12),
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}