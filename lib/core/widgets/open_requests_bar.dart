import 'package:flutter/material.dart';

class OpenRequestsBar extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const OpenRequestsBar({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1E5AA8);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 40,
            width: 220, // matches screenshot-like pill width
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: onTap,
              child: Text(
                '($count) Open Requests',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
