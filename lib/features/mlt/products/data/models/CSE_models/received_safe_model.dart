class ReceivedSafeResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final int totalProduct;
  final List<ReceivedSafeRequest> productList;

  ReceivedSafeResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    required this.totalProduct,
    required this.productList,
  });

  factory ReceivedSafeResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['product_list'] as List?)
            ?.map((e) => ReceivedSafeRequest.fromJson(e))
            .toList() ??
        [];

    return ReceivedSafeResponse(
      errorCode: json['error_code'] ?? 1,
      errorMsg: json['error_msg'] ?? '',
      successCode: json['success_code'] ?? 0,
      totalProduct: json['total_product'] ?? 0,
      productList: list,
    );
  }
}

class ReceivedSafeRequest {
  final String safeRequestId;
  final String timeSince;
  final List<ReceivedSafeProduct> stockList;

  ReceivedSafeRequest({
    required this.safeRequestId,
    required this.timeSince,
    required this.stockList,
  });

  factory ReceivedSafeRequest.fromJson(Map<String, dynamic> json) {
    final list = (json['stock_list'] as List?)
            ?.map((e) => ReceivedSafeProduct.fromJson(e))
            .toList() ??
        [];

    return ReceivedSafeRequest(
      safeRequestId: json['safe_request_id'] ?? '',
      timeSince: json['time_since'] ?? '',
      stockList: list,
    );
  }
}

class ReceivedSafeProduct {
  final String stockCode;
  final String lob;
  final String category;
  final String productImage;

  ReceivedSafeProduct({
    required this.stockCode,
    required this.lob,
    required this.category,
    required this.productImage,
  });

  factory ReceivedSafeProduct.fromJson(Map<String, dynamic> json) {
    return ReceivedSafeProduct(
      stockCode: json['stock_code'] ?? '',
      lob: json['lob'] ?? '',
      category: json['category'] ?? '',
      productImage: json['product_image'] ?? '',
    );
  }
}
