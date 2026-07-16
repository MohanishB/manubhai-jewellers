import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/shop_keeper_models/safe_keeper_update_status_response_model.dart';
import '../../data/models/shop_keeper_models/safe_keeper_request_model.dart';

class SafeKeeperRepository {
  static const _baseUrl =
      'https://vitazreportingservices.com/mlt_app_webservices';

  Future<List<SafeKeeperRequestModel>> fetchSafeKeeperRequests(String cseId) async {
    final url = Uri.parse('$_baseUrl/safe_keeper_request_received_list.php');
    final body = {'cse_id': cseId};

    debugPrint('📡 [POST] $url');
    debugPrint('Body: $body');

    final response = await http.post(url, body: body);

    debugPrint('Response: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success_code'] == 1) {
        final list = (data['product_list'] as List<dynamic>)
            .map((e) => SafeKeeperRequestModel.fromJson(e))
            .toList();
        return list;
      } else {
        throw Exception(data['error_msg'] ?? 'Failed to fetch requests');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<SafeKeeperUpdateStatusResponseModel> updateRequestStatus({
    required String cseId,
    required String safeRequestId,
    required List<String> stockList,
    required int status, // 1 = dispatched, 2 = not found
  }) async {
    final url = Uri.parse('$_baseUrl/safe_keeper_update_request_status.php');

    final Map<String, String> body = {
      'cse_id': cseId,
      'safe_request_id': safeRequestId,
      'status': status.toString(),
      for (int i = 0; i < stockList.length; i++) 'stock_list[$i]': stockList[i],
    };

    print("🔹 [POST] $url");
    print("📦 Body: $body");

    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SafeKeeperUpdateStatusResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to update status: ${response.statusCode}');
    }
  }
}
