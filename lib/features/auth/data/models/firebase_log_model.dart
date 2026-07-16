class CSEFirebaseLogResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;
  final Map<String, dynamic>? cseDetail;

  CSEFirebaseLogResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
    this.cseDetail,
  });

  factory CSEFirebaseLogResponse.fromJson(Map<String, dynamic> json) {
    return CSEFirebaseLogResponse(
      errorCode: json['error_code'] ?? 1,
      errorMsg: json['error_msg'] ?? '',
      successCode: json['success_code'] ?? 0,
      cseDetail: json['cse_detail'] != null
          ? Map<String, dynamic>.from(json['cse_detail'])
          : null,
    );
  }
}
