// lib/features/solitaire/data/models/solitaire_diamond_models.dart
class SolitaireDiamondVm {
  final String id;
  final String lotNumber;
  final String shape;
  final String carat; // keep as string (API returns string)
  final String color;
  final String clarity;
  final String cut;
  final String cert;
  final String certNo;
  final String priceInr;
  final String valueInr;
  final String isAvailable;

  const SolitaireDiamondVm({
    required this.id,
    required this.lotNumber,
    required this.shape,
    required this.carat,
    required this.color,
    required this.clarity,
    required this.cut,
    required this.cert,
    required this.certNo,
    required this.priceInr,
    required this.valueInr,
    required this.isAvailable,
  });

  factory SolitaireDiamondVm.fromJson(Map<String, dynamic> j) {
    return SolitaireDiamondVm(
      id: (j['id'] ?? '').toString(),
      lotNumber: (j['lot_number'] ?? '').toString(),
      shape: (j['shape'] ?? '').toString(),
      carat: (j['carat'] ?? j['carats'] ?? '').toString(),
      color: (j['color'] ?? '').toString(),
      clarity: (j['clarity'] ?? '').toString(),
      cut: (j['cut'] ?? '').toString(),
      cert: (j['cert'] ?? '').toString(),
      certNo: (j['cert_no'] ?? '').toString(),
      priceInr: (j['price_inr'] ?? '').toString(),
      valueInr: (j['value_inr'] ?? '').toString(),
      isAvailable: (j['is_available'] ?? '').toString(),
    );
  }
}

class FilterDiamondsResponse {
  final int successCode;
  final String errorMsg;
  final List<SolitaireDiamondVm> diamonds;
  final int totalCount;

  const FilterDiamondsResponse({
    required this.successCode,
    required this.errorMsg,
    required this.diamonds,
    required this.totalCount,
  });

  factory FilterDiamondsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['diamonds'] as List? ?? [])
        .map((e) => SolitaireDiamondVm.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return FilterDiamondsResponse(
      successCode: (json['success_code'] ?? 0) as int,
      errorMsg: (json['error_msg'] ?? '').toString(),
      diamonds: list,
      totalCount: int.tryParse((json['total_count'] ?? 0).toString()) ?? 0,
    );
  }
}

