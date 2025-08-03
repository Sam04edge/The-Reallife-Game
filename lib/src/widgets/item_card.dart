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
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: _buildLeading(rarityColor),
        title: Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.description),
        trailing: Text(
          '+${item.bonusPercent.toInt()} %',
          style: TextStyle(fontWeight: FontWeight.bold, color: rarityColor),
        ),
        onTap: onEquip,
      ),
    );
  }

  Widget _buildLeading(Color borderColor) {
    final imagePath = item.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      // HIER wird der volle Pfad geladen:
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath, // z.B. "assets/images/items/Ring_rpg.png"
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Fallback-Icon
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_iconForSlot(item.slot), color: borderColor, size: 28),
      );
    }
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
        return Icons.emoji_events;
      case 'schuhe':
        return Icons.directions_walk;
      case 'ring':
        return Icons.radio_button_unchecked;
      case 'amulett':
      case 'amulet':
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
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
      default:
        return Colors.grey.shade600;
    }
  }
}
