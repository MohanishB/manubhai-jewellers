import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/saved_orders_response_model.dart';

class SavedOrdersRepository {
  final String baseUrl;
  final http.Client _client;

  SavedOrdersRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<SavedOrdersResponse> fetchSavedOrders({
    required String cseId,
    required String fromDate, // yyyy-MM-dd
    required String toDate,   // yyyy-MM-dd
    String customerName = '',
    String customerPhone = '',
  }) async {
    final url = Uri.parse('$baseUrl/get_saved_orders.php');

    final resp = await _client.post(
      url,
      headers: const {
        'Accept': 'application/json',
      },
      body: {
        'cse_id': cseId,
        'from_date': fromDate,
        'to_date': toDate,
        'customer_name': customerName,
        'customer_phone': customerPhone,
      },
    );

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.reasonPhrase}');
    }

    final decoded = json.decode(resp.body) as Map<String, dynamic>;
    final parsed = SavedOrdersResponse.fromJson(decoded);

    // API uses error_code/success_code – treat non-success as error
    if (parsed.successCode != 1 || parsed.errorCode != 0) {
      throw Exception(parsed.errorMsg.isNotEmpty ? parsed.errorMsg : 'Failed');
    }

    return parsed;
  }
}