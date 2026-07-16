class SoliShiftLgResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final SoliShiftLgData data;

  const SoliShiftLgResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    required this.data,
  });

  factory SoliShiftLgResponse.fromJson(Map<String, dynamic> json) {
    return SoliShiftLgResponse(
      errorCode: int.tryParse(json['error_code'].toString()) ?? 0,
      errorMsg: json['error_msg']?.toString() ?? '',
      successCode: int.tryParse(json['success_code'].toString()) ?? 0,
      data: SoliShiftLgData.fromJson(
        Map<String, dynamic>.from(json['lg_data'] ?? {}),
      ),
    );
  }
}

class SoliShiftLgData {
  final StockInfo stockInfo;
  final FilterOptions filters;
  final List<PricingTable> pricingTables;

  const SoliShiftLgData({
    required this.stockInfo,
    required this.filters,
    required this.pricingTables,
  });

  factory SoliShiftLgData.fromJson(Map<String, dynamic> json) {
    return SoliShiftLgData(
      stockInfo: StockInfo.fromJson(
        Map<String, dynamic>.from(json['stock_info'] ?? {}),
      ),
      filters: FilterOptions.fromJson(
        Map<String, dynamic>.from(json['filters'] ?? {}),
      ),
      pricingTables: (json['pricing_tables'] as List<dynamic>? ?? [])
          .map((e) => PricingTable.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class StockInfo {
  final String stockCode;
  final String stockImage;
  final String grossWt;
  final String netWt;
  final String solitaireWt;
  final String diamondWt;

  const StockInfo({
    required this.stockCode,
    required this.stockImage,
    required this.grossWt,
    required this.netWt,
    required this.solitaireWt,
    required this.diamondWt,
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) {
    return StockInfo(
      stockCode: json['stock_code']?.toString() ?? '',
      stockImage: json['stock_image']?.toString() ?? '',
      grossWt: _numString(json['gross_wt']),
      netWt: _numString(json['net_wt']),
      solitaireWt: _numString(json['solitaire_wt']),
      diamondWt: _numString(json['diamond_wt']),
    );
  }
}

class FilterOptions {
  final List<String> shapes;
  final List<String> colours;
  final List<String> clarities;

  const FilterOptions({
    required this.shapes,
    required this.colours,
    required this.clarities,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      return (value as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return FilterOptions(
      shapes: parseList(json['shape']),
      colours: parseList(json['colour']),
      clarities: parseList(json['clarity']),
    );
  }

  List<String> get shapeDropdown => ['All', ...shapes];
  List<String> get colourDropdown => ['All', ...colours];
  List<String> get clarityDropdown => ['All', ...clarities];
}

class PricingTable {
  final String tableId;
  final String shape;
  final String colour;
  final String clarity;
  final bool visible;
  final PricingHeader header;
  final List<PricingRow> rows;

  const PricingTable({
    required this.tableId,
    required this.shape,
    required this.colour,
    required this.clarity,
    required this.visible,
    required this.header,
    required this.rows,
  });

  factory PricingTable.fromJson(Map<String, dynamic> json) {
    return PricingTable(
      tableId: json['table_id']?.toString() ?? '',
      shape: json['shape']?.toString() ?? '',
      colour: json['colour']?.toString() ?? '',
      clarity: json['clarity']?.toString() ?? '',
      visible: json['visible'] != false,
      header: PricingHeader.fromJson(
        Map<String, dynamic>.from(json['header'] ?? {}),
      ),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((e) => PricingRow.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class PricingHeader {
  final String title;
  final String colDetail;
  final String colLg;
  final String colNat;
  final String col4;

  const PricingHeader({
    required this.title,
    required this.colDetail,
    required this.colLg,
    required this.colNat,
    required this.col4,
  });

  factory PricingHeader.fromJson(Map<String, dynamic> json) {
    return PricingHeader(
      title: json['title']?.toString() ?? '',
      colDetail: json['col_detail']?.toString() ?? 'Detail',
      colLg: json['col_lg']?.toString() ?? 'LG',
      colNat: json['col_nat']?.toString() ?? 'Real Diamond',
      col4: json['col4']?.toString() ?? 'Same price as LG with Real Diamond',
    );
  }
}

class PricingRow {
  final String type;
  final String label;
  final String subLabel;
  final String lgFormula;
  final String natFormula;
  final String lgAmount;
  final String natAmount;
  final String col4Display;

  const PricingRow({
    required this.type,
    required this.label,
    required this.subLabel,
    required this.lgFormula,
    required this.natFormula,
    required this.lgAmount,
    required this.natAmount,
    required this.col4Display,
  });

  factory PricingRow.fromJson(Map<String, dynamic> json) {
    return PricingRow(
      type: json['type']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      subLabel: json['sub_label']?.toString() ?? '',
      lgFormula: json['lg_formula']?.toString() ?? '',
      natFormula: json['nat_formula']?.toString() ?? '',
      lgAmount: _formatInr(json['lg_amount']),
      natAmount: _formatInr(json['nat_amount']),
      col4Display: _parseCol4(json['col4']),
    );
  }

  String get lgCell {
    if (type == 'solitaire' || type == 'diamond') {
      return lgFormula.isEmpty ? lgAmount : '$lgFormula = $lgAmount';
    }
    return lgAmount;
  }

  String get natCell {
    if (type == 'solitaire' || type == 'diamond') {
      return natFormula.isEmpty ? natAmount : '$natFormula = $natAmount';
    }
    return natAmount;
  }
}

String _parseCol4(dynamic value) {
  if (value == null) return '';
  if (value is Map) {
    final display = value['display']?.toString() ?? '';
    return display.replaceAll('|', '\n');
  }
  return value.toString();
}

String _numString(dynamic value) {
  if (value == null) return '';
  final number = double.tryParse(value.toString());
  if (number == null) return value.toString();
  var text = number.toStringAsFixed(3);
  text = text.replaceFirst(RegExp(r'0+$'), '');
  text = text.replaceFirst(RegExp(r'\.$'), '');
  return text;
}

String _formatInr(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return '';

  final number = num.tryParse(value.toString());
  if (number == null) return value.toString();

  final raw = number.round().toString();

  return 'INR ${raw.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  )}';
}

// String _formatInr(dynamic value) {
//   if (value == null || value.toString().trim().isEmpty) return '';
//   final number = num.tryParse(value.toString());
//   if (number == null) return value.toString();

//   final raw = number.round().toString();
//   final buffer = StringBuffer();
//   for (int i = 0; i < raw.length; i++) {
//     final fromEnd = raw.length - i;
//     buffer.write(raw[i]);
//     if (fromEnd > 1 && fromEnd % 2 == 0 && i != raw.length - 1) {
//       buffer.write(',');
//     }
//   }
//   return 'INR ${buffer.toString()}';
// }
