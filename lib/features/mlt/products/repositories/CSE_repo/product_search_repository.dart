// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

// class ProductSearchRepository {
//   final String baseUrl;
//   ProductSearchRepository({required this.baseUrl});

//   Future<ProductSearchResponse> searchProducts({
//     required String cseId,
//     required Map<String, dynamic> filters,
//     int offset = 0,
//   }) async {
//     final url = Uri.parse('$baseUrl/cse_product_search.php');

//     // ✅ Use MultipartRequest for arrays
//     final request = http.MultipartRequest('POST', url)
//       ..fields['cse_id'] = cseId
//       ..fields['offset'] = offset.toString();

//     // ✅ Add filters
//     filters.forEach((key, value) {
//       if (value is List) {
//         for (var item in value) {
//           // ✅ Each checkbox value must be a separate "file field"
//           request.files.add(http.MultipartFile.fromString('$key[]', item.toString()));
//         }
//       } else {
//         request.fields[key] = value.toString();
//       }
//     });

//     // 🧠 Debug Log
//     print('🔹 [POST] $url');
//     for (final entry in request.fields.entries) {
//       print('   ${entry.key} = ${entry.value}');
//     }
//     // for (final file in request.files) {
//     //   print('   ${file.field} = ${await file.length()} bytes (${file.field})');
//     // }

//     // ✅ Send request
//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);

//       print('✅ Product Search Response: ${response.body.substring(0, 200)}...');

//       if (data['success_code'] == 1) {
//         return ProductSearchResponse.fromJson(data);
//       } else {
//         throw Exception(data['error_msg'] ?? 'Failed to fetch products');
//       }
//     } else {
//       throw Exception('Network error: ${response.statusCode}');
//     }
//   }
// }

/////======================///////////////


import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

class ProductSearchRepository {
  final String baseUrl;

  ProductSearchRepository({required this.baseUrl});

  Future<ProductSearchResponse> searchProducts({
    required String cseId,
    required Map<String, dynamic> filters,
    int offset = 0,
  }) async {
    final url = Uri.parse('$baseUrl/cse_product_search.php');

    final request = http.MultipartRequest('POST', url)
      ..fields['cse_id'] = cseId
      ..fields['offset'] = offset.toString();

    filters.forEach((key, value) {
      if (value is List) {
        for (final item in value) {
          request.files.add(
            http.MultipartFile.fromString(
              '$key[]',
              item.toString(),
            ),
          );
        }
      } else if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    print('🔹 [POST] $url');

    for (final entry in request.fields.entries) {
      print('   ${entry.key} = ${entry.value}');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print(
        '✅ Product Search Response: '
        '${response.body.length > 200 ? response.body.substring(0, 200) : response.body}...',
      );

      if (data['success_code'] == 1) {
        return ProductSearchResponse.fromJson(data);
      } else {
        throw Exception(data['error_msg'] ?? 'Failed to fetch products');
      }
    } else {
      throw Exception('Network error: ${response.statusCode}');
    }
  }
  Future<ProductSearchResponse> searchSingleProduct({
    required String cseId,
    required String stockCode,
  }) async {
    final url = Uri.parse('$baseUrl/cse_single_product_search.php');

    final response = await http.post(
      url,
      body: {
        'cse_id': cseId,
        'stock_code': stockCode,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print(
        '✅ Single Product Search Response: '
        '${response.body.length > 200 ? response.body.substring(0, 200) : response.body}...',
      );

      if (data['success_code'] == 1) {
        return ProductSearchResponse.fromJson(data);
      } else {
        throw Exception(data['error_msg'] ?? 'Failed to fetch product');
      }
    } else {
      throw Exception('Network error: ${response.statusCode}');
    }
  }

}