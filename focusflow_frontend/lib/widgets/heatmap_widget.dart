import 'package:flutter/material.dart';
import '../models/stats_summary.dart';

class HeatmapWidget extends StatelessWidget {
  final List<HeatmapDay> data;

  const HeatmapWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cells = _buildLast70Days();
    final maxMinutes = cells.fold<int>(0, (max, val) => val > max ? val : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final minutes = cells[index];
              return Tooltip(
                message: _getTooltip(index, minutes),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getColor(minutes, maxMinutes),
                    borderRadius: BorderRadius.circular(4),
                  ),
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
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            _legendBox(_getColor(0, 60)),
            const SizedBox(width: 3),
            _legendBox(_getColor(15, 60)),
            const SizedBox(width: 3),
            _legendBox(_getColor(30, 60)),
            const SizedBox(width: 3),
            _legendBox(_getColor(45, 60)),
            const SizedBox(width: 3),
            _legendBox(_getColor(60, 60)),
            const SizedBox(width: 6),
            const Text(
              'Mehr',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTooltip(int index, int minutes) {
    final date = DateTime.now().subtract(Duration(days: 69 - index));
    final dateStr = '${date.day}.${date.month}.${date.year}';
    return minutes > 0 ? '$dateStr: $minutes Min' : '$dateStr: Keine';
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
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result.add(map[key] ?? 0);
    }
    return result;
  }

  Color _getColor(int minutes, int maxMinutes) {
    if (minutes <= 0) return const Color(0xFFEBEDF0);
    if (maxMinutes == 0) return const Color(0xFF9BE9A8);
    
    final intensity = minutes / maxMinutes;
    if (intensity < 0.25) return const Color(0xFF9BE9A8);
    if (intensity < 0.5) return const Color(0xFF40C463);
    if (intensity < 0.75) return const Color(0xFF30A14E);
    return const Color(0xFF216E39);
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
