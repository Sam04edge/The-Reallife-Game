// quest_step.dart

class QuestStep {
  final String id;
  final String questId;
  final String description;
  bool done;

  QuestStep({
    required this.id,
    required this.questId,
    required this.description,
    this.done = false,
  });
}
