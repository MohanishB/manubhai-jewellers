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
        Map<String, dynamic>.from(json['lg_data'] ?? const {}),
      ),
    );
  }
}

class SoliShiftLgData {
  final String mode;
  final StockInfo stockInfo;
  final FilterOptions filters;
  final List<Map<String, dynamic>> solitaireEntries;
  final List<Map<String, dynamic>> diamondEntries;
  final List<PricingTable> pricingTables;
  final RawEntries rawEntries;

  const SoliShiftLgData({
    this.mode = 'carat',
    required this.stockInfo,
    required this.filters,
    this.solitaireEntries = const [],
    this.diamondEntries = const [],
    required this.pricingTables,
    required this.rawEntries,
  });

  factory SoliShiftLgData.fromJson(Map<String, dynamic> json) {
    return SoliShiftLgData(
      mode: json['mode']?.toString() ?? 'carat',
      stockInfo: StockInfo.fromJson(
        Map<String, dynamic>.from(json['stock_info'] ?? const {}),
      ),
      filters: FilterOptions.fromJson(
        Map<String, dynamic>.from(json['filters'] ?? const {}),
      ),
      solitaireEntries: _mapList(json['solitaire_entries']),
      diamondEntries: _mapList(json['diamond_entries']),
      pricingTables: (json['pricing_tables'] as List<dynamic>? ?? const [])
          .map((e) => PricingTable.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      rawEntries: RawEntries.fromJson(
        Map<String, dynamic>.from(json['raw_entries'] ?? const {}),
      ),
    );
  }

  /// Update APIs don't return stock_info, filters or raw_entries.
  /// Preserve them from the initial search response.
  SoliShiftLgData mergeUpdate(SoliShiftLgData update) {
    return SoliShiftLgData(
      mode: update.mode,
      stockInfo: update.stockInfo.stockCode.isEmpty ? stockInfo : update.stockInfo,
      filters: update.filters.isEmpty ? filters : update.filters,
      solitaireEntries: update.solitaireEntries,
      diamondEntries: update.diamondEntries,
      pricingTables: update.pricingTables,
      rawEntries: rawEntries,
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
    this.stockCode = '',
    this.stockImage = '',
    this.grossWt = '',
    this.netWt = '',
    this.solitaireWt = '',
    this.diamondWt = '',
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
    this.shapes = const [],
    this.colours = const [],
    this.clarities = const [],
  });

  bool get isEmpty => shapes.isEmpty && colours.isEmpty && clarities.isEmpty;

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      return (value as List<dynamic>? ?? const [])
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

class RawEntries {
  final num labourAmount;
  final num metalAmount;
  final num solitaireWt;
  final List<Map<String, dynamic>> solitaireDetails;
  final List<Map<String, dynamic>> diamondDetails;

  const RawEntries({
    this.labourAmount = 0,
    this.metalAmount = 0,
    this.solitaireWt = 0,
    this.solitaireDetails = const [],
    this.diamondDetails = const [],
  });

  factory RawEntries.fromJson(Map<String, dynamic> json) {
    return RawEntries(
      labourAmount: _asNum(json['labour_amount']),
      metalAmount: _asNum(json['metal_amount']),
      solitaireWt: _asNum(json['solitaire_wt']),
      solitaireDetails: _mapList(json['solitaire_details']),
      diamondDetails: _mapList(json['diamond_details']),
    );
  }
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
        Map<String, dynamic>.from(json['header'] ?? const {}),
      ),
      rows: (json['rows'] as List<dynamic>? ?? const [])
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
  final bool showCol4;

  const PricingHeader({
    required this.title,
    required this.colDetail,
    required this.colLg,
    required this.colNat,
    required this.col4,
    required this.showCol4,
  });

  factory PricingHeader.fromJson(Map<String, dynamic> json) {
    return PricingHeader(
      title: json['title']?.toString() ?? '',
      colDetail: json['col_detail']?.toString() ?? 'Detail',
      colLg: json['col_lg']?.toString() ?? 'LG',
      colNat: json['col_nat']?.toString() ?? 'Real Diamond',
      col4: json['col4']?.toString() ?? 'Same price as LG with Real Diamond',
      showCol4: json['show_col4'] != false,
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
      lgFormula: _formatFormula(json['lg_formula']),
      natFormula: _formatFormula(json['nat_formula']),
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

List<Map<String, dynamic>> _mapList(dynamic value) {
  return (value as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

num _asNum(dynamic value) => value is num ? value : num.tryParse('$value') ?? 0;

String _parseCol4(dynamic value) {
  if (value == null) return '';
  if (value is Map) {
    return (value['display']?.toString() ?? '').replaceAll('|', '\n');
  }
  return value.toString();
}

String _numString(dynamic value) {
  if (value == null) return '';
  final number = double.tryParse(value.toString());
  if (number == null) return value.toString();
  var text = number.toStringAsFixed(4);
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
    (_) => ',',
  )}';
}

String _formatFormula(dynamic value) {
  final text = value?.toString() ?? '';
  return text.replaceAllMapped(
    RegExp(r'(?<![\d.])(\d{4,})(?![\d.])'),
    (match) {
      final raw = match.group(1)!;
      return raw.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
    },
  );
}
