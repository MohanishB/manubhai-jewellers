import 'package:flutter/material.dart';

class MJPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final double? width; // optional override

  const MJPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.height = 48,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ Auto-adjust text size based on screen width
    final double fontSize = screenWidth < 400
        ? 10.5
        : screenWidth < 600
            ? 12.5
            : 13.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = width ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : 300.0);

        final minW = 0.0; // ✅ allows small widths without crashing
        final maxW = effectiveWidth.isFinite ? effectiveWidth : 300.0;
            

        return ConstrainedBox(
          // constraints: BoxConstraints(
          //   minWidth: 80,
          //   maxWidth: effectiveWidth,
          //   minHeight: height,
          //   maxHeight: height,
          // ),
          constraints: BoxConstraints(
            minWidth: minW,
            maxWidth: maxW,
            minHeight: height,
            maxHeight: height,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B2E5E),
              foregroundColor: Colors.white,
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: loading ? null : onPressed,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize, // ✅ now correctly typed
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
