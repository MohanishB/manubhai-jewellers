import 'package:flutter/material.dart';

class SavedOrdersCountRow extends StatelessWidget {
  final int count;
  const SavedOrdersCountRow({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.inventory_2_outlined, color: Color(0xFF616161)),
        const SizedBox(width: 10),
        Text(
          'Orders Found: $count',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ],
    );
  }
}