// import 'package:flutter/material.dart';

// class Step2OriginalProductBanner extends StatelessWidget {
//   final bool isTablet;

//   // ✅ dynamic values (from Step1)
//   final String stockCode;
//   final String solitaireWt; // e.g. "0.28"
//   final String solitaireAmount; // e.g. "49000"
//   final String grossWt; // e.g. "4.710"
//   final String totalAmount; // e.g. "187987"

//   const Step2OriginalProductBanner({
//     super.key,
//     required this.isTablet,
//     required this.stockCode,
//     required this.solitaireWt,
//     required this.solitaireAmount,
//     required this.grossWt,
//     required this.totalAmount,
//   });

//   String _fmtMoney(String raw) {
//     final t = raw.toString().trim();
//     if (t.isEmpty) return '₹0.00';

//     if (t.contains('₹')) return t;
//     if (t.contains(',') || t.contains('.')) return '₹$t';

//     final n = int.tryParse(t) ?? 0;
//     final s = n.toString();
//     final withCommas = s.replaceAllMapped(
//       RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
//       (m) => '${m[1]},',
//     );
//     return '₹$withCommas.00';
//   }

//   String _fmtWt(String raw, {String unit = 'ct'}) {
//     final t = raw.toString().trim();
//     if (t.isEmpty) return '0 $unit';
//     return '$t $unit';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final title = 'Original Product Details - Stock Code: $stockCode';

//     final wtText = _fmtWt(solitaireWt, unit: 'ct');
//     final amtText = _fmtMoney(solitaireAmount);
//     final grossText = _fmtWt(grossWt, unit: 'g');
//     final totalText = _fmtMoney(totalAmount);

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F1D1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0C56A), width: 1.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.inventory_2_outlined,
//                   size: 18, color: Color(0xFF6A5A1A)),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w900,
//                     fontSize: 16,
//                     color: Color(0xFF6A5A1A),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),

//           if (isTablet)
//             Wrap(
//               spacing: 28,
//               runSpacing: 8,
//               alignment: WrapAlignment.start,
//               children: [
//                 _InfoItem(label: 'Original Solitaire Weight', value: wtText),
//                 _InfoItem(label: 'Original Solitaire Amount', value: amtText),
//                 _InfoItem(label: 'Gross Weight', value: grossText),
//                 _InfoItem(label: 'Original Total', value: totalText),
//               ],
//             )
//           else
//             Column(
//               children: [
//                 _InfoLine(label: 'Original Solitaire Weight', value: wtText),
//                 const SizedBox(height: 6),
//                 _InfoLine(label: 'Original Solitaire Amount', value: amtText),
//                 const SizedBox(height: 6),
//                 _InfoLine(label: 'Gross Weight', value: grossText),
//                 const SizedBox(height: 6),
//                 _InfoLine(label: 'Original Total', value: totalText),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _InfoItem extends StatelessWidget {
//   final String label;
//   final String value;

//   const _InfoItem({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: const BoxConstraints(minWidth: 220),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             '$label:',
//             style: const TextStyle(
//               fontWeight: FontWeight.w900,
//               color: Color(0xFF6A5A1A),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.w900,
//               color: Color(0xFF2F2A16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InfoLine extends StatelessWidget {
//   final String label;
//   final String value;

//   const _InfoLine({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             '$label:',
//             style: const TextStyle(
//               fontWeight: FontWeight.w900,
//               color: Color(0xFF6A5A1A),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           value,
//           style: const TextStyle(
//             fontWeight: FontWeight.w900,
//             color: Color(0xFF2F2A16),
//           ),
//         ),
//       ],
//     );
//   }
// }


//========================================//
//========================================//
//========================================//

import 'package:flutter/material.dart';

class Step2OriginalProductBanner extends StatelessWidget {
  final bool isTablet;

  final String stockCode;
  final String solitaireWt;
  final String solitaireAmount;
  final String grossWt;
  final String totalAmount;
  final String lob;

  const Step2OriginalProductBanner({
    super.key,
    required this.isTablet,
    required this.stockCode,
    required this.solitaireWt,
    required this.solitaireAmount,
    required this.grossWt,
    required this.totalAmount,
    required this.lob,
  });

  String _fmtMoney(String raw) {
    final t = raw.toString().trim();
    if (t.isEmpty) return '₹0.00';

    if (t.contains('₹')) return t;
    if (t.contains(',') || t.contains('.')) return '₹$t';

    final n = int.tryParse(t) ?? 0;
    final s = n.toString();
    final withCommas = s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₹$withCommas.00';
  }

  String _fmtWt(String raw, {String unit = 'ct'}) {
    final t = raw.toString().trim();
    if (t.isEmpty) return '0 $unit';
    return '$t $unit';
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Original Product Details - Stock Code: $stockCode';

    final wtText = _fmtWt(solitaireWt, unit: 'ct');
    final amtText = _fmtMoney(solitaireAmount);
    final grossText = _fmtWt(grossWt, unit: 'g');
    final totalText = _fmtMoney(totalAmount);

    final isLg = lob.trim().toUpperCase() == 'LG';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1D1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C56A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: Color(0xFF6A5A1A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF6A5A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (isTablet)
            Wrap(
              spacing: 28,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                _InfoItem(label: 'Original Solitaire Weight', value: wtText),
                _InfoItem(label: 'Gross Weight', value: grossText),
                if (!isLg)
                  _InfoItem(
                    label: 'Original Solitaire Amount',
                    value: amtText,
                  ),
                if (!isLg)
                  _InfoItem(label: 'Original Total', value: totalText),
              ],
            )
          else
            Column(
              children: [
                _InfoLine(label: 'Original Solitaire Weight', value: wtText),
                const SizedBox(height: 6),
                _InfoLine(label: 'Gross Weight', value: grossText),
                if (!isLg) ...[
                  const SizedBox(height: 6),
                  _InfoLine(
                    label: 'Original Solitaire Amount',
                    value: amtText,
                  ),
                  const SizedBox(height: 6),
                  _InfoLine(label: 'Original Total', value: totalText),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF6A5A1A),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2A16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF6A5A1A),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF2F2A16),
          ),
        ),
      ],
    );
  }
}