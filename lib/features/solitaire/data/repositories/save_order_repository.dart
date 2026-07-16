// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:manubhaimlt/features/solitaire/data/models/save_order_models.dart';

// class SaveOrderRepository {
//   final String baseUrl;
//   SaveOrderRepository({required this.baseUrl});

//   Future<SaveOrderResponse> saveOrder({
//     required String cseId,
//     required String stockCode,
//     required String diamondId,
//     required String customerName,
//     required String customerPhone,
//     String? customerEmail,

//     required Map<String, dynamic> originalProduct,
//     required Map<String, dynamic> priceCalculation,

//     /// ✅ If backend supports JSON strings like confirm_order.php, set true.
//     /// Default false because Postman shows bracketed keys.
//     bool sendAsJsonStrings = false,
//   }) async {
//     final url = Uri.parse('$baseUrl/save_order.php');

//     final body = <String, String>{
//       'cse_id': cseId,
//       'stock_code': stockCode,
//       'diamond_id': diamondId,
//       'customer_name': customerName,
//       'customer_phone': customerPhone,
//     };

//     if (customerEmail != null && customerEmail.trim().isNotEmpty) {
//       body['customer_email'] = customerEmail.trim();
//     }

//     if (sendAsJsonStrings) {
//       // ✅ confirm_order style
//       body['original_product'] = jsonEncode(originalProduct);
//       body['price_calculation'] = jsonEncode(priceCalculation);
//     } else {
//       // ✅ Postman style (recommended)
//       for (final e in originalProduct.entries) {
//         body['original_product[${e.key}]'] = (e.value ?? '').toString();
//       }
//       for (final e in priceCalculation.entries) {
//         body['price_calculation[${e.key}]'] = (e.value ?? '').toString();
//       }
//     }

//     final resp = await http.post(url, body: body);

//     if (resp.statusCode != 200) {
//       throw Exception('HTTP ${resp.statusCode}');
//     }

//     final map = Map<String, dynamic>.from(jsonDecode(resp.body));

//     if ((map['success_code'] ?? 0).toString() == '1') {
//       return SaveOrderResponse.fromJson(map);
//     }

//     throw Exception(map['error_msg'] ?? 'Failed to save order');
//   }
// }

//========================================//
//========================================//
//========================================//
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/solitaire/data/models/save_order_models.dart';

class SaveOrderRepository {
  final String baseUrl;
  SaveOrderRepository({required this.baseUrl});

  Future<SaveOrderResponse> saveOrder({
    required String cseId,
    required String stockCode,
    required String diamondId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String selectedKarat,
    required Map<String, dynamic> originalProduct,
    required Map<String, dynamic> priceCalculation,

    /// If backend supports JSON strings like confirm_order.php, set true.
    /// Default false because Postman shows bracketed keys.
    bool sendAsJsonStrings = false,
  }) async {
    final url = Uri.parse('$baseUrl/save_order.php');

    final body = <String, String>{
      'cse_id': cseId,
      'stock_code': stockCode,
      'diamond_id': diamondId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'selected_karat': selectedKarat,
    };

    if (customerEmail != null && customerEmail.trim().isNotEmpty) {
      body['customer_email'] = customerEmail.trim();
    }

    if (sendAsJsonStrings) {
      body['original_product'] = jsonEncode(originalProduct);
      body['price_calculation'] = jsonEncode(priceCalculation);
    } else {
      for (final e in originalProduct.entries) {
        body['original_product[${e.key}]'] = (e.value ?? '').toString();
      }
      for (final e in priceCalculation.entries) {
        body['price_calculation[${e.key}]'] = (e.value ?? '').toString();
      }
    }

    final resp = await http.post(url, body: body);

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final map = Map<String, dynamic>.from(jsonDecode(resp.body));

    if ((map['success_code'] ?? 0).toString() == '1') {
      return SaveOrderResponse.fromJson(map);
    }

    throw Exception(map['error_msg'] ?? 'Failed to save order');
  }
}