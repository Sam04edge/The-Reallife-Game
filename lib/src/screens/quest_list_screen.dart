// lib/src/screens/quest_list_screen.dart

import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../services/quest_system.dart';
import '../widgets/quest_card.dart';

class QuestListScreen extends StatefulWidget {
  const QuestListScreen({Key? key}) : super(key: key);

  @override
  State<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends State<QuestListScreen> {
  List<Quest> _daily = [];
  List<Quest> _custom = [];
  Set<String> _doneIds = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final daily = await loadTodaysQuests();
    final custom = await loadCustomQuests();
    final done = await getCompletedQuestIds();

    // Flag-Feld in each Quest setzen
    for (var q in daily) q.completed = done.contains(q.id);
    for (var q in custom) q.completed = done.contains(q.id);

    setState(() {
      _daily = daily;
      _custom = custom;
      _doneIds = done;
    });
  }

  Future<void> _onToggle(Quest quest, bool? checked) async {
    if (checked == true) {
      await completeQuest(quest);
      final newIds = {..._doneIds, quest.id};
      await setCompletedQuestIds(newIds);
      setState(() {
        _doneIds = newIds;
        quest.completed = true;
      });
    } else {
      // optional: Abhaken rückgängig machen
      final newIds = {..._doneIds}..remove(quest.id);
      await setCompletedQuestIds(newIds);
      setState(() {
        _doneIds = newIds;
        quest.completed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests'),
        backgroundColor: primary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Tägliche Quests
          ExpansionTile(
            initiallyExpanded: true,
            title: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text('Tägliche Quests',
                    style:
                        TextStyle(color: primary, fontWeight: FontWeight.bold)),
              ],
            ),
            children: _daily.map((q) {
              return QuestCard(
                quest: q,
                onChanged: (c) => _onToggle(q, c),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Eigene Quests
          ExpansionTile(
            title: Row(
              children: [
                const Icon(Icons.edit),
                const SizedBox(width: 8),
                Text('Eigene Quests',
                    style:
                        TextStyle(color: primary, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: primary,
                  onPressed: () {
                    // Dein Dialog zum Hinzufügen
                  },
                ),
              ],
            ),
            children: _custom.map((q) {
              return QuestCard(
                quest: q,
                onChanged: (c) => _onToggle(q, c),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
