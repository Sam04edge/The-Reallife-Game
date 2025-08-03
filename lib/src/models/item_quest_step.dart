// lib/src/models/item_quest_step.dart

/// Ein Schritt innerhalb einer Item‑Quest, der einen Titel, eine Beschreibung
/// und einen Erledigt‑Status besitzt.
class ItemQuestStep {
  final String title;
  final String description;
  bool completed;

  ItemQuestStep({
    required this.title,
    required this.description,
    this.completed = false,
  });

  /// Deserialisiert einen Schritt aus JSON.
  factory ItemQuestStep.fromJson(Map<String, dynamic> json) => ItemQuestStep(
        title: json['title'] as String,
        description: json['description'] as String,
        completed: json['completed'] as bool? ?? false,
      );

  /// Serialisiert diesen Schritt zu JSON.
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'completed': completed,
      };
}
