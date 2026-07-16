class CseRequestedStockListResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final int totalProduct;
  final List<CseRequestedStockGroup> productList;

  const CseRequestedStockListResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    required this.totalProduct,
    required this.productList,
  });

  factory CseRequestedStockListResponse.fromJson(Map<String, dynamic> json) {
    return CseRequestedStockListResponse(
      errorCode: (json['error_code'] ?? 0) as int,
      errorMsg: (json['error_msg'] ?? '') as String,
      successCode: (json['success_code'] ?? 0) as int,
      totalProduct: (json['total_product'] ?? 0) as int,
      productList: ((json['product_list'] ?? []) as List)
          .map((e) => CseRequestedStockGroup.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class CseRequestedStockGroup {
  final String safeRequestId;
  final String timeSince;
  final List<CseRequestedStockItem> stockList;

  const CseRequestedStockGroup({
    required this.safeRequestId,
    required this.timeSince,
    required this.stockList,
  });

  factory CseRequestedStockGroup.fromJson(Map<String, dynamic> json) {
    return CseRequestedStockGroup(
      safeRequestId: (json['safe_request_id'] ?? '').toString(),
      timeSince: (json['time_since'] ?? '').toString(),
      stockList: ((json['stock_list'] ?? []) as List)
          .map((e) => CseRequestedStockItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class CseRequestedStockItem {
  final String stockCode;
  final String lob;
  final String category;
  final String productImage;
  final String safeKeeperStockStatus;
  final String cseStockStatus;

  const CseRequestedStockItem({
    required this.stockCode,
    required this.lob,
    required this.category,
    required this.productImage,
    required this.safeKeeperStockStatus,
    required this.cseStockStatus,
  });

  factory CseRequestedStockItem.fromJson(Map<String, dynamic> json) {
    return CseRequestedStockItem(
      stockCode: (json['stock_code'] ?? '').toString(),
      lob: (json['lob'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      productImage: (json['product_image'] ?? '').toString(),
      safeKeeperStockStatus: (json['safe_keeper_stock_status'] ?? '').toString(),
      cseStockStatus: (json['cse_stock_status'] ?? '').toString(),
    );
  }
}
