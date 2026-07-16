// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import '../../core/theme/app_colors.dart';

// enum BottomPillBarMode { cse, storeKeeper }

// class BottomPillBar extends StatelessWidget {
//   final int requestSafeCount;
//   final int receivedSafeCount;

//   final VoidCallback onRequestSafe;
//   final VoidCallback onReceivedSafe;
//   final VoidCallback onCustomerExperience;

//   /// Controls layout (CSE or Storekeeper mode)
//   final BottomPillBarMode mode;

//   const BottomPillBar({
//     super.key,
//     required this.requestSafeCount,
//     required this.receivedSafeCount,
//     required this.onRequestSafe,
//     required this.onReceivedSafe,
//     required this.onCustomerExperience,
//     this.mode = BottomPillBarMode.cse,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     final t = Theme.of(context);

//     return SafeArea(
//       top: false,
//       child: Container(
//         height: 70,
//         color: Colors.transparent,
//         padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
//         child: mode == BottomPillBarMode.storeKeeper
//             ? Row(
//                 children: [
//                   SizedBox(
//                     width: 210,
//                     child: _pill(
//                       context,
//                        label:
//                           '(${requestSafeCount}) Open Requests', // localized}',
//                       // label:
//                       //     '(${requestSafeCount}) ${l10n.openRequests(requestSafeCount)}',
//                       enabled: true,
//                       primary: true,
//                       onTap: onRequestSafe,
//                     ),
//                   ),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: _pill(
//                       context,
//                       // label:
//                       //     '(${requestSafeCount}) ${l10n.requestSafe}', // localized
//                       label:
//                           '(${requestSafeCount}) Request from safe',
//                       enabled: requestSafeCount > 0,
//                       //  enabled: true,
//                       primary: requestSafeCount > 0,
//                       onTap: onRequestSafe,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _pill(
//                       context,
//                         label:
//                           l10n.receivedSafe, // localized
//                       // label:
//                       //     '(${receivedSafeCount})\n${l10n.receivedSafe}', // localized
//                       // enabled: receivedSafeCount > 0,
//                       enabled: true,
//                       primary: true,
//                       onTap: onReceivedSafe,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _pill(
//                       context,
//                       label: l10n.customerExperience, // example localization usage
//                       enabled: true,
//                       primary: true,
//                       onTap: onCustomerExperience,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//    Widget _pill(
//     BuildContext context, {
//     required String label,
//     required bool enabled,
//     required bool primary,
//     required VoidCallback onTap,
//   }) {
//     final t = Theme.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;

//     // ✅ Use a single global responsive font size
//     final double fontSize = screenWidth < 360
//         ? 9.5
//         : screenWidth < 420
//             ? 10.5
//             : screenWidth < 600
//                 ? 12.0
//                 : 13.0;

//     final double height = screenWidth < 360
//         ? 40
//         : screenWidth < 600
//             ? 46
//             : 48;

//     final Color bg = primary
//         ? AppColors.brand
//         : (enabled ? AppColors.brand : AppColors.surfaceDisabled);

//     final Color fg = primary
//         ? Colors.white
//         : (enabled ? AppColors.brand : AppColors.textDisabled);

//     return InkWell(
//       onTap: enabled ? onTap : null,
//       child: Container(
//         height: height,
//         padding: const EdgeInsets.symmetric(horizontal: 6),
//         decoration: BoxDecoration(color: bg),
//         alignment: Alignment.center,
//         // ✅ Auto-size text safely across screen widths
//         child: FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             label.toUpperCase(),
//             textAlign: TextAlign.center,
//             style: t.textTheme.bodyMedium?.copyWith(
//               color: fg,
//               fontWeight: FontWeight.w800,
//               fontSize: fontSize,
//               letterSpacing: 0.8,
//             ),
//           ),
//         ),
//       ),
//     );
//   }



// //   Widget _pill(
// //   BuildContext context, {
// //   required String label,
// //   required bool enabled,
// //   required bool primary,
// //   required VoidCallback onTap,
// // }) {
// //   final t = Theme.of(context);

// //   final Color bg = primary
// //       ? AppColors.brand
// //       : (enabled ? AppColors.brand : AppColors.surfaceDisabled);

// //   final Color fg = primary
// //       ? Colors.white
// //       : (enabled ? AppColors.brand : AppColors.textDisabled);

// //   return InkWell(
  
// //     onTap: enabled ? onTap : null,
// //     child: Container(
// //       height: 48,
// //       decoration: BoxDecoration(
// //         color: bg,
 
// //       ),
// //       alignment: Alignment.center,
// //       child: Text(
// //         label.toUpperCase(), // ✅ Always caps (UI rule)
// //         textAlign: TextAlign.center,
// //         // style: t.textTheme.titleMedium,
// //         style: t.textTheme.bodyMedium?.copyWith(
// //           color: fg,
// //           // fontFamily: t.textTheme.labelSmall?.fontFamily,  
// //           // fontWeight: FontWeight.w800,
// //         ),
// //         // ),
// //       ),
// //     ),
// //   );
// // }

// }

//==============================================================//
//==============================================================//
//==============================================================//

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BottomPillBarMode { cse, storeKeeper }

class BottomPillBar extends StatelessWidget {
  final int requestSafeCount;
  final int receivedSafeCount;

  final VoidCallback onRequestSafe;
  final VoidCallback onMyRequestList; 
  final VoidCallback onReceivedSafe;
  final VoidCallback onCustomerExperience;

  /// Controls layout (CSE or Storekeeper mode)
  final BottomPillBarMode mode;

  const BottomPillBar({
    super.key,
    required this.requestSafeCount,
    required this.receivedSafeCount,
    required this.onRequestSafe,
    required this.onMyRequestList, 
    required this.onReceivedSafe,
    required this.onCustomerExperience,
    this.mode = BottomPillBarMode.cse,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: mode == BottomPillBarMode.storeKeeper
            ? Row(
                children: [
                  SizedBox(
                    width: 210,
                    child: _pill(
                      context,
                      label: '(${requestSafeCount}) Open Requests',
                      icon: Icons.inbox_outlined,
                      enabled: true,
                      primary: true,
                      onTap: onRequestSafe,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _pill(
                      context,
                      label: '(${requestSafeCount}) Request from safe',
                      icon: Icons.shopping_bag_outlined,
                      enabled: requestSafeCount > 0,
                      primary: requestSafeCount > 0,
                      onTap: onRequestSafe,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ✅ NEW BUTTON (2nd place)
                  Expanded(
                    child: _pill(
                      context,
                      label: 'My request list',
                      icon: Icons.list_alt_outlined,
                      enabled: true,
                      primary: true,
                      onTap: onMyRequestList,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Expanded(
                  //   child: _pill(
                  //     context,
                  //     // label: '(${receivedSafeCount}) Received from safe',
                  //     label: 'Received from safe',
                  //     icon: Icons.inventory_2_outlined,
                  //     enabled: true,
                  //     primary: true,
                  //     onTap: onReceivedSafe,
                  //   ),
                  // ),
                  // const SizedBox(width: 10),

                  Expanded(
                    child: _pill(
                      context,
                      label: 'Feedback',
                      icon: Icons.feedback_outlined,
                      enabled: true,
                      primary: true,
                      onTap: onCustomerExperience,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _pill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool enabled,
    required bool primary,
    required VoidCallback onTap,
  }) {
    final t = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ responsive font size
    final double fontSize = screenWidth < 360
        ? 9.5
        : screenWidth < 420
            ? 10.5
            : screenWidth < 600
                ? 12.0
                : 13.0;

    final double height = screenWidth < 360
        ? 40
        : screenWidth < 600
            ? 46
            : 48;

    final Color bg = primary
        ? AppColors.brand
        : (enabled ? AppColors.brand : AppColors.surfaceDisabled);

    final Color fg = primary
        ? Colors.white
        : (enabled ? AppColors.brand : AppColors.textDisabled);

    // ✅ icon size balanced with text
    final double iconSize = screenWidth < 360
        ? 14
        : screenWidth < 600
            ? 16
            : 18;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(color: bg),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: fg),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
