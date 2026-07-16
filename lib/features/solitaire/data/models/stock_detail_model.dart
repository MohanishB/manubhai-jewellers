// class StockDetailModel {
//   final String stockCode;
//   final String stockImage;
//   final String grossWt;
//   final String netWt;
//   final String diamondTotalWt;
//   final String labourAmount;
//   final String totalAmount;
//   final String totalAmountIncGet;
//   final String metalAmount;
//   final String solitaireWt;
//   final String diamondWt;
//   final String solitaireAmount;
//   final String diamondAmount;
//   final String finalAmount;

//   StockDetailModel({
//     required this.stockCode,
//     required this.stockImage,
//     required this.grossWt,
//     required this.netWt,
//     required this.diamondTotalWt,
//     required this.labourAmount,
//     required this.totalAmount,
//     required this.totalAmountIncGet,
//     required this.metalAmount,
//     required this.solitaireWt,
//     required this.diamondWt,
//     required this.solitaireAmount,
//     required this.diamondAmount,
//     required this.finalAmount,
//   });

//   factory StockDetailModel.fromJson(Map<String, dynamic> json) {
//     final stock = json['stock_detail'] ?? {};

//     String _toString(dynamic v) => v?.toString() ?? '0';

//     return StockDetailModel(
//       stockCode: _toString(stock['stock_code']),
//       stockImage: _toString(stock['stock_image']),
//       grossWt: _toString(stock['gross_wt']),
//       netWt: _toString(stock['net_wt']),
//       diamondTotalWt: _toString(stock['diamond_total_wt']),
//       labourAmount: _toString(stock['labour_amount']),
//       totalAmount: _toString(stock['total_amount']),
//       totalAmountIncGet: _toString(stock['total_amount_inc_get']),
//       metalAmount: _toString(stock['metal_amount']),
//       solitaireWt: _toString(stock['solitaire_wt']),
//       diamondWt: _toString(stock['diamond_wt']),
//       solitaireAmount: _toString(stock['solitaire_amount']),
//       diamondAmount: _toString(stock['diamond_amount']),
//       finalAmount: _toString(stock['final_amount']),
//     );
//   }
// }

//==============================================//
//==============================================//
//==============================================//

class StockDetailModel {
  final String stockCode;
  final String stockImage;
  final String grossWt;
  final String netWt;
  final String diamondTotalWt;
  final String labourAmount;
  final String totalAmount;
  final String totalAmountIncGet;
  final String metalAmount;
  final String lob;
  final String carat;
  final String solitaireWt;
  final String diamondWt;
  final String solitaireAmount;
  final String diamondAmount;
  final String finalAmount;
  final List<DiamondDetailModel> diamondDetails;

  StockDetailModel({
    required this.stockCode,
    required this.stockImage,
    required this.grossWt,
    required this.netWt,
    required this.diamondTotalWt,
    required this.labourAmount,
    required this.totalAmount,
    required this.totalAmountIncGet,
    required this.metalAmount,
    required this.lob,
    required this.carat,
    required this.solitaireWt,
    required this.diamondWt,
    required this.solitaireAmount,
    required this.diamondAmount,
    required this.finalAmount,
    required this.diamondDetails,
  });

  factory StockDetailModel.fromJson(Map<String, dynamic> json) {
    final stock = json['stock_detail'] ?? <String, dynamic>{};

    String toStr(dynamic value) => value?.toString() ?? '';

    return StockDetailModel(
      stockCode: toStr(stock['stock_code']),
      stockImage: toStr(stock['stock_image']),
      grossWt: toStr(stock['gross_wt']),
      netWt: toStr(stock['net_wt']),
      diamondTotalWt: toStr(stock['diamond_total_wt']),
      labourAmount: toStr(stock['labour_amount']),
      totalAmount: toStr(stock['total_amount']),
      totalAmountIncGet: toStr(stock['total_amount_inc_get']),
      metalAmount: toStr(stock['metal_amount']),
      lob: toStr(stock['lob']),
      carat: toStr(stock['carat']),
      solitaireWt: toStr(stock['solitaire_wt']),
      diamondWt: toStr(stock['diamond_wt']),
      solitaireAmount: toStr(stock['solitaire_amount']),
      diamondAmount: toStr(stock['diamond_amount']),
      finalAmount: toStr(stock['final_amount']),
      diamondDetails: (stock['diamond_details'] as List<dynamic>? ?? [])
          .map((e) => DiamondDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DiamondDetailModel {
  final int pcs;
  final String qty;
  final String clarity;
  final String shape;
  final String perCtPrice;
  final String diamondAmt;

  DiamondDetailModel({
    required this.pcs,
    required this.qty,
    required this.clarity,
    required this.shape,
    required this.perCtPrice,
    required this.diamondAmt,
  });

  factory DiamondDetailModel.fromJson(Map<String, dynamic> json) {
    return DiamondDetailModel(
      pcs: int.tryParse(json['pcs']?.toString() ?? '') ?? 0,
      qty: json['qty']?.toString() ?? '0',
      clarity: json['clarity']?.toString() ?? '',
      shape: json['shape']?.toString() ?? '',
      perCtPrice: json['per_ct_price']?.toString() ?? '0',
      diamondAmt: json['diamond_amt']?.toString() ?? '0',
    );
  }
}