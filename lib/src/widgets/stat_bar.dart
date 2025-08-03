// lib/src/widgets/stat_bar.dart

import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;

  const StatBar({
    Key? key,
    required this.label,
    required this.value,
    required this.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percent = (value / max).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon je nach Label
            Icon(_iconFor(label), color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: percent, minHeight: 8),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${value.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String label) {
    switch (label) {
      case 'Weisheit':
        return Icons.school;
      case 'Stärke':
        return Icons.fitness_center;
      case 'Ausdauer':
        return Icons.directions_run;
      case 'Charisma':
        return Icons.emoji_people;
      case 'Glück':
        return Icons.star;
      case 'Willenskraft':
        return Icons.self_improvement;
      default:
        return Icons.bar_chart;
    }
  }
}
