// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../data/models/request_safe_response_model.dart';

// class RequestSafeRepository {
//   static const _baseUrl =
//       'https://vitazreportingservices.com/mlt_app_webservices';

//   Future<RequestSafeResponseModel> requestSafe({
//     required String cseId,
//     required List<String> stockList,
//   }) async {
//     final url = Uri.parse('$_baseUrl/cse_request_stock_from_safe.php');

//     final Map<String, String> body = {
//       'cse_id': cseId,
//       for (int i = 0; i < stockList.length; i++) 'stock_list[$i]': stockList[i],
//     };

//     final response = await http.post(url, body: body);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return RequestSafeResponseModel.fromJson(data);
//     } else {
//       throw Exception(
//           'Server returned ${response.statusCode}: ${response.reasonPhrase}');
//     }
//   }
// }


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../data/models/CSE_models/request_safe_response_model.dart';

class RequestSafeRepository {
  static const _baseUrl =
      'https://vitazreportingservices.com/mlt_app_webservices';

  Future<RequestSafeResponseModel> requestSafe({
    required String cseId,
    required List<String> stockList,
  }) async {
    final url = Uri.parse('$_baseUrl/cse_request_stock_from_safe.php');

    final Map<String, String> body = {
      'cse_id': cseId,
      for (int i = 0; i < stockList.length; i++) 'stock_list[$i]': stockList[i],
    };

    // ✅ Print request body for debugging
    debugPrint('🔹 [POST] $url');
    body.forEach((key, value) {
      debugPrint('   $key = $value');
    });

    final response = await http.post(url, body: body);

    debugPrint('🔹 [RESPONSE STATUS]: ${response.statusCode}');
    debugPrint('🔹 [RESPONSE BODY]: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return RequestSafeResponseModel.fromJson(data);
    } else {
      throw Exception(
          'Server returned ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
