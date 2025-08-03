// lib/src/widgets/item_card.dart

import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onEquip;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onEquip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(item.rarity);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: onEquip,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: _buildLeading(item.imagePath, rarityColor),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item.description),
        trailing: Text(
          '+${item.bonusPercent.toInt()}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: rarityColor,
          ),
        ),
      ),
    );
  }

  /// Wenn imagePath gesetzt ist, Asset laden, sonst Icon-Fallback
  Widget _buildLeading(String? imagePath, Color borderColor) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _iconForSlot(item.slot),
        color: borderColor,
        size: 28,
      ),
    );
  }

  IconData _iconForSlot(String slot) {
    switch (slot.toLowerCase()) {
      case 'kopf':
      case 'helm':
        return Icons.shield;
      case 'brust':
      case 'hemd':
        return Icons.checkroom;
      case 'hose':
        return Icons.checkroom;
      case 'schuhe':
        return Icons.directions_walk;
      case 'ring':
        return Icons.radio_button_unchecked;
      case 'amulet':
      case 'amulett':
        return Icons.emoji_symbols;
      case 'gürtel':
      case 'belt':
        return Icons.wallet_travel;
      default:
        return Icons.inventory_2;
    }
  }

  Color _rarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey.shade600;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
    }
  }
}
