// lib/src/screens/inventar_screen.dart
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_system.dart';
import '../widgets/item_card.dart';

class InventarScreen extends StatefulWidget {
  const InventarScreen({Key? key}) : super(key: key);
  @override
  _InventarScreenState createState() => _InventarScreenState();
}

class _InventarScreenState extends State<InventarScreen> {
  List<Item> _items = [];
  @override
  void initState() {
    super.initState();
    loadOwnedItems().then((l) => setState(() => _items = l));
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Center(child: Text('Kein Inventar'));
    }
    return ListView(
      children: _items.map((item) {
        return ItemCard(
          item: item,
          onEquip: () {
            // falls Du hier equip‐Logik haben willst
          },
        );
      }).toList(),
    );
  }
}
