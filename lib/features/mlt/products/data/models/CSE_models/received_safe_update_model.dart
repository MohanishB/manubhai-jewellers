class ReceivedSafeUpdateResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;

  ReceivedSafeUpdateResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
  });

  factory ReceivedSafeUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedSafeUpdateResponse(
      errorCode: json['error_code'] ?? 1,
      errorMsg: json['error_msg'] ?? '',
      successCode: json['success_code'] ?? 0,
    );
  }
}
