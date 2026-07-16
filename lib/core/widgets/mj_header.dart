// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class MJHeader extends StatelessWidget {
//   final String username;
//   final VoidCallback onLogout;

//   /// Whether to show the Home button (top right)
//   final bool showHome;

//   /// Optional override for home navigation
//   final VoidCallback? onHomePressed;

//   /// ✅ NEW — Whether to show a Back button (top left)
//   final bool showBack;

//   /// ✅ NEW — Custom back navigation handler
//   final VoidCallback? onBackPressed;

//   const MJHeader({
//     super.key,
//     required this.username,
//     required this.onLogout,
//     this.showHome = false,
//     this.onHomePressed,
//     this.showBack = false,
//     this.onBackPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       child: Row(
//         children: [
//           // ✅ Optional Back Button (before logo)
//           if (showBack)
//             Padding(
//               padding: const EdgeInsets.only(right: 10),
//               child: InkWell(
//                 onTap: onBackPressed ?? () => context.pop(),
//                 borderRadius: BorderRadius.circular(8),
//                 child: const Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Color(0xFF1E5AA8),
//                   size: 20,
//                 ),
//               ),
//             ),

//           // MJ Logo
//           Container(
//             width: 38,
//             height: 38,
//             alignment: Alignment.center,
//             child: Image.asset(
//               'assets/images/mj_logo_blue_text.png',
//               height: 28,
//               fit: BoxFit.contain,
//             ),
//           ),

//           const Spacer(),

//           // ✅ Optional Home button (right side)
//           if (showHome)
//             Padding(
//               padding: const EdgeInsets.only(right: 14),
//               child: InkWell(
//                 onTap: onHomePressed ??
//                     () {
//                       context.go('/project');
//                     },
//                 child: Row(
//                   children: const [
//                     Icon(Icons.home_outlined,
//                         color: Color(0xFF1E5AA8), size: 18),
//                     SizedBox(width: 4),
//                     Text(
//                       'Home',
//                       style: TextStyle(
//                         color: Color(0xFF1E5AA8),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           // Welcome message
//           Text(
//             'Welcome, $username',
//             style: const TextStyle(
//               color: Color(0xFF1E5AA8),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(width: 14),

//           // Logout button
//           InkWell(
//             onTap: onLogout,
//             child: const Text(
//               'Logout',
//               style: TextStyle(
//                 color: Color(0xFF1E5AA8),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//================================================//
//================================================//
//================================================//

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MJHeader extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;

  /// Whether to show the Home button (top right)
  final bool showHome;

  /// Optional override for home navigation
  final VoidCallback? onHomePressed;

  /// Whether to show a Back button (top left)
  final bool showBack;

  /// Custom back navigation handler
  final VoidCallback? onBackPressed;

  /// ✅ NEW: Saved Orders action
  final bool showSavedOrders;
  final VoidCallback? onSavedOrdersPressed;

  /// ✅ NEW: Create action
  final bool showCreate;
  final VoidCallback? onCreatePressed;

  const MJHeader({
    super.key,
    required this.username,
    required this.onLogout,
    this.showHome = false,
    this.onHomePressed,
    this.showBack = false,
    this.onBackPressed,

    // ✅ new (default hidden)
    this.showSavedOrders = false,
    this.onSavedOrdersPressed,
    this.showCreate = false,
    this.onCreatePressed,
  });

  Widget _actionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1E5AA8), size: 18),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E5AA8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // ✅ Optional Back Button (before logo)
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: onBackPressed ?? () => context.pop(),
                borderRadius: BorderRadius.circular(8),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF1E5AA8),
                  size: 20,
                ),
              ),
            ),

          // MJ Logo
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/mj_logo_blue_text.png',
              height: 28,
              fit: BoxFit.contain,
            ),
          ),

          const Spacer(),

          // ✅ Optional Home button
          if (showHome)
            _actionButton(
              onTap: onHomePressed ?? () => context.go('/project'),
              icon: Icons.home_outlined,
              label: 'Home',
            ),

          // ✅ NEW: Saved Orders button (after Home)
          if (showSavedOrders)
            _actionButton(
              onTap: onSavedOrdersPressed ?? () => context.go('/saved-orders?refresh=1'),
              icon: Icons.save_outlined,
              label: 'Saved Orders',
            ),

          // ✅ NEW: Create button (after Saved Orders)
          if (showCreate)
            _actionButton(
              onTap: onCreatePressed ?? () => context.go('/solitaire/step1'),
              icon: Icons.add_circle_outline,
              label: 'Create',
            ),

          // Welcome message
          Text(
            'Welcome, $username',
            style: const TextStyle(
              color: Color(0xFF1E5AA8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),

          // Logout button
          InkWell(
            onTap: onLogout,
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF1E5AA8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}