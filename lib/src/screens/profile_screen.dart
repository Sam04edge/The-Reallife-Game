// lib/src/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';
import '../services/item_system.dart';
import '../services/quest_system.dart'; // für xpNeededForLevel(...)
import '../widgets/stat_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  int level = 1;
  double exp = 0;
  String? avatarPath;
  String playerName = 'Spieler';

  final Map<String, int> stats = {
    'Weisheit': 0,
    'Stärke': 0,
    'Ausdauer': 0,
    'Charisma': 0,
    'Glück': 0,
    'Willenskraft': 0,
  };

  Map<String, Item> equippedItems = {};
  List<Item> ownedItems = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Level laden
    final lvl = prefs.getInt('level') ?? 1;

    // 2) XP, Avatar und Name laden
    final xpValue = prefs.getDouble('exp') ?? 0.0;
    final avatar = prefs.getString('avatarPath');
    final name = prefs.getString('playerName') ?? 'Spieler';

    // 3) Stats laden
    final newStats = <String, int>{};
    for (final key in stats.keys) {
      newStats[key] = prefs.getInt('stat_$key') ?? 0;
    }

    // 4) Items laden
    final owned = await loadOwnedItems();
    final equipped = await loadEquippedItems();

    // 5) State aktualisieren
    setState(() {
      level = lvl;
      exp = xpValue;
      avatarPath = avatar;
      playerName = name;
      stats
        ..clear()
        ..addAll(newStats);
      ownedItems = owned;
      equippedItems = equipped;
    });
  }

  /// XP bis zum nächsten Level, kommt aus quest_system.dart
  double get expToNextLevel => xpNeededForLevel(level);

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await SharedPreferences.getInstance()
          .then((p) => p.setString('avatarPath', picked.path));
      setState(() => avatarPath = picked.path);
    }
  }

  Future<void> _changeName() async {
    final controller = TextEditingController(text: playerName);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Name ändern'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Speichern')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await SharedPreferences.getInstance()
          .then((p) => p.setString('playerName', result));
      setState(() => playerName = result);
    }
  }

  Future<void> _resetApp() async {
    await SharedPreferences.getInstance().then((p) => p.clear());
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  Color _rarityColor(ItemRarity? r) {
    switch (r) {
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
      default:
        return Colors.grey.shade800;
    }
  }

  Future<void> _showEquipDialog(String slot) async {
    final options = ownedItems.where((i) => i.slot == slot).toList();
    final picked = await showDialog<Item?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$slot auswählen'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Keines'),
                onTap: () => Navigator.pop(context, null),
              ),
              for (final item in options)
                ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: Text(item.rarity.name,
                      style: TextStyle(color: _rarityColor(item.rarity))),
                  onTap: () => Navigator.pop(context, item),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      equippedItems[slot] = picked;
    } else {
      equippedItems.remove(slot);
    }
    await saveEquippedItems(equippedItems);
    setState(() {});
  }

  Widget _buildSlot(String slot) {
    final item = equippedItems[slot];
    final borderColor = item != null ? _rarityColor(item.rarity) : Colors.brown;
    return InkWell(
      onTap: () => _showEquipDialog(slot),
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.brown.shade200,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          item?.name ?? slot,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (exp / expToNextLevel).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.brown.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Level & XP
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield, color: Colors.brown.shade700),
                        const SizedBox(width: 8),
                        Text('Level $level',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 4),
                    Text('${exp.toInt()} / ${expToNextLevel.toInt()} XP'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Slots + Avatar + Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                    children: ['Kopf', 'Brust', 'Hose', 'Schuhe']
                        .map(_buildSlot)
                        .toList()),
                Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.brown.shade300,
                        backgroundImage: avatarPath != null
                            ? FileImage(File(avatarPath!))
                            : null,
                        child: avatarPath == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _changeName,
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(playerName),
                    ),
                  ],
                ),
                Column(
                    children:
                        ['Amulett', 'Ring', 'Gürtel'].map(_buildSlot).toList()),
              ],
            ),
            const SizedBox(height: 16),

            // Stats
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Deine Werte',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Column(
              children: stats.entries.map((e) {
                return StatBar(
                  label: e.key,
                  value: e.value.toDouble(),
                  max: 100.0,
                );
              }).toList(),
            ),

            if (kDebugMode) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _resetApp,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade300),
                child: const Text('🛠️ App zurücksetzen (DEV)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
