// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';
// import '../theme/app_radius.dart';
// import '../theme/app_spacing.dart';

// class MJSearchField extends StatefulWidget {
//   final TextEditingController? controller;
//   final String hintText;
//   final ValueChanged<String>? onChanged;
//   final VoidCallback? onClear;
//   final bool autoFocus;
//   final EdgeInsets? padding;
//   final FocusNode? focusNode;
//   final int debounceMs;
//   final int minCharsToSearch; 

//   const MJSearchField({
//     super.key,
//     this.controller,
//     this.hintText = 'Search...',
//     this.onChanged,
//     this.onClear,
//     this.autoFocus = false,
//     this.padding,
//     this.focusNode,
//     this.debounceMs = 300,
//     this.minCharsToSearch = 1, 
//   });

//   @override
//   State<MJSearchField> createState() => _MJSearchFieldState();
// }

// class _MJSearchFieldState extends State<MJSearchField> {
//   Timer? _debounce;

//   void _onChangedHandler(String value) {
//     // ✅ refresh suffix icon instantly while typing
//     if (mounted) setState(() {});

//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
//       final v = value.trim();

//       // ✅ always allow clearing search
//       if (v.isEmpty) {
//         widget.onChanged?.call('');
//         return;
//       }

//       // ✅ start search only when min chars reached
//       if (v.length >= widget.minCharsToSearch) {
//         widget.onChanged?.call(value);
//       }
//       // else: do nothing (keeps old results until user types more)
//     });
//   }

//   // void _onChangedHandler(String value) {
//   //   if (_debounce?.isActive ?? false) _debounce?.cancel();
//   //   _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
//   //     widget.onChanged?.call(value);
//   //   });
//   // }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = Theme.of(context);
//     final c = widget.controller ?? TextEditingController();

//     return Padding(
//       padding:
//           widget.padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           // ✅ if unbounded width, fallback to max 600px
//           final effectiveWidth = constraints.maxWidth.isFinite
//               ? constraints.maxWidth
//               : 600.0;

//           return Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: effectiveWidth),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.surface,
//                   borderRadius: BorderRadius.circular(AppRadius.lg),
//                   border: Border.all(color: AppColors.border),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color(0x14000000),
//                       blurRadius: 8,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: c,
//                   focusNode: widget.focusNode,
//                   autofocus: widget.autoFocus,
//                   onChanged: _onChangedHandler,
//                   style: t.textTheme.bodyMedium?.copyWith(
//                     color: AppColors.text,
//                     fontWeight: FontWeight.w500,
//                     fontFamily: t.textTheme.bodyMedium?.fontFamily,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: widget.hintText.toUpperCase(),
//                     hintStyle: t.textTheme.bodyMedium?.copyWith(
//                       color: AppColors.textMuted,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.3,
//                     ),
//                     prefixIcon:
//                         const Icon(Icons.search, color: AppColors.textMuted),
//                     suffixIcon: (c.text.isNotEmpty)
//                         ? IconButton(
//                             icon: const Icon(Icons.close,
//                                 color: AppColors.textMuted),
//                             onPressed: widget.onClear ??
//                                 () {
//                                   c.clear();
//                                   widget.onChanged?.call('');
//                                   setState(() {}); // refresh icon
//                                 },
//                           )
//                         : null,
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: AppSpacing.sm,
//                       horizontal: AppSpacing.md,
//                     ),
//                   ),
//                   onTap: () => setState(() {}),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

//==================================================//
//==================================================//
//==================================================//

import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

enum MJSearchFieldVariant {
  defaultBox, // current (rounded + shadow + search icon)
  flat,       // ✅ new (Step2-like: flat border, no shadow)
}

class MJSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autoFocus;
  final EdgeInsets? padding;
  final FocusNode? focusNode;
  final int debounceMs;
  final int minCharsToSearch;

  /// ✅ NEW: look & feel
  final MJSearchFieldVariant variant;

  /// ✅ NEW: show/hide prefix search icon (default true for old screens)
  final bool showPrefixIcon;

  /// ✅ NEW: override height for flat inputs
  final double height;

  const MJSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.autoFocus = false,
    this.padding,
    this.focusNode,
    this.debounceMs = 300,
    this.minCharsToSearch = 1,

    // ✅ NEW defaults keep existing UI unchanged
    this.variant = MJSearchFieldVariant.defaultBox,
    this.showPrefixIcon = true,
    this.height = 48,
  });

  @override
  State<MJSearchField> createState() => _MJSearchFieldState();
}

class _MJSearchFieldState extends State<MJSearchField> {
  Timer? _debounce;

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MJSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }
  }

  void _onChangedHandler(String value) {
    if (mounted) setState(() {});

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      final v = value.trim();

      if (v.isEmpty) {
        widget.onChanged?.call('');
        return;
      }

      if (v.length >= widget.minCharsToSearch) {
        widget.onChanged?.call(value);
      }
    });
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = widget.controller ?? TextEditingController();

    final isFlat = widget.variant == MJSearchFieldVariant.flat;

    final borderRadius = isFlat ? 2.0 : AppRadius.lg.toDouble();
    final borderColor = isFlat ? const Color(0xFFD9D9D9) : AppColors.border;

    final boxShadow = isFlat
        ? const <BoxShadow>[]
        : const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ];

    // NOTE: For flat inputs, we usually don't want extra horizontal padding wrapper
    final effectivePadding =
        widget.padding ?? (isFlat ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: AppSpacing.md));

    return Padding(
      padding: effectivePadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveWidth =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: effectiveWidth),
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: borderColor),
                  boxShadow: boxShadow,
                ),
                child: TextField(
                  controller: c,
                  focusNode: widget.focusNode,
                  autofocus: widget.autoFocus,
                  onChanged: _onChangedHandler,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontFamily: t.textTheme.bodyMedium?.fontFamily,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText.toUpperCase(),
                    hintStyle: t.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      fontSize: 12,
                    ),

                    // ✅ prevents theme border from drawing
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,

                    // ✅ avoids extra outline / fill from theme
                    filled: false,
                    fillColor: Colors.transparent,

                    isDense: true,
                    prefixIcon: widget.showPrefixIcon
                        ? const Icon(Icons.search, color: AppColors.textMuted)
                        : null,
                    suffixIcon: (c.text.isNotEmpty)
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textMuted),
                            onPressed: widget.onClear ??
                                () {
                                  c.clear();
                                  widget.onChanged?.call('');
                                  setState(() {});
                                },
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isFlat ? 12 : AppSpacing.sm,
                      horizontal: isFlat ? 12 : AppSpacing.md,
                    ),
                  ),
                  // decoration: InputDecoration(
                  //   hintText: widget.hintText.toUpperCase(),
                  //   hintStyle: t.textTheme.bodyMedium?.copyWith(
                  //     color: AppColors.textMuted,
                  //     fontWeight: FontWeight.w700,
                  //     letterSpacing: 0.3,
                  //     fontSize: 12,
                  //   ),
                  //   prefixIcon: widget.showPrefixIcon
                  //       ? const Icon(Icons.search, color: AppColors.textMuted)
                  //       : null,
                  //   suffixIcon: (c.text.isNotEmpty)
                  //       ? IconButton(
                  //           icon: const Icon(Icons.close,
                  //               color: AppColors.textMuted),
                  //           onPressed: widget.onClear ??
                  //               () {
                  //                 c.clear();
                  //                 widget.onChanged?.call('');
                  //                 setState(() {});
                  //               },
                  //         )
                  //       : null,
                  //   border: InputBorder.none,
                  //   isDense: true,
                  //   contentPadding: EdgeInsets.symmetric(
                  //     vertical: isFlat ? 12 : AppSpacing.sm,
                  //     horizontal: isFlat ? 12 : AppSpacing.md,
                  //   ),
                  // ),
                  onTap: () => setState(() {}),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
