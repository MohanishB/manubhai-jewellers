// import 'package:flutter/material.dart';

// class SavedOrdersHeaderBanner extends StatelessWidget {
//   const SavedOrdersHeaderBanner({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF5A67D8), Color(0xFF7B4DAF)],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.save, color: Colors.white),
//           SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Saved Orders',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'View and manage all saved customer orders',
//                   style: TextStyle(
//                     color: Color(0xEFFFFFFF),
//                     fontSize: 13.5,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


//======================================================//
//======================================================//
//======================================================//

import 'package:flutter/material.dart';

class SavedOrdersHeaderBanner extends StatelessWidget {
  const SavedOrdersHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF5A67D8), Color(0xFF7B4DAF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ align to top
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5), // ✅ tweak to match title baseline
            child: Icon(Icons.save, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ prevents extra height
              children: [
                Text(
                  'Saved Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'View and manage all saved customer orders',
                  style: TextStyle(
                    color: Color(0xEFFFFFFF),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}