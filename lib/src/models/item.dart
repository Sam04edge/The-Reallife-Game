// lib/src/models/item.dart

import '../utils/enums.dart';

/// Seltenheit eines Items
enum ItemRarity { common, rare, epic, legendary }

/// Ein Ausrüstungs‐Item mit optionalem Bildpfad
class Item {
  final String id;
  final String name;
  final String description;
  final String slot; // z. B. "Ring", "Amulett"
  final String affectedStat; // z. B. "Ausdauer"
  final double bonusPercent; // z. B. 20.0
  final ItemRarity rarity;
  final String?
      imagePath; // optionaler Asset‐Pfad, z.B. "assets/images/items/ring.png"

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.slot,
    required this.affectedStat,
    required this.bonusPercent,
    required this.rarity,
    this.imagePath,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        slot: json['slot'] as String,
        affectedStat: json['affectedStat'] as String,
        bonusPercent: (json['bonusPercent'] as num).toDouble(),
        rarity: ItemRarity.values.firstWhere((r) => r.name == json['rarity']),
        imagePath: json['imagePath'] as String?,
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'slot': slot,
      'affectedStat': affectedStat,
      'bonusPercent': bonusPercent,
      'rarity': rarity.name,
    };
    if (imagePath != null) {
      data['imagePath'] = imagePath;
    }
    return data;
  }
}
