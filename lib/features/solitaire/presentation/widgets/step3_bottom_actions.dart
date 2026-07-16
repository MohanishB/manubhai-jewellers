import 'package:flutter/material.dart';

class Step3BottomActions extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  final bool viewMode;
  final String? viewingText;

  // ✅ NEW (safe defaults)
  final String confirmText;
  final bool showConfirm;

  const Step3BottomActions({
    super.key,
    required this.onBack,
    required this.onConfirm,
    this.viewMode = false,
    this.viewingText,
    this.confirmText = 'CONFIRM ORDER',
    this.showConfirm = true,
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode) {
      return Row(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF616161),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text(
                  '← BACK TO SAVED ORDERS',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFDFF5E1),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                viewingText ?? 'VIEWING SAVED ORDER',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ✅ Normal mode: Back + (Confirm/Save) button
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF616161),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text(
                '← BACK TO SELECTION',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (showConfirm)
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2E5E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(
                  confirmText.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
      ],
    );
  }
}