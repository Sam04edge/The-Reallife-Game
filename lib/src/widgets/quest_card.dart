// quest_card.dart
import 'package:flutter/material.dart';
import '../models/quest.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  // onChanged ist jetzt nullable – wenn null, ist die Checkbox gesperrt
  final ValueChanged<bool?>? onChanged;

  const QuestCard({
    Key? key,
    required this.quest,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: CheckboxListTile(
        // aktueller Check‐Status
        value: quest.completed,
        // wenn onChanged null ist, ist die Checkbox automatisch deaktiviert
        onChanged: onChanged == null
            ? null
            : (val) {
                // lokal setzen
                quest.completed = val ?? false;
                // Callback für XP/Stat/Prefs
                onChanged!(val);
              },
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: theme.primaryColor,
        tileColor: quest.completed ? theme.primaryColor.withOpacity(0.1) : null,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          quest.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: quest.completed ? theme.primaryColor : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            quest.rewardItemId == null
                ? '${quest.description}\nBelohnung: ${quest.xp} XP +1 auf ${quest.stat}'
                : '${quest.description}\nBelohnung: Item – ${quest.rewardItemId}',
            style: const TextStyle(height: 1.4),
          ),
        ),
      ),
    );
  }
}
