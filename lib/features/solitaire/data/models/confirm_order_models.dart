class ConfirmOrderResponse {
  final int successCode;
  final String errorMsg;
  final String orderId;
  final String message;

  const ConfirmOrderResponse({
    required this.successCode,
    required this.errorMsg,
    required this.orderId,
    required this.message,
  });

  factory ConfirmOrderResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmOrderResponse(
      successCode: int.tryParse((json['success_code'] ?? 0).toString()) ?? 0,
      errorMsg: (json['error_msg'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }
}
