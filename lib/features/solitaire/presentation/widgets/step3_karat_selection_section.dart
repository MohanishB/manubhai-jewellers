import 'package:flutter/material.dart';
import 'package:manubhaimlt/features/solitaire/data/models/step3_order_summary_models.dart';

class Step3KaratSelectionSection extends StatelessWidget {
  final List<KaratOptionVm> options;
  final String? selectedKarat;
  final ValueChanged<String> onSelect;

  const Step3KaratSelectionSection({
    super.key,
    required this.options,
    required this.selectedKarat,
    required this.onSelect,
  });

  String _fmtMoney(String raw) {
    final t = raw.toString().trim();
    if (t.isEmpty) return '₹0.00';

    if (t.contains('₹')) return t;
    if (t.contains(',') || t.contains('.')) return '₹$t';

    final n = double.tryParse(t) ?? 0;
    final fixed = n.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final dec = parts[1];

    final withCommas = whole.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return '₹$withCommas.$dec';
  }

  String _fmtWt(String raw, String unit) {
    final t = raw.toString().trim();
    return t.isEmpty ? '0 $unit' : '$t $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4D6DFF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🥇', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Select Your Preferred Gold Karat *',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFF4D6DFF)),
          const SizedBox(height: 14),
          const Text(
            'Required: Choose the gold karat that best suits your preferences and budget. Prices are calculated based on current gold rates.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF616161),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final isTablet = c.maxWidth >= 900;

              if (!isTablet) {
                return Column(
                  children: options
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _KaratCard(
                            option: e,
                            selected:
                                (selectedKarat ?? '').trim().toLowerCase() ==
                                    e.karat.trim().toLowerCase(),
                            onTap: () => onSelect(e.karat),
                            fmtMoney: _fmtMoney,
                            fmtWt: _fmtWt,
                          ),
                          // child: _KaratCard(
                          //   option: e,
                          //   selected: selectedKarat == e.karat,
                          //   onTap: () => onSelect(e.karat),
                          //   fmtMoney: _fmtMoney,
                          //   fmtWt: _fmtWt,
                          // ),
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options
                    .map(
                      (e) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: e == options.last ? 0 : 12,
                          ),
                          child: _KaratCard(
                            option: e,
                            selected:
                                (selectedKarat ?? '').trim().toLowerCase() ==
                                    e.karat.trim().toLowerCase(),
                            onTap: () => onSelect(e.karat),
                            fmtMoney: _fmtMoney,
                            fmtWt: _fmtWt,
                          ),
                          // child: _KaratCard(
                          //   option: e,
                          //   selected: selectedKarat == e.karat,
                          //   onTap: () => onSelect(e.karat),
                          //   fmtMoney: _fmtMoney,
                          //   fmtWt: _fmtWt,
                          // ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KaratCard extends StatelessWidget {
  final KaratOptionVm option;
  final bool selected;
  final VoidCallback onTap;
  final String Function(String) fmtMoney;
  final String Function(String, String) fmtWt;

  const _KaratCard({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.fmtMoney,
    required this.fmtWt,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? const Color(0xFF4D6DFF) : const Color(0xFFD7D7D7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: selected ? 2 : 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    option.karat.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected
                      ? const Color(0xFF4D6DFF)
                      : const Color(0xFF9E9E9E),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              fmtMoney(option.finalPrice),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Color(0xFF4D6DFF),
              ),
            ),
            const SizedBox(height: 12),
            Text('Small Diamonds: ${fmtMoney(option.smallDiamonds)}'),
            const SizedBox(height: 6),
            Text('Per Carat: ${fmtMoney(option.perCaratPrice)}/ct'),
            const SizedBox(height: 6),
            Text('Solitaire Wt: ${fmtWt(option.solitaireWeight, 'ct')}'),
            const SizedBox(height: 6),
            Text('Solitaire Cost: ${fmtMoney(option.solitaireCost)}'),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text('Gold Rate: ${fmtMoney(option.goldRate)}/gm'),
            const SizedBox(height: 6),
            Text('Net Weight: ${fmtWt(option.netWeight, 'gm')}'),
            const SizedBox(height: 6),
            Text('Gold Cost: ${fmtMoney(option.goldCost)}'),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text('Labour: ${fmtMoney(option.labour)}'),
          ],
        ),
      ),
    );
  }
}