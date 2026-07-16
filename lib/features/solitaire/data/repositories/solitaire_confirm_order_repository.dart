import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/solitaire/data/models/confirm_order_models.dart';

class SolitaireConfirmOrderRepository {
  final String baseUrl;
  SolitaireConfirmOrderRepository({required this.baseUrl});

  Future<ConfirmOrderResponse> confirmOrder({
    required String cseId,
    required String stockCode,
    required String diamondId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,

    // MUST be json-encoded strings of objects received from API 3
    required Map<String, dynamic> originalProduct,
    required Map<String, dynamic> priceCalculation,
  }) async {
    final url = Uri.parse('$baseUrl/confirm_order.php');

    final body = <String, String>{
      'cse_id': cseId,
      'stock_code': stockCode,
      'diamond_id': diamondId,
      'customer_name': customerName,
      'customer_phone': customerPhone,

      // IMPORTANT: backend expects JSON encoded strings
      'original_product': jsonEncode(originalProduct),
      'price_calculation': jsonEncode(priceCalculation),
    };

    if (customerEmail != null && customerEmail.trim().isNotEmpty) {
      body['customer_email'] = customerEmail.trim();
    }

    final resp = await http.post(url, body: body);

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final map = Map<String, dynamic>.from(jsonDecode(resp.body));

    if ((map['success_code'] ?? 0).toString() == '1') {
      return ConfirmOrderResponse.fromJson(map);
    }

    throw Exception(map['error_msg'] ?? 'Failed to confirm order');
  }
}
