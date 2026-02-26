import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const FocusFlowApp());

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Flow',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const FocusTimerScreen(),
    );
  }
}

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const int defaultMinutes = 25;

  Timer? _timer;
  int _totalSec = defaultMinutes * 60;
  int _remainingSec = defaultMinutes * 60;

  bool get _isRunning => _timer != null;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSec <= 1) {
        _timer?.cancel();
        _timer = null;
        setState(() => _remainingSec = 0);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session fertig')),
        );
        return;
      }

      setState(() => _remainingSec--);
    });

    setState(() {});
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    setState(() {});
  }

  void _reset() {
    _pause();
    setState(() {
      _totalSec = defaultMinutes * 60;
      _remainingSec = _totalSec;
    });
  }

  String _mmss(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    if (_totalSec == 0) return 0;
    return (1 - (_remainingSec / _totalSec)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _mmss(_remainingSec);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 18),
            Text(
              '$defaultMinutes min Fokus',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 12,
                  ),
                  Text(
                    timeText,
                    style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? _pause : _start,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? 'Pause' : 'Start'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}