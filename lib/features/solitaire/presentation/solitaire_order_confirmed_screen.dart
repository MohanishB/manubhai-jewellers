import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/theme/app_colors.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';

class SolitaireOrderConfirmedScreen extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String phone;
  final String stockCode;
  final String selectedDiamondLabel; // e.g. "HRD2" / or cert type+no
  final String diamondSpecs; // e.g. "0.90 ct | G | I1"
  final String weightDiffText; // e.g. "+0.62 ct"
  final String priceDiffText;  // e.g. "+₹2,799.00"
  final String finalTotalText; // e.g. "₹190,786.00"

  const SolitaireOrderConfirmedScreen({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.phone,
    required this.stockCode,
    required this.selectedDiamondLabel,
    required this.diamondSpecs,
    required this.weightDiffText,
    required this.priceDiffText,
    required this.finalTotalText,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final maxW = w >= 1200 ? 820.0 : (w * 0.92);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: _card(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 64, color: Color(0xFF2E9E48)),
          const SizedBox(height: 10),
          const Text(
            'Order Confirmed!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E9E48),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thank you for your order. Your customized ring details have been saved successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF616161)),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Text('Your Order ID', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF616161))),
                const SizedBox(height: 6),
                Text(orderId, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: const [
              Icon(Icons.assignment_outlined, color: Color(0xFF0B2E5E)),
              SizedBox(width: 10),
              Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),

          _kv('Customer Name:', customerName),
          _kv('Phone Number:', phone),
          _kv('Stock Code:', stockCode),
          _kv('Selected Diamond:', selectedDiamondLabel),
          _kv('Diamond Specs:', diamondSpecs),
          _kv('Weight Difference:', weightDiffText, valueColor: const Color(0xFF2E9E48)),
          _kv('Price Difference:', priceDiffText, valueColor: AppColors.danger),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FINAL TOTAL:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2E9E48))),
              Text(finalTotalText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2E9E48))),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.call, size: 18, color: Color(0xFF1976D2)),
                    SizedBox(width: 8),
                    Text("What's Next?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1976D2))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Our team will contact you shortly at $phone to confirm your order details and arrange delivery.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF455A64)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please keep your Order ID handy for reference: $orderId',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF455A64)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: 220,
            height: 46,
            child:MJPrimaryButton(
                  text: 'Create New Order',
                  onPressed: () {
                   context.go('/solitaire/step1');
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(fontWeight: FontWeight.w700))),
          const SizedBox(width: 10),
          Text(v, style: TextStyle(fontWeight: FontWeight.w900, color: valueColor ?? const Color(0xFF212121))),
        ],
      ),
    );
  }
}
