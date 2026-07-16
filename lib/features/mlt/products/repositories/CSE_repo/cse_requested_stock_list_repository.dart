import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/cse_requested_stock_list_model.dart';


class CseRequestedStockListRepository {
  final String baseUrl;
  final http.Client _client;

  CseRequestedStockListRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<CseRequestedStockListResponse> fetchRequestedStockList({
    required String cseId,
  }) async {
    final uri = Uri.parse('$baseUrl/cse_requested_stock_list.php');

    final res = await _client.post(
      uri,
      body: {'cse_id': cseId},
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: Failed to load requested stock');
    }

    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final parsed = CseRequestedStockListResponse.fromJson(jsonMap);

    if (parsed.successCode != 1 || parsed.errorCode != 0) {
      throw Exception(parsed.errorMsg.isNotEmpty
          ? parsed.errorMsg
          : 'Failed to load requested stock list');
    }

    return parsed;
  }
}
