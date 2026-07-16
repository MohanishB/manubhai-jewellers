// lib/features/solitaire/data/repositories/solitaire_filter_diamonds_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/solitaire/data/models/solitaire_diamond_models.dart';

class SolitaireFilterDiamondsRepository {
  final String baseUrl;
  SolitaireFilterDiamondsRepository({required this.baseUrl});

  Future<FilterDiamondsResponse> fetchDiamonds({
    required String cseId,
    required String stockCode,
    String? shape,

    // Optional filters (send ONLY if user selected)
    String? priceMin,
    String? priceMax,
    String? caratMin,
    String? caratMax,
    String? colorCsv,
    String? clarityCsv,
    String? cutCsv,
    String? certCsv,

    // optional sort
    String? sortBy,
    String? sortOrder,

    // search within results
    String? lotNumber,
    String? certNumber,
    String? searchCaratMin,
    String? searchCaratMax,
    String? searchPriceMin,
    String? searchPriceMax,
  }) async {
    // final url = Uri.parse('$baseUrl/step2_filter_diamonds.php');
    final url = Uri.parse('$baseUrl/step2_filter_diamonds_ver2.php');
    

    final body = <String, String>{
      'cse_id': cseId,
      'stock_code': stockCode,
    };

    void putIf(String key, String? v) {
      if (v == null) return;
      final t = v.trim();
      if (t.isEmpty) return;
      body[key] = t;
    }

    // filters
    putIf('shape', shape);
    putIf('price_min', priceMin);
    putIf('price_max', priceMax);
    putIf('carat_min', caratMin);
    putIf('carat_max', caratMax);
    putIf('color', colorCsv);
    putIf('clarity', clarityCsv);
    putIf('cut', cutCsv);
    putIf('cert', certCsv);

    // sort
    putIf('sort_by', sortBy);
    putIf('sort_order', sortOrder);

    // search within results (API doc shows these)
    putIf('search_carat_min', searchCaratMin);
    putIf('search_carat_max', searchCaratMax);
    putIf('search_price_min', searchPriceMin);
    putIf('search_price_max', searchPriceMax);

    // lot/cert inputs (common backend naming)
    putIf('lot_number', lotNumber);
    putIf('cert_no', certNumber);

    final resp = await http.post(url, body: body);

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final data = json.decode(resp.body);
    final map = Map<String, dynamic>.from(data);

    if ((map['success_code'] ?? 0) == 1) {
      return FilterDiamondsResponse.fromJson(map);
    }

    throw Exception(map['error_msg'] ?? 'Failed to fetch diamonds');
  }
}
