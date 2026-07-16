// solitaire/presentation/widgets/step3_section_card.dart
import 'package:flutter/material.dart';

class Step3SectionCard extends StatelessWidget {
  final Widget? leading;        // ✅ new
  final IconData? icon;         // keep for backward compatibility
  final String title;
  final Widget child;

  const Step3SectionCard({
    super.key,
    this.leading,
    this.icon,
    required this.title,
    required this.child,
  }) : assert(leading != null || icon != null,
            'Provide either leading or icon');

  static const _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
  ];

  @override
  Widget build(BuildContext context) {
    final Widget leadingWidget = leading ??
        Icon(icon!, color: const Color(0xFF0B2E5E));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leadingWidget,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}