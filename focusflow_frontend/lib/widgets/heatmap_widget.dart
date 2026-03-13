import 'package:flutter/material.dart';
import '../models/stats_summary.dart';

class HeatmapWidget extends StatelessWidget {
  final List<HeatmapDay> data;

  const HeatmapWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cells = _buildLast70Days();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final minutes = cells[index];

              return Container(
                decoration: BoxDecoration(
                  color: _getColor(minutes),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Weniger',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            _legendBox(const Color(0xFFEFF2F8)),
            const SizedBox(width: 6),
            _legendBox(const Color(0xFFC9D4F8)),
            const SizedBox(width: 6),
            _legendBox(const Color(0xFF93A8F0)),
            const SizedBox(width: 6),
            _legendBox(const Color(0xFF6483EA)),
            const SizedBox(width: 6),
            _legendBox(const Color(0xFF4A67F5)),
            const SizedBox(width: 8),
            const Text(
              'Mehr',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<int> _buildLast70Days() {
    final map = <String, int>{};

    for (final d in data) {
      map[d.date] = d.minutes;
    }

    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 69));

    final result = <int>[];

    for (int i = 0; i < 70; i++) {
      final date = start.add(Duration(days: i));
      final key =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      result.add(map[key] ?? 0);
    }

    return result;
  }

  Color _getColor(int minutes) {
    if (minutes <= 0) return const Color(0xFFEFF2F8);
    if (minutes < 15) return const Color(0xFFD7DFFC);
    if (minutes < 30) return const Color(0xFFB5C4F8);
    if (minutes < 60) return const Color(0xFF8FA6F2);
    return const Color(0xFF6483EA);
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}