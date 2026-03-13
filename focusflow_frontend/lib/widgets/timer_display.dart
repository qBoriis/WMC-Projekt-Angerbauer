import 'dart:async';
import 'package:flutter/material.dart';

class TimerDisplay extends StatefulWidget {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final Future<void> Function(int duration, String mode) onComplete;

  const TimerDisplay({
    super.key,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.onComplete,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  Timer? _timer;
  String mode = 'focus';
  late int totalSeconds;
  late int remainingSeconds;
  DateTime? startedAtUtc;

  bool get isRunning => _timer != null;

  @override
  void initState() {
    super.initState();
    _resetForMode();
  }

  @override
  void didUpdateWidget(covariant TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isRunning) {
      _resetForMode();
    }
  }

  int _getMinutesForMode() {
    switch (mode) {
      case 'shortBreak':
        return widget.shortBreakMinutes;
      case 'longBreak':
        return widget.longBreakMinutes;
      default:
        return widget.focusMinutes;
    }
  }

  void _resetForMode() {
    totalSeconds = _getMinutesForMode() * 60;
    remainingSeconds = totalSeconds;
    if (mounted) setState(() {});
  }

  void _switchMode(String newMode) {
    _timer?.cancel();
    _timer = null;
    startedAtUtc = null;
    mode = newMode;
    _resetForMode();
  }

  void _toggle() {
    if (isRunning) {
      _timer?.cancel();
      _timer = null;
      setState(() {});
      return;
    }

    startedAtUtc ??= DateTime.now().toUtc();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (remainingSeconds <= 1) {
        _timer?.cancel();
        _timer = null;

        final durationMin = _getMinutesForMode();

        setState(() {
          remainingSeconds = 0;
        });

        await widget.onComplete(
          durationMin,
          mode == 'focus' ? 'focus' : 'break',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                mode == 'focus' ? 'Fokus-Session fertig' : 'Pause fertig',
              ),
            ),
          );
        }
        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });

    setState(() {});
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    startedAtUtc = null;
    _resetForMode();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : 1 - (remainingSeconds / totalSeconds);

    return Column(
      children: [
        _buildModeSelector(),
        const SizedBox(height: 55),
        _buildCircle(progress),
        const SizedBox(height: 56),
        _buildButtons(),
      ],
    );
  }

  Widget _buildModeSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF2F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeChip('focus', 'Focus'),
          _buildModeChip('shortBreak', 'Short Break'),
          _buildModeChip('longBreak', 'Long Break'),
        ],
      ),
    );
  }

  Widget _buildModeChip(String value, String text) {
    final selected = mode == value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _switchMode(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected 
              ? (isDark ? theme.colorScheme.surface : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected 
                ? theme.colorScheme.onSurface 
                : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double progress) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 315,
      height: 315,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 315,
            height: 315,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          Container(
            width: 285,
            height: 285,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(remainingSeconds),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isRunning ? 'RUNNING' : 'PAUSED',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 2.3,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _reset,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                width: 2,
              ),
              color: Colors.transparent,
            ),
            child: Icon(
              Icons.restart_alt,
              size: 28,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: 28),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isRunning ? Icons.pause : Icons.play_arrow_rounded,
              size: 36,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}