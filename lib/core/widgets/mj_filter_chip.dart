import 'package:flutter/material.dart';

class MJFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const MJFilterChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1E5AA8);
   

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF6), // same family as your light blue
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: blue, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: blue,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.close, size: 16, color: blue),
          ),
        ],
      ),
    );
  }
}
