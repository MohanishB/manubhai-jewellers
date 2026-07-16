// import 'package:flutter/material.dart';
// import 'app_colors.dart';
// import 'app_radius.dart';

// ThemeData buildAppTheme() {
//   final base = ThemeData.light(useMaterial3: true);

//   return ThemeData(
//     useMaterial3: true,
//     fontFamily: 'Arial', // ✅ VALID HERE

//     scaffoldBackgroundColor: AppColors.background,
//     colorScheme: base.colorScheme.copyWith(
//       primary: AppColors.brand,
//       surface: AppColors.surface,
//     ),

//     textTheme: base.textTheme.copyWith(
//       titleLarge: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.text),
//       titleMedium: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.text),
//       bodyLarge: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: AppColors.text),
//       bodyMedium: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.text),
//       labelLarge: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
//       labelSmall: const TextStyle(fontWeight: FontWeight.w100, fontSize: 2),
//     ),

//     dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),

//     cardTheme: CardTheme(
//       color: AppColors.surface,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(AppRadius.md),
//         side: const BorderSide(color: AppColors.border),
//       ),
//     ),

//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.brand,
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         textStyle: const TextStyle(fontWeight: FontWeight.w900),
//       ),
//     ),

//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppRadius.md),
//         borderSide: const BorderSide(color: AppColors.border),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppRadius.md),
//         borderSide: const BorderSide(color: AppColors.border),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(AppRadius.md),
//         borderSide: const BorderSide(color: AppColors.brand, width: 2),
//       ),
//       hintStyle: const TextStyle(color: AppColors.textMuted),
//     ),
//   );
// }


import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';

ThemeData buildAppTheme() {
  const fontFamily = 'Arial'; // ✅ single source of truth

  final base = ThemeData.light(useMaterial3: true);

  return ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily, // ✅ global font applied
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.brand,
      surface: AppColors.surface,
    ),

    // ✅ Text theme uses apply() to enforce font + colors globally
    textTheme: base.textTheme
        .apply(
          fontFamily: fontFamily,
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        )
        .copyWith(
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppColors.text,
          ),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
          bodyLarge: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.text,
          ),
          bodyMedium: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.text,
          ),
          labelLarge: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.text,
          ),
          labelSmall: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),

    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),

    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontFamily: fontFamily, // ✅ ensure consistent button font
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.brand, width: 2),
      ),
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
