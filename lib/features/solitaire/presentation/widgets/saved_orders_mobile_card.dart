import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import '../saved_orders_screen.dart';

class SavedOrdersMobileCard extends StatelessWidget {
  final SavedOrderVm order;
  final VoidCallback onView;

  const SavedOrdersMobileCard({
    super.key,
    required this.order,
    required this.onView,
  });

  static const _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
  ];

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd-MMM-yyyy HH:mm');

    Widget row(String k, String v, {bool bold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(
                k,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF616161),
                ),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: _shadow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.orderUniqueId,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 8),
          row('Date', fmt.format(order.date)),
          row('Customer', order.customerName),
          row('Phone', order.phone),
          row('Stock', order.stockCode, bold: true),
          row('Diamond Lot', order.diamondLot),
          row('Final Amount', order.finalAmount, bold: true),
          if (order.status != null && order.status!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAF3F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B2E5E),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            width: double.infinity,
            child: MJPrimaryButton(text: "View", onPressed: onView),
            
          ),
        ],
      ),
    );
  }
}