import 'dart:convert';

class SavedOrdersResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final List<SavedOrderApiModel> orders;
  final int totalCount;
  final SavedOrdersFilterApplied filterApplied;

  const SavedOrdersResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    required this.orders,
    required this.totalCount,
    required this.filterApplied,
  });

  factory SavedOrdersResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['orders'] as List? ?? const [])
        .map((e) => SavedOrderApiModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return SavedOrdersResponse(
      errorCode: _toInt(json['error_code']),
      errorMsg: (json['error_msg'] ?? '').toString(),
      successCode: _toInt(json['success_code']),
      orders: list,
      totalCount: _toInt(json['total_count']),
      filterApplied: SavedOrdersFilterApplied.fromJson(
        (json['filter_applied'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  static int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

  static SavedOrdersResponse fromRaw(String raw) =>
      SavedOrdersResponse.fromJson(json.decode(raw) as Map<String, dynamic>);
}

class SavedOrdersFilterApplied {
  final String fromDate;
  final String toDate;
  final String customerName;
  final String customerPhone;
  final String orderStatus;

  const SavedOrdersFilterApplied({
    required this.fromDate,
    required this.toDate,
    required this.customerName,
    required this.customerPhone,
    required this.orderStatus,
  });

  factory SavedOrdersFilterApplied.fromJson(Map<String, dynamic> json) {
    return SavedOrdersFilterApplied(
      fromDate: (json['from_date'] ?? '').toString(),
      toDate: (json['to_date'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      customerPhone: (json['customer_phone'] ?? '').toString(),
      orderStatus: (json['order_status'] ?? '').toString(),
    );
  }
}

class SavedOrderApiModel {
  final String orderId;
  final String orderUniqueId;
  final String orderDate; // "2026-02-23 07:24:26"
  final String orderStatus;

  final String customerName;
  final String customerPhone;
  final String customerEmail;

  final String stockCode;
  final String stockImage;

  final String selectedLotNumber;
  final String finalTotalAmount; // "119463.50"

  const SavedOrderApiModel({
    required this.orderId,
    required this.orderUniqueId,
    required this.orderDate,
    required this.orderStatus,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.stockCode,
    required this.stockImage,
    required this.selectedLotNumber,
    required this.finalTotalAmount,
  });

  factory SavedOrderApiModel.fromJson(Map<String, dynamic> json) {
    return SavedOrderApiModel(
      orderId: (json['order_id'] ?? '').toString(),
      orderUniqueId: (json['order_unique_id'] ?? '').toString(),
      orderDate: (json['order_date'] ?? '').toString(),
      orderStatus: (json['order_status'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      customerPhone: (json['customer_phone'] ?? '').toString(),
      customerEmail: (json['customer_email'] ?? '').toString(),
      stockCode: (json['stock_code'] ?? '').toString(),
      stockImage: (json['stock_image'] ?? '').toString(),
      selectedLotNumber: (json['selected_lot_number'] ?? '').toString(),
      finalTotalAmount: (json['final_total_amount'] ?? '').toString(),
    );
  }
}