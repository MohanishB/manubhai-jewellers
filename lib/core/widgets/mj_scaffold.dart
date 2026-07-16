// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:manubhaimlt/app/router.dart';
// import 'mj_header.dart';
// import 'bottom_pill_bar.dart';
// import 'filter_drawer.dart';

// class MJScaffold extends StatelessWidget {
//   final String username;
//   final VoidCallback onLogout;
//   final Widget body;

//   final int requestSafeCount;
//   final int receivedSafeCount;

//   final VoidCallback onRequestSafe;
//   final VoidCallback onReceivedSafe;
//   final VoidCallback onCustomerExperience;

//   // ✅ NEW
//   final BottomPillBarMode bottomMode;

//   const MJScaffold({
//     super.key,
//     required this.username,
//     required this.onLogout,
//     required this.body,
//     required this.requestSafeCount,
//     required this.receivedSafeCount,
//     required this.onRequestSafe,
//     required this.onReceivedSafe,
//     required this.onCustomerExperience,
//     this.bottomMode = BottomPillBarMode.cse,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const FilterDrawer(),
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             // MJHeader(username: username, onLogout: onLogout),
//             MJHeader(
//               username: username, onLogout: onLogout,
//               showHome: true,

//               // ✅ Navigate to project selection
//               onHomePressed: () {
//                 // context.go('/project');
//                 rootNavigatorKey.currentContext?.go('/project');

//               },
//             ),
//             const Divider(height: 1),
//             Expanded(child: body),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomPillBar(
//         mode: bottomMode, // ✅ important
//         requestSafeCount: requestSafeCount,
//         receivedSafeCount: receivedSafeCount,
//         onRequestSafe: onRequestSafe,
//         onReceivedSafe: onReceivedSafe,
//         onCustomerExperience: onCustomerExperience, 
//       ),
//     );
//   }
// }

//============================================


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/app/router.dart';
import 'mj_header.dart';
import 'bottom_pill_bar.dart';
import 'filter_drawer.dart';

class MJScaffold extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;
  final Widget body;

  final int requestSafeCount;
  final int receivedSafeCount;

  final VoidCallback onRequestSafe;
  final VoidCallback onRequestedList;
  final VoidCallback onReceivedSafe;
  final VoidCallback onCustomerExperience;

  final BottomPillBarMode bottomMode;

  /// ✅ NEW optional parameters for back/home customization
  final bool showHome;
  final VoidCallback? onHomePressed;

  final bool showBack;
  final VoidCallback? onBackPressed;

  const MJScaffold({
    super.key,
    required this.username,
    required this.onLogout,
    required this.body,
    required this.requestSafeCount,
    required this.onRequestedList,
    required this.receivedSafeCount,
    required this.onRequestSafe,
    required this.onReceivedSafe,
    required this.onCustomerExperience,
    this.bottomMode = BottomPillBarMode.cse,
    this.showHome = false,
    this.onHomePressed,
    this.showBack = false,
    this.onBackPressed, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FilterDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MJHeader(
              username: username,
              onLogout: onLogout,

              // ✅ pass through both Back & Home
              showHome: showHome,
              onHomePressed: onHomePressed ??
                  () {
                    rootNavigatorKey.currentContext?.go('/project');
                  },
              showBack: showBack,
              onBackPressed: onBackPressed,
            ),
            const Divider(height: 1),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: BottomPillBar(
        mode: bottomMode,
        requestSafeCount: requestSafeCount,
        receivedSafeCount: receivedSafeCount,
        onRequestSafe: onRequestSafe,
        onReceivedSafe: onReceivedSafe,
        onCustomerExperience: onCustomerExperience, 
        onMyRequestList: onRequestedList,
      ),
    );
  }
}
