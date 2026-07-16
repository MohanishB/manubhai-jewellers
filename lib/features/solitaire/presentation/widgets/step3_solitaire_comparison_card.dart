// solitaire/presentation/widgets/step3_solitaire_comparison_card.dart
import 'package:flutter/material.dart';
import 'package:manubhaimlt/features/solitaire/data/models/step3_models.dart';

import 'step3_section_card.dart';

class Step3SolitaireComparisonCard extends StatelessWidget {
  final ComparisonVm original;
  final ComparisonVm selected;

  const Step3SolitaireComparisonCard({
    super.key,
    required this.original,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Step3SectionCard(
      icon: Icons.diamond_outlined,
      title: 'Solitaire Comparison',
      child: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 520;

          if (isNarrow) {
            return Column(
              children: [
                _originalBox(),
                const SizedBox(height: 12),
                const Icon(Icons.arrow_downward, color: Color(0xFF4D6DFF), size: 28),
                const SizedBox(height: 12),
                _selectedBox(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _originalBox()),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward, color: Color(0xFF4D6DFF), size: 28),
              const SizedBox(width: 16),
              Expanded(child: _selectedBox()),
            ],
          );
        },
      ),
    );
  }

  Widget _originalBox() {
    return _boxed(
      border: const Color(0xFFE0B300),
      title: 'Original Solitaire',
      titleIcon: Icons.warning_amber_rounded,
      titleColor: const Color(0xFF7A5C00),
      rows: [
        _kv('Weight', original.weight),
        if (original.showAmount) _kv('Amount', original.amount),
      ],
    );
  }

  // Widget _originalBox() {
  //   return _boxed(
  //     border: const Color(0xFFE0B300),
  //     title: 'Original Solitaire',
  //     titleIcon: Icons.warning_amber_rounded,
  //     titleColor: const Color(0xFF7A5C00),
  //     rows: [
  //       _kv('Weight', original.weight),
  //       _kv('Amount', original.amount),
  //     ],
  //   );
  // }

  Widget _selectedBox() {
    return _boxed(
      border: const Color(0xFF2EAD4A),
      title: 'Selected Solitaire',
      titleIcon: Icons.check_circle,
      titleColor: const Color(0xFF1E6E31),
      rows: [
        if (selected.lotNumber != null) _kv('Lot Number', selected.lotNumber!),
        _kv('Weight', selected.weight),
        _kv('Amount', selected.amount),
        const SizedBox(height: 6),
        _twoCol(
          leftLabel: 'Shape',
          leftValue: selected.shape ?? '-',
          rightLabel: 'Color',
          rightValue: selected.color ?? '-',
        ),
        _twoCol(
          leftLabel: 'Clarity',
          leftValue: selected.clarity ?? '-',
          rightLabel: 'Cut',
          rightValue: selected.cut ?? '-',
        ),
        _twoCol(
          leftLabel: 'Cert',
          leftValue: selected.cert ?? '-',
          rightLabel: 'Cert No',
          rightValue: selected.certNo ?? '-',
        ),
      ],
    );
  }

  Widget _boxed({
    required Color border,
    required String title,
    required IconData titleIcon,
    required Color titleColor,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.6),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(titleIcon, size: 18, color: titleColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w900, color: titleColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(k,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF616161))),
            ),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _twoCol({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text('$leftLabel: ',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF616161))),
                Expanded(
                  child: Text(leftValue, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text('$rightLabel: ',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF616161))),
                Expanded(
                  child: Text(
                    rightValue,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
