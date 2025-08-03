// lib/src/screens/stats_overview_screen.dart
import 'package:flutter/material.dart';
import '../widgets/stat_bar.dart';

class StatsOverviewScreen extends StatelessWidget {
  const StatsOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Echte Datenquelle anbinden
    final stats = {
      'Stärke': 10.0,
      'Ausdauer': 20.0,
      'Weisheit': 15.0,
    };
    const maxStat = 100.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Statsübersicht')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stats.entries
              .map((e) => StatBar(
                    label: e.key,
                    value: e.value,
                    max: maxStat,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
