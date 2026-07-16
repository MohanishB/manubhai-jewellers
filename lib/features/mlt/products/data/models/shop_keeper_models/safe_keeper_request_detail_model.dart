class SafeKeeperRequestReceivedDetailResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final int totalProduct;

  final List<SafeKeeperRequestDetailProduct> productList;

  SafeKeeperRequestReceivedDetailResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    required this.totalProduct,
    required this.productList,
  });

  factory SafeKeeperRequestReceivedDetailResponse.fromJson(
      Map<String, dynamic> json) {
    return SafeKeeperRequestReceivedDetailResponse(
      errorCode: int.tryParse(json['error_code']?.toString() ?? '') ?? 0,
      errorMsg: (json['error_msg'] ?? '').toString(),
      successCode: int.tryParse(json['success_code']?.toString() ?? '') ?? 0,
      totalProduct: int.tryParse(json['total_product']?.toString() ?? '') ?? 0,
      productList: (json['product_list'] as List? ?? [])
          .map((e) =>
              SafeKeeperRequestDetailProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SafeKeeperRequestDetailProduct {
  final String safeRequestId;
  final String ssoId;
  final String ssoName;
  final String timeSince;
  final List<SafeKeeperRequestDetailStock> stockList;

  SafeKeeperRequestDetailProduct({
    required this.safeRequestId,
    required this.ssoId,
    required this.ssoName,
    required this.timeSince,
    required this.stockList,
  });

  factory SafeKeeperRequestDetailProduct.fromJson(Map<String, dynamic> json) {
    return SafeKeeperRequestDetailProduct(
      safeRequestId: (json['safe_request_id'] ?? '').toString(),
      ssoId: (json['sso_id'] ?? '').toString(),
      ssoName: (json['sso_name'] ?? '').toString(),
      timeSince: (json['time_since'] ?? '').toString(),
      stockList: (json['stock_list'] as List? ?? [])
          .map((e) =>
              SafeKeeperRequestDetailStock.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SafeKeeperRequestDetailStock {
  final String stockCode;
  final String lob;
  final String category;
  final String productImage;

  SafeKeeperRequestDetailStock({
    required this.stockCode,
    required this.lob,
    required this.category,
    required this.productImage,
  });

  factory SafeKeeperRequestDetailStock.fromJson(Map<String, dynamic> json) {
    return SafeKeeperRequestDetailStock(
      stockCode: (json['stock_code'] ?? '').toString(),
      lob: (json['lob'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      productImage: (json['product_image'] ?? '').toString(),
    );
  }
}
