class SaveOrderResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final int orderId;
  final String message;

  const SaveOrderResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    required this.orderId,
    required this.message,
  });

  factory SaveOrderResponse.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

    return SaveOrderResponse(
      errorCode: toInt(json['error_code']),
      errorMsg: (json['error_msg'] ?? '').toString(),
      successCode: toInt(json['success_code']),
      orderId: toInt(json['order_id']),
      message: (json['message'] ?? '').toString(),
    );
  }

  bool get isSuccess => successCode == 1 && errorCode == 0;
}