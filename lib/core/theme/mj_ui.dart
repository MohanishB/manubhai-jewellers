import 'package:flutter/material.dart';

class MJColors {
  static const primaryBlue = Color(0xFF0B2E5E); // button color (dark navy)
  static const borderGrey = Color(0xFFBDBDBD);
  static const hintGrey = Color(0xFF616161);
  static const disabledBorder = Color(0xFFE0E0E0);
  static const background = Color(0xFFF7F7F7);
}

class MJSpacing {
  static const fieldGap = 12.0;
  static const sectionGap = 16.0;
}

class MJResponsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static EdgeInsets screenPadding(BuildContext context) {
    final tablet = isTablet(context);
    return EdgeInsets.symmetric(
      horizontal: tablet ? 28 : 16,
      vertical: tablet ? 18 : 14,
    );
  }

  static double maxContentWidth(BuildContext context) =>
      isTablet(context) ? 720 : 520;
}

class MJInputDecorations {
  static const _enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: MJColors.borderGrey, width: 1),
  );

  static const _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: MJColors.borderGrey, width: 1),
  );

  static const _disabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: MJColors.disabledBorder, width: 1),
  );

  static const _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: Colors.red, width: 1),
  );

  static InputDecoration textField({
    required String hintText,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: MJColors.hintGrey, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: contentPadding,
      enabledBorder: _enabledBorder,
      focusedBorder: _focusedBorder,
      disabledBorder: _disabledBorder,
      errorBorder: _errorBorder,
      focusedErrorBorder: _errorBorder,
    );
  }

  static InputDecoration dropdown({
    required String hintText,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: MJColors.hintGrey, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: contentPadding,
      enabledBorder: _enabledBorder,
      focusedBorder: _focusedBorder,
      disabledBorder: _disabledBorder,
      errorBorder: _errorBorder,
      focusedErrorBorder: _errorBorder,
    );
  }
}
