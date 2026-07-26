// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/stock_detail_model.dart';

// class StockRepository {
//   final String baseUrl;

//   StockRepository({required this.baseUrl});

//   Future<StockDetailModel> fetchStockDetail({
//     required String cseId,
//     required String stockCode,
//   }) async {
//     final url = Uri.parse('$baseUrl/jwel_api/get_stock_detail.php');

//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: {'cse_id': cseId, 'stock_code': stockCode},
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Network error: ${response.statusCode}');
//       }

//       final jsonBody = json.decode(response.body);

//       // ✅ Backend explicitly signals failure
//       if (jsonBody['success_code'] == 0 || jsonBody['error_code'] != 0) {
//         final errorMsg = jsonBody['error_msg']?.toString() ?? 'Something went wrong';
//         throw errorMsg; // <-- THROW message directly (not Exception)
//       }

//       // ✅ Success: parse model
//       return StockDetailModel.fromJson(jsonBody);
//     } catch (e) {
//       // ✅ If backend already threw String, rethrow cleanly
//       if (e is String) {
//         throw e;
//       } else {
//         throw 'Failed to fetch stock details. Please try again later.';
//       }
//     }
//   }
// }

//=========================================//



import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_detail_model.dart';

class StockRepository {
  final String baseUrl;

  StockRepository({required this.baseUrl});

  Future<StockDetailModel> fetchStockDetail({
    required String cseId,
    required String stockCode,
  }) async {
    final url = Uri.parse('$baseUrl/jwel_api/get_stock_detail.php');

    try {
      print("========== API REQUEST ==========");
      print("URL: $url");
      print("Body: {'cse_id': '$cseId', 'stock_code': '$stockCode'}");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'cse_id': cseId,
          'stock_code': stockCode,
        },
      );

      print("========== API RESPONSE ==========");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode != 200) {
        print("❌ Network Error: ${response.statusCode}");
        throw Exception('Network error: ${response.statusCode}');
      }

      final jsonBody = json.decode(response.body);

      if (jsonBody['success_code'] == 0 || jsonBody['error_code'] != 0) {
        final errorMsg =
            jsonBody['error_msg']?.toString() ?? 'Something went wrong';

        print("❌ API Error");
        print("Success Code: ${jsonBody['success_code']}");
        print("Error Code: ${jsonBody['error_code']}");
        print("Error Message: $errorMsg");

        throw errorMsg;
      }

      print("✅ API Success");
      print(jsonEncode(jsonBody));

      return StockDetailModel.fromJson(jsonBody);
    } catch (e, stackTrace) {
      print("========== EXCEPTION ==========");
      print("Error: $e");
      print("StackTrace:\n$stackTrace");

      if (e is String) {
        throw e;
      } else {
        throw 'Failed to fetch stock details. Please try again later.';
      }
    }
  }
}