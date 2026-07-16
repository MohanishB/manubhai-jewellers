import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/solitaire/data/models/step3_order_summary_models.dart';

class SolitaireStep3OrderSummaryRepository {
  final String baseUrl;
  SolitaireStep3OrderSummaryRepository({required this.baseUrl});

  /// ✅ Existing (do not change)
  Future<Step3OrderSummaryResponse> fetchOrderSummary({
    required String cseId,
    required String stockCode,
    required String diamondId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
  }) async {
    final url = Uri.parse('$baseUrl/step3_order_summary.php');

    final body = <String, String>{
      'cse_id': cseId,
      'stock_code': stockCode,
      'diamond_id': diamondId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
    };

    if (customerEmail != null && customerEmail.trim().isNotEmpty) {
      body['customer_email'] = customerEmail.trim();
    }

    final resp = await http.post(url, body: body);

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final data = json.decode(resp.body);
    final map = Map<String, dynamic>.from(data);

    if ((map['success_code'] ?? 0) == 1) {
      return Step3OrderSummaryResponse.fromJson(map);
    }

    throw Exception(map['error_msg'] ?? 'Failed to fetch order summary');
  }

  /// ✅ NEW: Saved Orders view mode (order_id + cse_id)
  Future<Step3OrderSummaryResponse> fetchOrderSummaryByOrderId({
    required String cseId,
    required String orderId,
  }) async {
    final url = Uri.parse('$baseUrl/step3_order_summary.php');

    final body = <String, String>{
      'cse_id': cseId,
      'order_id': orderId,
    };

    final resp = await http.post(url, body: body);

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final data = json.decode(resp.body);
    final map = Map<String, dynamic>.from(data);

    if ((map['success_code'] ?? 0) == 1) {
      return Step3OrderSummaryResponse.fromJson(map);
    }

    throw Exception(map['error_msg'] ?? 'Failed to fetch order summary');
  }
}