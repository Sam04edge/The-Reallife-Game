// lib/src/services/item_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';
import '../models/item_quest.dart';
import '../models/item_quest_step.dart';

/// Alle verfügbaren Items
final List<Item> allAvailableItems = [
  Item(
    id: 'ring_ausdauer_rare',
    name: 'Ring der Ausdauer',
    description: 'Erhöht XP auf Ausdauerquests um 20 %',
    slot: 'Ring',
    affectedStat: 'Ausdauer',
    bonusPercent: 20.0,
    rarity: ItemRarity.rare,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
  Item(
    id: 'amulet_weisheit_epic',
    name: 'Amulett der Weisheit',
    description: 'Erhöht XP auf Weisheitsquests um 30 %',
    slot: 'Amulett',
    affectedStat: 'Weisheit',
    bonusPercent: 30.0,
    rarity: ItemRarity.epic,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
  Item(
    id: 'belt_starke_common',
    name: 'Gürtel der Stärke',
    description: 'Erhöht XP auf Stärkequests um 10 %',
    slot: 'Gürtel',
    affectedStat: 'Stärke',
    bonusPercent: 10.0,
    rarity: ItemRarity.common,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
  Item(
    id: 'ring_charisma_legendary',
    name: 'Legendärer Ring des Charisma',
    description: 'Erhöht XP auf Charismaquests um 50 %',
    slot: 'Ring',
    affectedStat: 'Charisma',
    bonusPercent: 50.0,
    rarity: ItemRarity.legendary,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
  Item(
    id: 'schuhe_ausdauer_legendary',
    name: 'Legendärer Schuh der Ausdauer',
    description: 'Erhöht XP auf Ausdauerquests um 50 %',
    slot: 'Schuhe',
    affectedStat: 'Ausdauer',
    bonusPercent: 50.0,
    rarity: ItemRarity.legendary,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
  Item(
    id: 'helm_charisma_legendary',
    name: 'Legendärer Helm des Charisma',
    description: 'Erhöht XP auf Charismaquests um 50 %',
    slot: 'Kopf',
    affectedStat: 'Charisma',
    bonusPercent: 50.0,
    rarity: ItemRarity.legendary,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
  Item(
    id: 'hemd_charisma_legendary',
    name: 'Legendäres Hemd des Charisma',
    description: 'Erhöht XP auf Charismaquests um 50 %',
    slot: 'Brust',
    affectedStat: 'Charisma',
    bonusPercent: 50.0,
    rarity: ItemRarity.legendary,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
  Item(
    id: 'hose_charisma_legendary',
    name: 'Legendäre Hose des Charisma',
    description: 'Erhöht XP auf Charismaquests um 50 %',
    slot: 'Hose',
    affectedStat: 'Charisma',
    bonusPercent: 50.0,
    rarity: ItemRarity.legendary,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
  Item(
    id: 'schuhe_charisma_legendary',
    name: 'Legendäre Schuhe des Charisma',
    description: 'Erhöht XP auf Charismaquests um 50 %',
    slot: 'Schuhe',
    affectedStat: 'Charisma',
    bonusPercent: 50.0,
    rarity: ItemRarity.legendary,
    imagePath: 'assets/images/items/Ring_rpg.png',
  ),
];

/// Alle Item‑Quests (Haupt‑ und Nebenquests nach Level)
final List<ItemQuest> allItemQuests = [
  // Level 1 – Hauptquest
  ItemQuest(
    id: 'main_lvl1',
    title: 'Erkunde die alte Ruine',
    rewardItemId: 'amulet_weisheit_epic',
    steps: [
      ItemQuestStep(
          title: 'Reise zu den Ruinen', description: 'Jogge 30 Minuten.'),
      ItemQuestStep(
          title: 'Am Eingang triffst du einen Elfen',
          description: 'Lerne jemanden Neues kennen.'),
      ItemQuestStep(
          title: 'In der Bibliothek entdeckst du ein Merkwürdiges Buch',
          description: 'Lese ein Kapitel.'),
    ],
  ),
  // Level 1 – Nebenquest 1
  ItemQuest(
    id: 'side_lvl1_1',
    title: 'Hilf dem Schmied',
    rewardItemId: 'schuhe_ausdauer_legendary',
    steps: [
      ItemQuestStep(
          title: 'Trage Kohlen zum Ofen', description: 'Mache 20 Kniebeugen.'),
    ],
  ),
  // Level 1 – Nebenquest 2
  ItemQuest(
    id: 'side_lvl1_2',
    title: 'Sammle Heilkräuter',
    rewardItemId: 'hose_charisma_legendary',
    steps: [
      ItemQuestStep(
          title: 'Gehe in den Wald',
          description: 'Spaziere 20 Minuten draußen.'),
    ],
  ),
  // Level 2 – Hauptquest
  ItemQuest(
    id: 'main_lvl2',
    title: 'Reise zur Kristallhöhle',
    rewardItemId: 'amulet_weisheit_epic',
    steps: [
      ItemQuestStep(
          title: 'Wandere in die Berge',
          description: 'Mach einen Spaziergang mit Steigung.'),
    ],
  ),
];

/// Speichert die ausgerüsteten Items (Slot → Item)
Future<void> saveEquippedItems(Map<String, Item> equipped) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonMap = {
    for (final e in equipped.entries) e.key: e.value.toJson(),
  };
  await prefs.setString('equippedItems', jsonEncode(jsonMap));
}

/// Lädt die ausgerüsteten Items
Future<Map<String, Item>> loadEquippedItems() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('equippedItems');
  if (data == null) return {};
  final decoded = jsonDecode(data) as Map<String, dynamic>;
  return decoded.map((key, value) => MapEntry(key, Item.fromJson(value)));
}

/// Lädt alle besessenen Items
Future<List<Item>> loadOwnedItems() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('ownedItems');
  if (saved == null) return [];
  final list = jsonDecode(saved) as List<dynamic>;
  return list.map((e) => Item.fromJson(e)).toList();
}

/// Speichert die besessenen Items
Future<void> saveOwnedItems(List<Item> items) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
  await prefs.setString('ownedItems', encoded);
}

/// Speichert alle aktuell aktiven Item‑Quests
Future<void> saveItemQuests(List<ItemQuest> quests) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(quests.map((q) => q.toJson()).toList());
  await prefs.setString('itemQuests', encoded);
}

/// Lädt die aktuell aktiven Item‑Quests
Future<List<ItemQuest>> loadItemQuests() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('itemQuests');
  if (saved == null) return [];
  final list = jsonDecode(saved) as List<dynamic>;
  return list.map((e) => ItemQuest.fromJson(e)).toList();
}

/// Generiert für das gegebene Level eine Haupt‑ und zwei Nebenquests
List<ItemQuest> generateItemQuestsForLevel(int level) {
  final mainQuest = allItemQuests.firstWhere(
    (q) => q.id == 'main_lvl$level',
    orElse: () => throw Exception('Keine Hauptquest für Level $level'),
  );
  final side =
      allItemQuests.where((q) => q.id.startsWith('side_lvl$level')).toList();
  side.shuffle();
  final selectedSide = side.take(2).toList();
  return [mainQuest, ...selectedSide];
}

/// Weist dem Spieler neue Item‑Quests zu und speichert sie
Future<void> assignNewItemQuestsForLevel(int level) async {
  final newQuests = generateItemQuestsForLevel(level);
  await saveItemQuests(newQuests);
}
