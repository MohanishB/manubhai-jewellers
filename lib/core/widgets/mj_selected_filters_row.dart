import 'package:flutter/material.dart';
import 'mj_filter_chip.dart';

class MJSelectedFiltersRow extends StatelessWidget {
  final List<String> filters;
  final ValueChanged<String> onRemove;

  const MJSelectedFiltersRow({
    super.key,
    required this.filters,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters
              .map((f) => MJFilterChip(label: f, onRemove: () => onRemove(f)))
              .toList(),
        ),
      ),
    );
  }
}
