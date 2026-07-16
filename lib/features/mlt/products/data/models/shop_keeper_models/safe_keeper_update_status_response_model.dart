class SafeKeeperUpdateStatusResponseModel {
  final int errorCode;
  final String errorMsg;
  final int successCode;

  SafeKeeperUpdateStatusResponseModel({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
  });

  factory SafeKeeperUpdateStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return SafeKeeperUpdateStatusResponseModel(
      errorCode: json['error_code'] ?? 1,
      errorMsg: json['error_msg'] ?? '',
      successCode: json['success_code'] ?? 0,
    );
  }
}
