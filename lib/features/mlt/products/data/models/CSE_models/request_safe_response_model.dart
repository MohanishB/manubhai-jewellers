class RequestSafeResponseModel {
  final int errorCode;
  final String errorMsg;
  final int successCode;

  RequestSafeResponseModel({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
  });

  factory RequestSafeResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestSafeResponseModel(
      errorCode: json['error_code'] ?? -1,
      errorMsg: json['error_msg'] ?? '',
      successCode: json['success_code'] ?? 0,
    );
  }

  bool get isSuccess => successCode == 1 && errorCode == 0;
}
