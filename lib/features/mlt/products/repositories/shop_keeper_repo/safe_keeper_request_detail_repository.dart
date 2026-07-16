import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/shop_keeper_models/safe_keeper_request_detail_model.dart';

class SafeKeeperRequestDetailRepository {
  final String baseUrl;
  SafeKeeperRequestDetailRepository({required this.baseUrl});

  Future<SafeKeeperRequestReceivedDetailResponse> fetchDetail({
    required String cseId,
    required String safeRequestId,
  }) async {
    final uri = Uri.parse('$baseUrl/safe_keeper_request_received_detail.php');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'cse_id': cseId,
        'safe_request_id': safeRequestId,
      },
    );

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
    final parsed =
        SafeKeeperRequestReceivedDetailResponse.fromJson(jsonMap);

    if (parsed.errorCode != 0) {
      throw Exception(parsed.errorMsg.isEmpty ? 'Something went wrong' : parsed.errorMsg);
    }
    return parsed;
  }
}
