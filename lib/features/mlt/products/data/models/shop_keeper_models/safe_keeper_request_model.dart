class SafeKeeperRequestModel {
  final String safeRequestId;
  final String ssoId;
  final String ssoName;
  final String timeSince;
  final List<SafeKeeperProductModel> stockList;

  SafeKeeperRequestModel({
    required this.safeRequestId,
    required this.ssoId,
    required this.ssoName,
    required this.timeSince,
    required this.stockList,
  });

  factory SafeKeeperRequestModel.fromJson(Map<String, dynamic> json) {
    return SafeKeeperRequestModel(
      safeRequestId: json['safe_request_id'] ?? '',
      ssoId: json['sso_id'] ?? '',
      ssoName: json['sso_name'] ?? '',
      timeSince: json['time_since'] ?? '',
      stockList: (json['stock_list'] as List<dynamic>? ?? [])
          .map((e) => SafeKeeperProductModel.fromJson(e))
          .toList(),
    );
  }
}

class SafeKeeperProductModel {
  final String stockCode;
  final String lob;
  final String category;
  final String productImage;

  SafeKeeperProductModel({
    required this.stockCode,
    required this.lob,
    required this.category,
    required this.productImage,
  });

  factory SafeKeeperProductModel.fromJson(Map<String, dynamic> json) {
    return SafeKeeperProductModel(
      stockCode: json['stock_code'] ?? '',
      lob: json['lob'] ?? '',
      category: json['category'] ?? '',
      productImage: json['product_image'] ?? '',
    );
  }
}
