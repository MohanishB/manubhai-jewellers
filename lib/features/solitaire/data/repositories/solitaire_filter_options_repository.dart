import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/solitaire/data/models/filter_options_response_model.dart';

class SolitaireFilterOptionsRepository {
  final String baseUrl;

  SolitaireFilterOptionsRepository({required this.baseUrl});

  Future<FilterShapesResponse> fetchFilterShapes({
    required String cseId,
    required String stockCode,
  }) async {
    final url = Uri.parse('$baseUrl/get_filter_shape.php');

    final response = await http.post(
      url,
      body: {
        'cse_id': cseId,
        'stock_code': stockCode,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);

    if (data is Map<String, dynamic>) {
      if (data['success_code'].toString() == '1') {
        return FilterShapesResponse.fromJson(data);
      }
      throw Exception(data['error_msg'] ?? 'Failed to fetch solitaire shapes');
    }

    throw Exception('Invalid response');
  }

  Future<FilterOptionsResponse> fetchFilterOptions({
    required String cseId,
    required String stockCode,
  }) async {
    final url = Uri.parse('$baseUrl/get_filter_options.php');

    final response = await http.post(
      url,
      body: {
        'cse_id': cseId,
        'stock_code': stockCode,
      },
    );

    return _parseFilterOptionsResponse(response);
  }

  Future<FilterOptionsResponse> fetchFilterOptionsByShape({
    required String cseId,
    required String stockCode,
    required String shape,
  }) async {
    final url = Uri.parse('$baseUrl/get_filter_options_sub.php');

    final response = await http.post(
      url,
      body: {
        'cse_id': cseId,
        'stock_code': stockCode,
        'shape': shape,
      },
    );

    return _parseFilterOptionsResponse(response);
  }

  FilterOptionsResponse _parseFilterOptionsResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);

    if (data is Map<String, dynamic>) {
      if (data['success_code'].toString() == '1') {
        return FilterOptionsResponse.fromJson(data);
      }
      throw Exception(data['error_msg'] ?? 'Failed to fetch filter options');
    }

    throw Exception('Invalid response');
  }
}
