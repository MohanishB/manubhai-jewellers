// solitaire/presentation/widgets/step3_customer_details_banner.dart
import 'package:flutter/material.dart';

class Step3CustomerDetailsBanner extends StatelessWidget {
  final String name;
  final String phone;

  const Step3CustomerDetailsBanner({
    super.key,
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3FF), // light blue banner like website
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0B2E5E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person_outline, color: Color(0xFF0B2E5E)),
              SizedBox(width: 10),
              Text(
                'Customer Details',
                style: TextStyle(
                  color: Color(0xFF0B2E5E),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Name: $name',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(
                child: Text(
                  'Phone: $phone',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
