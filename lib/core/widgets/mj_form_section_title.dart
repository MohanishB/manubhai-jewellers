import 'package:flutter/material.dart';

class MJFormSectionTitle extends StatelessWidget {
  final String text;
  const MJFormSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
