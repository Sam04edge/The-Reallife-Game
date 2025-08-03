// lib/src/models/item_quest.dart

import 'item_quest_step.dart';

/// Eine Item‑Quest besteht aus einer ID, einem Titel, einer Reward‑Item‑ID und einer Liste von Schritten.
class ItemQuest {
  final String id;
  final String title;
  final String rewardItemId;
  final List<ItemQuestStep> steps;

  ItemQuest({
    required this.id,
    required this.title,
    required this.rewardItemId,
    this.steps = const [],
  });

  /// Deserialisierung aus JSON
  factory ItemQuest.fromJson(Map<String, dynamic> json) => ItemQuest(
        id: json['id'] as String,
        title: json['title'] as String,
        rewardItemId: json['rewardItemId'] as String,
        steps: (json['steps'] as List<dynamic>)
            .map((e) => ItemQuestStep.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Serialisierung zu JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'rewardItemId': rewardItemId,
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}
