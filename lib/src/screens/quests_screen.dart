// lib/src/screens/quests_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quest.dart';
import '../models/item.dart';
import '../models/item_quest.dart';
import '../models/item_quest_step.dart';
import '../services/quest_system.dart';
import '../services/item_system.dart';
import '../widgets/quest_card.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  late Future<void> _initialLoad;

  List<Quest> todaysQuests = [];
  Set<String> completedIds = {};
  List<Quest> customQuests = [];
  List<ItemQuest> activeItemQuests = [];
  List<Item> ownedItems = [];

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getInt('level') ?? 1;

    // bereits erfüllte Quest-IDs heute
    final done = await getCompletedQuestIds();

    // tägliche Quests laden und completed-Flag setzen
    final quests = await loadTodaysQuests();
    for (var q in quests) {
      q.completed = done.contains(q.id);
    }

    // eigene Quests
    final custom = await loadCustomQuests();
    for (var q in custom) {
      q.completed = done.contains(q.id);
    }

    // Item-Quests: nur wenn Level sich wirklich ändert
    final savedLevel = prefs.getInt('itemQuestLevel') ?? 0;
    List<ItemQuest> itemQuests = await loadItemQuests();
    if (savedLevel != level) {
      itemQuests = generateItemQuestsForLevel(level);
      await saveItemQuests(itemQuests);
      await prefs.setInt('itemQuestLevel', level);
    }

    // owned items
    final items = await loadOwnedItems();

    setState(() {
      todaysQuests = quests;
      completedIds = done;
      customQuests = custom;
      ownedItems = items;
      activeItemQuests = itemQuests;
    });
  }

  Future<void> _showAddCustomQuestDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String difficulty = 'Leicht';

    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Neue eigene Quest'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Quest Titel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: difficulty,
                items: const [
                  DropdownMenuItem(value: 'Leicht', child: Text('Leicht')),
                  DropdownMenuItem(value: 'Mittel', child: Text('Mittel')),
                  DropdownMenuItem(value: 'Schwer', child: Text('Schwer')),
                ],
                onChanged: (v) => difficulty = v ?? difficulty,
                decoration: const InputDecoration(
                  labelText: 'Schwierigkeit',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Hinzufügen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      int xp;
      switch (difficulty) {
        case 'Mittel':
          xp = 100;
          break;
        case 'Schwer':
          xp = 150;
          break;
        default:
          xp = 50;
      }

      final newQuest = Quest(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        xp: xp,
        stat: 'Willenskraft',
        requiredLevel: 1,
      );

      customQuests.add(newQuest);
      await saveCustomQuests(customQuests);
      setState(() {});
    }
  }

  Future<void> _markQuestCompleted(Quest quest) async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Item-Quest?
    if (quest.rewardItemId != null) {
      final rewardItem =
          allAvailableItems.firstWhere((i) => i.id == quest.rewardItemId);
      final owned = await loadOwnedItems();
      owned.add(rewardItem);
      await saveOwnedItems(owned);

      // Item-Quest entfernen
      activeItemQuests.removeWhere((q) => q.id == quest.id);
      await saveItemQuests(activeItemQuests);
      setState(() {});
      return;
    }

    // 2) Normale XP-Quest
    double exp = prefs.getDouble('exp') ?? 0.0;
    int level = prefs.getInt('level') ?? 1;
    final oldLevel = level; // merken

    final equipped = await loadEquippedItems();
    double bonusPercent = equipped.values
        .where((i) => i.affectedStat == quest.stat)
        .fold(0.0, (s, i) => s + i.bonusPercent);
    final bonusXp = (quest.xp * bonusPercent / 100).round();
    exp += quest.xp + bonusXp;

    // **nur hier** Level-Up prüfen
    while (exp >= xpNeededForLevel(level)) {
      exp -= xpNeededForLevel(level);
      level++;
    }
    await savePlayerProgress(exp, level);

    // wenn echtes Level-Up, neue Item-Quests generieren
    if (level > oldLevel) {
      await assignNewItemQuestsForLevel(level);
      await prefs.setInt('itemQuestLevel', level);
    }

    // Stat erhöhen
    final key = 'stat_${quest.stat}';
    final curr = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, curr + 1);

    // als erledigt markieren
    completedIds.add(quest.id);
    await setCompletedQuestIds(completedIds);

    // eigene Quest aus Liste nehmen
    if (customQuests.any((q) => q.id == quest.id)) {
      customQuests.removeWhere((q) => q.id == quest.id);
      await saveCustomQuests(customQuests);
    }

    setState(() {});
  }

  List<Widget> _buildQuestList(List<Quest> quests,
      {bool lockWhenDone = false}) {
    if (quests.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Keine Quests verfügbar.',
            style: TextStyle(color: Colors.brown.shade600),
          ),
        )
      ];
    }
    return quests.map((q) {
      final onChanged =
          (lockWhenDone && q.completed) ? null : (_) => _markQuestCompleted(q);
      return QuestCard(quest: q, onChanged: onChanged);
    }).toList();
  }

  List<Widget> _buildItemQuestList() {
    if (activeItemQuests.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Keine Item-Quests verfügbar.',
            style: TextStyle(color: Colors.brown.shade600),
          ),
        )
      ];
    }

    return activeItemQuests.map((quest) {
      final allDone = quest.steps.every((s) => s.completed);

      // nur bereits erledigte Schritte + den nächsten offenen zeigen
      final visibleSteps = <ItemQuestStep>[];
      for (final step in quest.steps) {
        visibleSteps.add(step);
        if (!step.completed) break;
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ExpansionTile(
          title: Text(
            quest.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            allDone
                ? 'Bereit für Belohnung!'
                : 'Fortschritt: ${quest.steps.where((s) => s.completed).length}/${quest.steps.length}',
          ),
          children: [
            ...visibleSteps.map((step) => CheckboxListTile(
                  title: Text(step.title),
                  subtitle: Text(step.description),
                  value: step.completed,
                  onChanged: step.completed
                      ? null
                      : (v) {
                          setState(() => step.completed = v ?? false);
                          saveItemQuests(activeItemQuests);
                        },
                )),
            if (allDone)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Belohnung abholen'),
                  onPressed: () => _markQuestCompleted(
                    Quest(
                      id: quest.id,
                      title: quest.title,
                      description: '',
                      xp: 0,
                      stat: '',
                      requiredLevel: 0,
                      rewardItemId: quest.rewardItemId,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialLoad,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Quests'),
            backgroundColor: Colors.brown.shade700,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  '🗓️ Tägliche Quests',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800),
                ),
                children: _buildQuestList(todaysQuests, lockWhenDone: true),
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text(
                  '💍 Item-Quests',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800),
                ),
                children: _buildItemQuestList(),
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                title: Row(
                  children: [
                    Text(
                      '✏️ Eigene Quests',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      color: Colors.brown,
                      onPressed: _showAddCustomQuestDialog,
                    ),
                  ],
                ),
                children: _buildQuestList(customQuests, lockWhenDone: true),
              ),
            ],
          ),
        );
      },
    );
  }
}
