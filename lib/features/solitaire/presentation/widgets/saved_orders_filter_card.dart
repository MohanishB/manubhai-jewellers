// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
// import 'package:manubhaimlt/core/widgets/mj_search_field.dart';
// import 'package:manubhaimlt/core/theme/app_spacing.dart';

// class SavedOrdersFilterCard extends StatelessWidget {
//   final bool isTablet;

//   final DateTime? fromDate;
//   final DateTime? toDate;
//   final TextEditingController nameCtrl;
//   final TextEditingController phoneCtrl;

//   final VoidCallback onPickFromDate;
//   final VoidCallback onPickToDate;
//   final VoidCallback onApply;
//   final VoidCallback onClear;

//   const SavedOrdersFilterCard({
//     super.key,
//     required this.isTablet,
//     required this.fromDate,
//     required this.toDate,
//     required this.nameCtrl,
//     required this.phoneCtrl,
//     required this.onPickFromDate,
//     required this.onPickToDate,
//     required this.onApply,
//     required this.onClear,
//   });

//   static const _shadow = [
//     BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
//   ];

//   String _fmt(DateTime? d) {
//     if (d == null) return '';
//     return DateFormat('dd/MM/yyyy').format(d);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final fromText = _fmt(fromDate);
//     final toText = _fmt(toDate);

//     final dateField = (
//       String label,
//       String value,
//       VoidCallback onTap,
//     ) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.w800),
//           ),
//           const SizedBox(height: 8),
//           InkWell(
//             onTap: onTap,
//             child: Container(
//               height: 48,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: const Color(0xFFD9D9D9)),
//                 color: Colors.white,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       value.isEmpty ? 'Select date' : value,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w700,
//                         color: value.isEmpty
//                             ? const Color(0xFF9E9E9E)
//                             : const Color(0xFF212121),
//                       ),
//                     ),
//                   ),
//                   const Icon(Icons.calendar_month, size: 18),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       );
//     };

//     final content = isTablet
//         ? Row(
//             children: [
//               Expanded(child: dateField('From Date', fromText, onPickFromDate)),
//               const SizedBox(width: 14),
//               Expanded(child: dateField('To Date', toText, onPickToDate)),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Customer Name',
//                         style: TextStyle(fontWeight: FontWeight.w800)),
//                     const SizedBox(height: 8),
//                     MJSearchField(
//                       controller: nameCtrl,
//                       hintText: 'Search by name...',
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Phone Number',
//                         style: TextStyle(fontWeight: FontWeight.w800)),
//                     const SizedBox(height: 8),
//                     MJSearchField(
//                       controller: phoneCtrl,
//                       hintText: 'Search by phone...',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           )
//         : Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               dateField('From Date', fromText, onPickFromDate),
//               const SizedBox(height: 12),
//               dateField('To Date', toText, onPickToDate),
//               const SizedBox(height: 12),
//               const Text('Customer Name',
//                   style: TextStyle(fontWeight: FontWeight.w800)),
//               const SizedBox(height: 8),
//               MJSearchField(controller: nameCtrl, hintText: 'Search by name...'),
//               const SizedBox(height: 12),
//               const Text('Phone Number',
//                   style: TextStyle(fontWeight: FontWeight.w800)),
//               const SizedBox(height: 8),
//               MJSearchField(
//                   controller: phoneCtrl, hintText: 'Search by phone...'),
//             ],
//           );

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: _shadow,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.search, color: Color(0xFF0B2E5E)),
//               SizedBox(width: 10),
//               Text(
//                 'Filter Orders',
//                 style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           content,
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               SizedBox(
//                 height: 46,
//                 child: MJPrimaryButton(
//                   text: 'APPLY FILTERS',
//                   onPressed: onApply,
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.sm),
//               // SizedBox(
//               //   height: 46,
//               //   child: OutlinedButton(
//               //     onPressed: onClear,
//               //     style: OutlinedButton.styleFrom(
//               //       side: const BorderSide(color: Color(0xFF8E8E8E)),
//               //       foregroundColor: const Color(0xFF424242),
//               //       padding: const EdgeInsets.symmetric(horizontal: 18),
//               //     ),
//               //     child: const Text(
//               //       'CLEAR FILTERS',
//               //       style: TextStyle(fontWeight: FontWeight.w900),
//               //     ),
//               //   ),
//               // ),
//                SizedBox(
//                 height: 46,
//                 // child: OutlinedButton(
//                   // onPressed: onClear,
//                   // style: OutlinedButton.styleFrom(
//                   //   side: const BorderSide(color: Color(0xFF8E8E8E)),
//                   //   foregroundColor: const Color(0xFF424242),
//                   //   padding: const EdgeInsets.symmetric(horizontal: 18),
//                   // ),
//                   child: _actionButton(
//                     text: 'Clear Filters',
//                     onPressed: onClear,
//                     bg: const Color(0xFF616161),
//                   ),
//                 // ),
//               ),
              
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _actionButton({
//     required String text,
//     required VoidCallback onPressed,
//     required Color bg,
//   }) {
//     return SizedBox(
//       height: 46,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: bg,
//           foregroundColor: Colors.white,
//           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//           elevation: 0,
//         ),
//         onPressed: onPressed,
//         child: Text(text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
//       ),
//     );
//   }
// }

//============================================================//
//============================================================//
//============================================================//

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_search_field.dart';
import 'package:manubhaimlt/core/widgets/mj_date_field.dart';
import 'package:manubhaimlt/core/theme/app_spacing.dart';

class SavedOrdersFilterCard extends StatelessWidget {
  final bool isTablet;

  final DateTime? fromDate;
  final DateTime? toDate;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;

  final VoidCallback onPickFromDate;
  final VoidCallback onPickToDate;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const SavedOrdersFilterCard({
    super.key,
    required this.isTablet,
    required this.fromDate,
    required this.toDate,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.onPickFromDate,
    required this.onPickToDate,
    required this.onApply,
    required this.onClear,
  });

  static const _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
  ];

  String _fmt(DateTime? d) {
    if (d == null) return '';
    return DateFormat('dd/MM/yyyy').format(d);
  }

  TextStyle _labelStyle() =>
      const TextStyle(fontWeight: FontWeight.w800, fontSize: 12);

  Widget _labeled(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromText = _fmt(fromDate);
    final toText = _fmt(toDate);

    final nameField = _labeled(
      'Customer Name',
      MJSearchField(
        controller: nameCtrl,
        hintText: 'Search by name...',
        variant: MJSearchFieldVariant.flat,
        showPrefixIcon: false,
        padding: EdgeInsets.zero,
        height: 44,
      ),
    );

    final phoneField = _labeled(
      'Phone Number',
      MJSearchField(
        controller: phoneCtrl,
        hintText: 'Search by phone...',
        variant: MJSearchFieldVariant.flat,
        showPrefixIcon: false,
        padding: EdgeInsets.zero,
        height: 44,
      ),
    );

    final content = isTablet
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MJDateField(
                  label: 'From Date',
                  valueText: fromText,
                  onTap: onPickFromDate,
                  height: 44,
                  flat: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: MJDateField(
                  label: 'To Date',
                  valueText: toText,
                  onTap: onPickToDate,
                  height: 44,
                  flat: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: nameField),
              const SizedBox(width: 14),
              Expanded(child: phoneField),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MJDateField(
                label: 'From Date',
                valueText: fromText,
                onTap: onPickFromDate,
                height: 44,
                flat: true,
              ),
              const SizedBox(height: 12),
              MJDateField(
                label: 'To Date',
                valueText: toText,
                onTap: onPickToDate,
                height: 44,
                flat: true,
              ),
              const SizedBox(height: 12),
              nameField,
              const SizedBox(height: 12),
              phoneField,
            ],
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: _shadow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.search, color: Color(0xFF0B2E5E)),
              SizedBox(width: 10),
              Text(
                'Filter Orders',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          content,
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                height: 46,
                child: MJPrimaryButton(
                  text: 'APPLY FILTERS',
                  onPressed: onApply,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                height: 46,
                child: _actionButton(
                  text: 'Clear Filters',
                  onPressed: onClear,
                  bg: const Color(0xFF616161),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required VoidCallback onPressed,
    required Color bg,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}