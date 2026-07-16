import 'dart:convert';

class CustomerExperienceRequest {
  final String cseId;
  final String expType; // HAPPY / NORMAL / SAD
  final String customerName;
  final String customerPhone;

  const CustomerExperienceRequest({
    required this.cseId,
    required this.expType,
    required this.customerName,
    required this.customerPhone,
  });

  Map<String, String> toFields() => {
        'cse_id': cseId,
        'exp_type': expType,
        'customer_name': customerName,
        'customer_phone': customerPhone,
      };
}

class CustomerExperienceResponse {
  final int errorCode;
  final String errorMsg;
  final int successCode;

  const CustomerExperienceResponse({
    required this.errorCode,
    required this.errorMsg,
    required this.successCode,
  });

  bool get isSuccess => successCode == 1 && errorCode == 0;

  factory CustomerExperienceResponse.fromJson(Map<String, dynamic> json) {
    return CustomerExperienceResponse(
      errorCode: int.tryParse(json['error_code']?.toString() ?? '') ?? 0,
      errorMsg: json['error_msg']?.toString() ?? '',
      successCode: int.tryParse(json['success_code']?.toString() ?? '') ?? 0,
    );
  }

  factory CustomerExperienceResponse.fromRaw(String raw) {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return CustomerExperienceResponse.fromJson(m);
  }
}
