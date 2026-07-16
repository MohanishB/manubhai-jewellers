// lib/features/solitaire/presentation/widgets/step2_search_within_results_card.dart
import 'package:flutter/material.dart';
import 'package:manubhaimlt/core/widgets/mj_text_field.dart';

class Step2SearchWithinResultsCard extends StatelessWidget {
  final bool isTablet;

  final TextEditingController lotCtrl;
  final TextEditingController certCtrl;
  final TextEditingController caratMinCtrl;
  final TextEditingController caratMaxCtrl;
  final TextEditingController priceMinCtrl;
  final TextEditingController priceMaxCtrl;

  final VoidCallback onSearch;
  final VoidCallback onClear;

  const Step2SearchWithinResultsCard({
    super.key,
    required this.isTablet,
    required this.lotCtrl,
    required this.certCtrl,
    required this.caratMinCtrl,
    required this.caratMaxCtrl,
    required this.priceMinCtrl,
    required this.priceMaxCtrl,
    required this.onSearch,
    required this.onClear,
  });

  static const _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, size: 20, color: Color(0xFF424242)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search Within Results',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (isTablet) _desktopLayout() else _mobileLayout(),

          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isTablet ? 160 : double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B2E5E),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                    elevation: 0,
                  ),
                  onPressed: onSearch,
                  child:  Text('Search'.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              SizedBox(
                width: isTablet ? 170 : double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF616161),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                    elevation: 0,
                  ),
                  onPressed: onClear,
                  child: Text('Clear Search'.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _desktopLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _labeled('Lot Number', lotCtrl, hint: 'Search...')),
            const SizedBox(width: 14),
            Expanded(child: _labeled('Cert Number', certCtrl)),
            const SizedBox(width: 14),
            Expanded(
                child: _labeled('Carat From', caratMinCtrl,
                    hint: 'Min', number: true)),
            const SizedBox(width: 14),
            Expanded(
                child: _labeled('Carat To', caratMaxCtrl,
                    hint: 'Max', number: true)),
            const SizedBox(width: 14),
            Expanded(
                child: _labeled('Price From', priceMinCtrl,
                    hint: 'Min', number: true)),
            const SizedBox(width: 14),
            Expanded(
                child: _labeled('Price To', priceMaxCtrl,
                    hint: 'Max', number: true)),
          ],
        ),
      ],
    );
  }

  Widget _mobileLayout() {
    return Column(
      children: [
        _labeled('Lot Number', lotCtrl, hint: 'Search...'),
        const SizedBox(height: 12),
        _labeled('Cert Number', certCtrl),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _labeled('Carat From', caratMinCtrl,
                    hint: 'Min', number: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _labeled('Carat To', caratMaxCtrl,
                    hint: 'Max', number: true)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _labeled('Price From', priceMinCtrl,
                    hint: 'Min', number: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _labeled('Price To', priceMaxCtrl,
                    hint: 'Max', number: true)),
          ],
        ),
      ],
    );
  }

  Widget _labeled(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool number = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        MJTextField(
          controller: ctrl,
          hintText: hint ?? '',
          keyboardType: number ? TextInputType.number : TextInputType.text,
        ),
      ],
    );
  }
}
