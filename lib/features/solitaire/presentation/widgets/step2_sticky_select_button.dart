import 'package:flutter/material.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';

class Step2StickySelectButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;

  const Step2StickySelectButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Use MJPrimaryButton as requested
    return SizedBox(
      width: 220,
      child: MJPrimaryButton(
        text: 'Select Diamond',
        onPressed: enabled ? onPressed : null,
        height: 48,
      ),
    );
  }
}
