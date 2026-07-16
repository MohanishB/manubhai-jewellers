// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
// import '../saved_orders_screen.dart';

// class SavedOrdersTable extends StatelessWidget {
//   final List<SavedOrderVm> rows;
//   final ValueChanged<SavedOrderVm> onView;

//   const SavedOrdersTable({
//     super.key,
//     required this.rows,
//     required this.onView,
//   });

//   static const _shadow = [
//     BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
//   ];

//   static const _headerBg = Color(0xFF5A67D8);
//   static const _primary = Color(0xFF0B2E5E);

//   @override
//   Widget build(BuildContext context) {
//     final fmt = DateFormat('dd-MMM-yyyy HH:mm');

//     Widget headerCell(String text) => Text(
//           text,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w900,
//             fontSize: 12,
//           ),
//         );

//     TextStyle cellStyle({FontWeight fw = FontWeight.w700, Color? c}) => TextStyle(
//           fontWeight: fw,
//           fontSize: 12,
//           color: c ?? const Color(0xFF212121),
//         );

//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: _shadow,
//       ),
//       child: Column(
//         children: [
//           // header
//           Container(
//             height: 46,
//             color: _headerBg,
//             child: Row(
//               children: [
//                 const SizedBox(width: 16),
//                 Expanded(flex: 4, child: headerCell('ORDER ID')),
//                 Expanded(flex: 3, child: Center(child: headerCell('DATE'))),
//                 Expanded(flex: 3, child: Center(child: headerCell('CUSTOMER NAME'))),
//                 Expanded(flex: 3, child: Center(child: headerCell('PHONE'))),
//                 Expanded(flex: 2, child: Center(child: headerCell('STOCK CODE'))),
//                 Expanded(flex: 2, child: Center(child: headerCell('DIAMOND LOT'))),
//                 Expanded(flex: 3, child: Center(child: headerCell('FINAL AMOUNT'))),
//                 Expanded(flex: 2, child: Center(child: headerCell('STATUS'))),
//                 Expanded(flex: 2, child: Center(child: headerCell('ACTION'))),
//                 const SizedBox(width: 16),
//               ],
//             ),
//           ),

//           // rows
//           ListView.separated(
//             itemCount: rows.length,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             separatorBuilder: (_, __) => const Divider(height: 1),
//             itemBuilder: (_, i) {
//               final r = rows[i];

//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 16),
//                     Expanded(
//                       flex: 4,
//                       child: Text(r.orderUniqueId, style: cellStyle(fw: FontWeight.w900)),
//                     ),
//                     Expanded(
//                       flex: 3,
//                       child: Center(child: Text(fmt.format(r.date), style: cellStyle())),
//                     ),
//                     Expanded(
//                       flex: 3,
//                       child: Center(child: Text(r.customerName, style: cellStyle())),
//                     ),
//                     Expanded(
//                       flex: 3,
//                       child: Center(child: Text(r.phone, style: cellStyle())),
//                     ),
//                     Expanded(
//                       flex: 2,
//                       child: Center(child: Text(r.stockCode, style: cellStyle(fw: FontWeight.w900))),
//                     ),
//                     Expanded(
//                       flex: 2,
//                       child: Center(child: Text(r.diamondLot, style: cellStyle())),
//                     ),
//                     Expanded(
//                       flex: 3,
//                       child: Center(child: Text(r.finalAmount, style: cellStyle(fw: FontWeight.w900))),
//                     ),
//                     Expanded(
//                       flex: 2,
//                       child: Center(
//                         child: r.status == null || r.status!.trim().isEmpty
//                             ? const SizedBox.shrink()
//                             : _statusPill(r.status!),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 2,
//                       child: Center(
//                         child: SizedBox(
//                           height: 36,
//                           child: MJPrimaryButton(text: "View", onPressed: () => onView(r)),
                          
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statusPill(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: const Color(0xFFDAF3F6),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text.toUpperCase(),
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w900,
//           color: _primary,
//         ),
//       ),
//     );
//   }
// }

//======================================================//
//======================================================//
//======================================================//

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import '../saved_orders_screen.dart';

class SavedOrdersTable extends StatelessWidget {
  final List<SavedOrderVm> rows;
  final ValueChanged<SavedOrderVm> onView;

  const SavedOrdersTable({
    super.key,
    required this.rows,
    required this.onView,
  });

  static const _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
  ];

  static const _headerBg = Color(0xFF5A67D8);
  static const _primary = Color(0xFF0B2E5E);

  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd-MMM-yyyy HH:mm');

    Widget headerCell(String text) => Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        );

    TextStyle cellStyle({FontWeight fw = FontWeight.w700, Color? c}) => TextStyle(
          fontWeight: fw,
          fontSize: 12,
          color: c ?? const Color(0xFF212121),
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius), // ✅ rounded container
        boxShadow: _shadow,
      ),
      clipBehavior: Clip.antiAlias, // ✅ clips rows/header to rounded edges
      child: Column(
        children: [
          // ✅ header with rounded TOP corners
          Container(
            height: 46,
            decoration: const BoxDecoration(
              color: _headerBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_radius),
                topRight: Radius.circular(_radius),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(flex: 4, child: headerCell('ORDER ID')),
                Expanded(flex: 3, child: Center(child: headerCell('DATE'))),
                Expanded(flex: 3, child: Center(child: headerCell('CUSTOMER NAME'))),
                Expanded(flex: 3, child: Center(child: headerCell('PHONE'))),
                Expanded(flex: 2, child: Center(child: headerCell('STOCK CODE'))),
                Expanded(flex: 2, child: Center(child: headerCell('DIAMOND LOT'))),
                Expanded(flex: 3, child: Center(child: headerCell('FINAL AMOUNT'))),
                Expanded(flex: 2, child: Center(child: headerCell('STATUS'))),
                Expanded(flex: 2, child: Center(child: headerCell('ACTION'))),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // ✅ rows
          ListView.separated(
            itemCount: rows.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = rows[i];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Text(
                        r.orderUniqueId,
                        style: cellStyle(fw: FontWeight.w900),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(child: Text(fmt.format(r.date), style: cellStyle())),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(child: Text(r.customerName, style: cellStyle())),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(child: Text(r.phone, style: cellStyle())),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(r.stockCode, style: cellStyle(fw: FontWeight.w900)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(child: Text(r.diamondLot, style: cellStyle())),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(r.finalAmount, style: cellStyle(fw: FontWeight.w900)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: (r.status == null || r.status!.trim().isEmpty)
                            ? const SizedBox.shrink()
                            : _statusPill(r.status!),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: SizedBox(
                          height: 36,
                          child: MJPrimaryButton(
                            text: "View",
                            onPressed: () => onView(r),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDAF3F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: _primary,
        ),
      ),
    );
  }
}