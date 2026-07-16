// solitaire/presentation/widgets/step2_result_mobile_card.dart
import 'package:flutter/material.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/features/solitaire/data/models/step2_models.dart';

class Step2ResultMobileCard extends StatelessWidget {
  final StockRowVm row;
  final bool selected;
  final VoidCallback onTap;

  const Step2ResultMobileCard({
    super.key,
    required this.row,
    required this.selected,
    required this.onTap,
  });

  static const _primary = Color(0xFF0B2E5E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0x0D0B2E5E) : Colors.white,
          border: Border.all(
            color: selected ? _primary : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<int>(
                  value: 1,
                  groupValue: selected ? 1 : 0,
                  activeColor: _primary,
                  onChanged: (_) => onTap(),
                ),
                Expanded(
                  child: Text(
                    '${row.shape} • ${row.carat} ct • ${row.color} • ${row.clarity} • ${row.cut}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Price: ${row.priceInr}', style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              'Certification: ${row.certification} • ${row.certNo}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF616161)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: MJPrimaryButton(
                text: 'Select',
                onPressed: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
