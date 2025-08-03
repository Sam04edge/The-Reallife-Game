// lib/src/services/quest_system.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';
import 'item_system.dart';

/// ***NEU***: führt beim Erledigen einer Quest
///   • XP-/Level-Logik aus
///   • Stat-Erhöhung
Future<void> completeQuest(Quest quest) async {
  final prefs = await SharedPreferences.getInstance();

  // 1) aktuellen XP-Stand & Level laden
  double exp = prefs.getDouble('exp') ?? 0;
  int level = prefs.getInt('level') ?? 1;

  // 2) Bonus durch ausgerüstete Items
  final equipped = await loadEquippedItems();
  double bonusPercent = equipped.values
      .where((i) => i.affectedStat == quest.stat)
      .fold(0.0, (sum, i) => sum + i.bonusPercent);
  int bonusXp = (quest.xp * bonusPercent / 100).round();

  // 3) XP hinzufügen
  exp += quest.xp + bonusXp;

  // 4) Level-Up prüfen
  while (exp >= xpNeededForLevel(level)) {
    exp -= xpNeededForLevel(level);
    level++;
  }

  // 5) neue Item-Quests für das neue Level generieren
  await assignNewItemQuestsForLevel(level);

  // 6) neuen XP-Stand & Level speichern
  await savePlayerProgress(exp, level);

  // 7) den Quest-Stat um 1 erhöhen
  final statKey = 'stat_${quest.stat}';
  int current = prefs.getInt(statKey) ?? 0;
  await prefs.setInt(statKey, current + 1);
}

/// Alle verfügbaren Standard-Quests
final List<Quest> allAvailableQuests = [
  Quest(
    id: 'q1',
    title: '30 Minuten Joggen',
    description: 'Trainiere deine Ausdauer und halte durch!',
    xp: 150,
    stat: 'Ausdauer',
    requiredLevel: 1,
  ),
  Quest(
    id: 'q2',
    title: '1 Kapitel lesen',
    description: 'Verbessere deine Weisheit durch Lesen.',
    xp: 100,
    stat: 'Weisheit',
    requiredLevel: 1,
  ),
  Quest(
    id: 'q3',
    title: 'Meditation (10 Minuten)',
    description: 'Stärke deine Willenskraft.',
    xp: 120,
    stat: 'Willenskraft',
    requiredLevel: 2,
  ),
  Quest(
    id: 'q4',
    title: 'Freund anrufen',
    description: 'Pflege dein soziales Netzwerk.',
    xp: 80,
    stat: 'Charisma',
    requiredLevel: 1,
  ),
  Quest(
    id: 'q5',
    title: 'Krafttraining',
    description: 'Steigere deine körperliche Stärke.',
    xp: 160,
    stat: 'Stärke',
    requiredLevel: 3,
  ),
  Quest(
    id: 'q6',
    title: 'Level-2 Quest: Weisheit',
    description: 'Verbessere deine Weisheit durch Lesen.',
    xp: 100,
    stat: 'Weisheit',
    requiredLevel: 2,
  ),
  Quest(
    id: 'q7',
    title: 'Level-2 Quest: Ausdauer',
    description: 'Teste deine Ausdauer bei einem längeren Lauf.',
    xp: 100,
    stat: 'Ausdauer',
    requiredLevel: 2,
  ),
];

/// Lädt die selbst definierten Quests
Future<List<Quest>> loadCustomQuests() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('customQuests');
  if (saved == null) return [];
  final List<dynamic> decoded = jsonDecode(saved);
  return decoded.map((e) => Quest.fromJson(e)).toList();
}

/// Speichert die selbst definierten Quests
Future<void> saveCustomQuests(List<Quest> quests) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(quests.map((q) => q.toJson()).toList());
  await prefs.setString('customQuests', encoded);
}

/// Gibt dir die Quests für heute zurück (max. 3 Stück, auf Basis deines Levels)
Future<List<Quest>> loadTodaysQuests() async {
  final prefs = await SharedPreferences.getInstance();
  final todayKey = DateTime.now().toIso8601String().substring(0, 10);

  // Wenn bereits generiert und noch heute gültig:
  final savedDate = prefs.getString('todayDate');
  if (savedDate == todayKey) {
    final savedJson = prefs.getString('todayQuests');
    if (savedJson != null) {
      final List<dynamic> decoded = jsonDecode(savedJson);
      return decoded.map((e) => Quest.fromJson(e)).toList();
    }
  }

  final level = prefs.getInt('level') ?? 1;
  final levelQuests =
      allAvailableQuests.where((q) => q.requiredLevel == level).toList();

  List<Quest> selection;
  if (levelQuests.isEmpty) {
    final fallback =
        allAvailableQuests.where((q) => q.requiredLevel == 1).toList();
    fallback.shuffle();
    selection = fallback.take(3).toList();
  } else {
    levelQuests.shuffle();
    final temp = <Quest>[];
    while (temp.length < 3) {
      temp.addAll(levelQuests);
    }
    temp.shuffle();
    selection = temp.take(3).toList();
  }

  await prefs.setString('todayDate', todayKey);
  await prefs.setString(
    'todayQuests',
    jsonEncode(selection.map((q) => q.toJson()).toList()),
  );

  return selection;
}

/// Liest die IDs der bereits erledigten Quests für heute
Future<Set<String>> getCompletedQuestIds() async {
  final prefs = await SharedPreferences.getInstance();
  final todayKey = DateTime.now().toIso8601String().substring(0, 10);
  final key = 'completedQuestIds_$todayKey';
  final saved = prefs.getString(key);
  if (saved == null) return {};
  return (jsonDecode(saved) as List<dynamic>).cast<String>().toSet();
}

/// Speichert die erledigten Quest-IDs für heute
Future<void> setCompletedQuestIds(Set<String> ids) async {
  final prefs = await SharedPreferences.getInstance();
  final todayKey = DateTime.now().toIso8601String().substring(0, 10);
  final key = 'completedQuestIds_$todayKey';
  await prefs.setString(key, jsonEncode(ids.toList()));
}

// XP-Berechnung pro Level
double xpNeededForLevel(int level) {
  return 1000 + (level - 1) * 500;
}

// speichert XP-Stand und Level
Future<void> savePlayerProgress(double exp, int level) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('exp', exp);
  await prefs.setInt('level', level);
}
