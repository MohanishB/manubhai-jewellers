import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

class SimilarProductsRepository {
  final String baseUrl;

  SimilarProductsRepository({required this.baseUrl});

  static const Set<String> _allowedOptionalKeys = {
    'selling_price_from',
    'selling_price_to',
    'metal_weight_from',
    'metal_weight_to',
    'diamond_wt_from',
    'diamond_wt_to',
    'size_weight_from',
    'size_weight_to',
    'sort_by',
  };

  Future<ProductSearchResponse> searchSimilarProducts({
    required String cseId,
    required String stockCode,
    Map<String, dynamic> filters = const {},
  }) async {
    final url = Uri.parse('$baseUrl/cse_similar_product_search.php');

    final request = http.MultipartRequest('POST', url)
      ..fields['cse_id'] = cseId
      ..fields['stock_code'] = stockCode;

    filters.forEach((key, value) {
      if (!_allowedOptionalKeys.contains(key)) return;
      if (value == null) return;

      if (value is List) {
        for (final item in value) {
          final itemText = item.toString().trim();
          if (itemText.isEmpty) continue;
          request.files.add(
            http.MultipartFile.fromString('$key[]', itemText),
          );
        }
        return;
      }

      final text = value.toString().trim();
      if (text.isEmpty) return;
      request.fields[key] = text;
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Network error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data['success_code'] == 1) {
      return ProductSearchResponse.fromJson(data);
    }

    throw Exception(data['error_msg'] ?? 'Failed to fetch similar products');
  }
}
