import 'package:flutter/material.dart';
import 'package:manubhaimlt/features/solitaire/data/models/step2_models.dart';

// ✅ Added lotNumber
enum Step2SortColumn { lotNumber, carat, color, clarity, cut, priceInr, certification }
enum Step2SortDir { none, asc, desc }

class Step2ResultsTable extends StatelessWidget {
  final List<StockRowVm> rows;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  // ✅ LOCAL SORT STATE
  final Step2SortColumn sortColumn;
  final Step2SortDir sortDir;
  final ValueChanged<Step2SortColumn> onSortTap;

  const Step2ResultsTable({
    super.key,
    required this.rows,
    required this.selectedIndex,
    required this.onSelect,
    required this.sortColumn,
    required this.sortDir,
    required this.onSortTap,
  });

  static const _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
  ];

  static const _primary = Color(0xFF0B2E5E);
  static const _headerBg = Color(0xFF5A67D8);
  static const double _radius = 12;

  /// ✅ When NOT sorted: show two arrows (neutral)
  /// ✅ When sorted: show single arrow up/down
  Widget _sortIconFor(Step2SortColumn col) {
    if (sortColumn != col || sortDir == Step2SortDir.none) {
      return const Icon(Icons.unfold_more, size: 14, color: Colors.white);
    }
    return Icon(
      sortDir == Step2SortDir.asc
          ? Icons.keyboard_arrow_up
          : Icons.keyboard_arrow_down,
      size: 16,
      color: Colors.white,
    );
  }

  Widget _headerCell(
    String label, {
    Step2SortColumn? sortCol,
  }) {
    final clickable = sortCol != null;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        if (clickable) ...[
          const SizedBox(width: 6),
          _sortIconFor(sortCol!),
        ],
      ],
    );

    if (!clickable) return child;

    return InkWell(
      onTap: () => onSortTap(sortCol),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius), // ✅ rounded card
        boxShadow: _shadow,
      ),
      clipBehavior: Clip.antiAlias, // ✅ clip header + rows to radius
      child: Column(
        children: [
          // ✅ HEADER (rounded top corners)
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
                SizedBox(width: 72, child: Center(child: _headerCell('SELECT'))),

                // ✅ LOT NUMBER (sortable)
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _headerCell(
                      'LOT NUMBER',
                      sortCol: Step2SortColumn.lotNumber,
                    ),
                  ),
                ),

                Expanded(flex: 2, child: Center(child: _headerCell('SHAPE'))),

                Expanded(
                  flex: 2,
                  child: Center(
                    child: _headerCell('CARAT', sortCol: Step2SortColumn.carat),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: _headerCell('COLOR', sortCol: Step2SortColumn.color),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: _headerCell('CLARITY', sortCol: Step2SortColumn.clarity),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: _headerCell('CUT', sortCol: Step2SortColumn.cut),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _headerCell(
                      'PRICE (INR)',
                      sortCol: Step2SortColumn.priceInr,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _headerCell(
                      'CERTIFICATION',
                      sortCol: Step2SortColumn.certification,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ ROWS
          ListView.separated(
            itemCount: rows.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = rows[i];
              final selected = selectedIndex == i;

              return InkWell(
                onTap: () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: selected ? const Color(0x0D0B2E5E) : Colors.white,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Center(
                          child: Radio<int>(
                            value: i,
                            groupValue: selectedIndex,
                            activeColor: _primary,
                            onChanged: (_) => onSelect(i),
                          ),
                        ),
                      ),

                      // ✅ LOT NUMBER
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(r.lotNumber, style: _cellStyle()),
                        ),
                      ),

                      Expanded(flex: 2, child: Center(child: _pill(r.shape))),
                      Expanded(
                        flex: 2,
                        child: Center(child: Text('${r.carat} ct', style: _cellStyle())),
                      ),
                      Expanded(flex: 2, child: Center(child: Text(r.color, style: _cellStyle()))),
                      Expanded(flex: 2, child: Center(child: Text(r.clarity, style: _cellStyle()))),
                      Expanded(flex: 2, child: Center(child: Text(r.cut, style: _cellStyle()))),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            '₹ ${r.priceInr}',
                            style: _cellStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                r.certification,
                                style: _cellStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r.certNo,
                                style: _cellStyle(
                                  color: const Color(0xFF616161),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static TextStyle _cellStyle({
    Color color = const Color(0xFF212121),
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight);
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: _primary,
        ),
      ),
    );
  }
}