// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_response_model.dart';

// class ProductFilterRepository {
//   final String baseUrl;

//   ProductFilterRepository({required this.baseUrl});

//   Future<ProductFilterResponse> fetchFilters(String cseId) async {
//     final url = Uri.parse('$baseUrl/cse_product_filters.php');
//     final response = await http.post(url, body: {'cse_id': cseId});

//     if (response.statusCode != 200) {
//       throw Exception('HTTP ${response.statusCode}');
//     }

//     final data = json.decode(response.body);

//     if (data['success_code'] == 1) {
//       return ProductFilterResponse.fromJson(Map<String, dynamic>.from(data));
//     }

//     throw Exception(data['display_msg'] ?? 'Failed to fetch filters');
//   }
// }

//==========================================//

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_response_model.dart';

class ProductFilterRepository {
  final String baseUrl;

  ProductFilterRepository({required this.baseUrl});

  Future<ProductFilterResponse> fetchMainFilters(String cseId) async {
    final url = Uri.parse('$baseUrl/cse_product_filters_main.php');

    final response = await http.post(url, body: {
      'cse_id': cseId,
    });

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);

    if (data['success_code'] == 1) {
      return ProductFilterResponse.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception(data['display_msg'] ?? 'Failed to fetch main filters');
  }

  Future<ProductFilterResponse> fetchSubFilters({
    required String cseId,
    required String lob,
    required String category,
  }) async {
    final url = Uri.parse('$baseUrl/cse_product_filters_sub.php');

    final response = await http.post(url, body: {
      'cse_id': cseId,
      'lob': lob,
      'category': category,
    });

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);

    if (data['success_code'] == 1) {
      return ProductFilterResponse.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception(data['display_msg'] ?? 'Failed to fetch sub filters');
  }

  /// Kept for backward compatibility.
  Future<ProductFilterResponse> fetchFilters(String cseId) {
    return fetchMainFilters(cseId);
  }
}