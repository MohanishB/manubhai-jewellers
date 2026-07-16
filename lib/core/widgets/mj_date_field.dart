import 'package:flutter/material.dart';

class MJDateField extends StatelessWidget {
  final String label;
  final String valueText; // already formatted date, or empty
  final String hintText;
  final VoidCallback onTap;

  final double height;
  final bool flat; // Step2-like

  const MJDateField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
    this.hintText = 'Select date',
    this.height = 48,
    this.flat = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = flat ? 2.0 : 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: const Color(0xFFD9D9D9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueText.isEmpty ? hintText.toUpperCase() : valueText,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: valueText.isEmpty
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF212121),
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month, size: 18, color: Color(0xFF616161)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}