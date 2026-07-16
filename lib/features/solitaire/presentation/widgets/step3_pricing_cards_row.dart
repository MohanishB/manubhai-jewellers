
// import 'package:flutter/material.dart';
// import 'package:manubhaimlt/features/solitaire/data/models/step3_models.dart';
// import 'step3_section_card.dart';

// class Step3PricingCardsRow extends StatelessWidget {
//   final List<PricingRowVm> originalRows;
//   final String originalTotal;

//   final List<PricingRowVm> finalRows;
//   final String finalTotal;

//   final String? selectedKarat;
//   final String? selectedGoldRate;
//   final String? selectedGoldCost;

//   const Step3PricingCardsRow({
//     super.key,
//     required this.originalRows,
//     required this.originalTotal,
//     required this.finalRows,
//     required this.finalTotal,
//     this.selectedKarat,
//     this.selectedGoldRate,
//     this.selectedGoldCost,
//   });

//   bool get _showSelectedKaratCard =>
//       (selectedKarat ?? '').trim().isNotEmpty ||
//       (selectedGoldRate ?? '').trim().isNotEmpty ||
//       (selectedGoldCost ?? '').trim().isNotEmpty;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, c) {
//         final isTablet = c.maxWidth >= 900;

//         if (!isTablet) {
//           return Column(
//             children: [
//               _originalCard(),
//               const SizedBox(height: 14),
//               _finalCard(),
//             ],
//           );
//         }

//         return Row(
//           children: [
//             Expanded(child: _originalCard()),
//             const SizedBox(width: 14),
//             Expanded(child: _finalCard()),
//           ],
//         );
//       },
//     );
//   }

//   Widget _originalCard() {
//     return Step3SectionCard(
//       icon: Icons.inventory_2_outlined,
//       title: 'Original Ring Pricing',
//       child: _pricingBody(
//         rows: originalRows,
//         total: originalTotal,
//         showFinal: false,
//       ),
//     );
//   }

//   Widget _finalCard() {
//     return Step3SectionCard(
//       leading: const Text(
//         '₹',
//         style: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.w400,
//           color: Color(0xFF0B2E5E),
//           height: 1,
//         ),
//       ),
//       title: 'Final Pricing (With New Solitaire)',
//       child: _pricingBody(
//         rows: finalRows,
//         total: finalTotal,
//         showFinal: true,
//       ),
//     );
//   }

//   Widget _pricingBody({
//     required List<PricingRowVm> rows,
//     required String total,
//     required bool showFinal,
//   }) {
//     return Column(
//       children: [
//         if (showFinal && _showSelectedKaratCard) ...[
//           _selectedKaratSummaryCard(),
//           const SizedBox(height: 16),
//         ],
//         ...rows.map((r) => _row(r.label, r.value)),
//         const SizedBox(height: 14),
//         Row(
//           children: [
//             Text(
//               showFinal ? 'FINAL TOTAL:' : 'Original Total:',
//               style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
//             ),
//             const Spacer(),
//             Text(
//               total,
//               style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _selectedKaratSummaryCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE6F3FF),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: const Color(0xFF42A5F5), width: 1),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Text('🥇', style: TextStyle(fontSize: 18)),
//               const SizedBox(width: 10),
//               const Text(
//                 'Selected Gold Karat:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   color: Color(0xFF1565C0),
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   (selectedKarat ?? '').toUpperCase(),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w900,
//                     color: Color(0xFF1565C0),
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Divider(height: 1),
//           const SizedBox(height: 10),
//           if ((selectedGoldRate ?? '').trim().isNotEmpty)
//             _summaryLine('Gold Rate:', selectedGoldRate!),
//           if ((selectedGoldCost ?? '').trim().isNotEmpty)
//             _summaryLine('Gold Cost:', selectedGoldCost!),
//         ],
//       ),
//     );
//   }

//   Widget _summaryLine(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF616161),
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontWeight: FontWeight.w900),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _row(String label, String value) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF616161),
//                 ),
//               ),
//             ),
//             Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
//           ],
//         ),
//         const SizedBox(height: 10),
//         const Divider(height: 1),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
// }

//=======================================//
//=======================================//
//=======================================//

import 'package:flutter/material.dart';
import 'package:manubhaimlt/features/solitaire/data/models/step3_models.dart';
import 'step3_section_card.dart';

class Step3PricingCardsRow extends StatelessWidget {
  final List<PricingRowVm> originalRows;
  final String originalTotal;

  final List<PricingRowVm> finalRows;
  final String finalTotal;

  final bool showSavedOrderKaratSummary;
  final String? selectedKarat;
  final String? selectedGoldRate;
  final String? selectedGoldCost;

  const Step3PricingCardsRow({
    super.key,
    required this.originalRows,
    required this.originalTotal,
    required this.finalRows,
    required this.finalTotal,
    this.showSavedOrderKaratSummary = false,
    this.selectedKarat,
    this.selectedGoldRate,
    this.selectedGoldCost,
  });

  bool get _showSelectedKaratCard =>
      showSavedOrderKaratSummary &&
      ((selectedKarat ?? '').trim().isNotEmpty ||
          (selectedGoldRate ?? '').trim().isNotEmpty ||
          (selectedGoldCost ?? '').trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isTablet = c.maxWidth >= 900;

        if (!isTablet) {
          return Column(
            children: [
              _originalCard(),
              const SizedBox(height: 14),
              _finalCard(),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _originalCard()),
            const SizedBox(width: 14),
            Expanded(child: _finalCard()),
          ],
        );
      },
    );
  }

  Widget _originalCard() {
    return Step3SectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Original Ring Pricing',
      child: _pricingBody(
        rows: originalRows,
        total: originalTotal,
        showFinal: false,
      ),
    );
  }

  Widget _finalCard() {
    return Step3SectionCard(
      leading: const Text(
        '₹',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Color(0xFF0B2E5E),
          height: 1,
        ),
      ),
      title: 'Final Pricing (With New Solitaire)',
      child: _pricingBody(
        rows: finalRows,
        total: finalTotal,
        showFinal: true,
      ),
    );
  }

  Widget _pricingBody({
    required List<PricingRowVm> rows,
    required String total,
    required bool showFinal,
  }) {
    return Column(
      children: [
        if (showFinal && _showSelectedKaratCard) ...[
          _selectedKaratSummaryCard(),
          const SizedBox(height: 16),
        ],
        ...rows.map((r) => _row(r.label, r.value)),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              showFinal ? 'FINAL TOTAL:' : 'Original Total:',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const Spacer(),
            Text(
              total,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _selectedKaratSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF42A5F5), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🥇', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              const Text(
                'Selected Gold Karat:',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1565C0),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (selectedKarat ?? '').toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1565C0),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          if ((selectedGoldRate ?? '').trim().isNotEmpty)
            _summaryLine('Gold Rate:', selectedGoldRate!),
          if ((selectedGoldCost ?? '').trim().isNotEmpty)
            _summaryLine('Gold Cost:', selectedGoldCost!),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF616161),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF616161),
                ),
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 10),
      ],
    );
  }
}