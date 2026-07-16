import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/solishift_lg/data/models/solishift_stock_model.dart';

class SoliShiftLgRepository {
  final String baseUrl;

  const SoliShiftLgRepository({
    this.baseUrl = 'https://vitazreportingservices.com/solishift-lg/app_webservices',
  });

  Future<SoliShiftLgResponse> fetchRingData({
    required String cseId,
    required String stockCode,
    String newSolitaireCt = '',
  }) async {
    final url = Uri.parse('$baseUrl/get_lg_ring_data.php');

    final response = await http.post(
      url,
      body: {
        'cse_id': cseId,
        'stock_code': stockCode,
        'new_solitaire_ct': newSolitaireCt,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Network error: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data['success_code'] == 1) {
      return SoliShiftLgResponse.fromJson(data);
    }

    throw Exception(
      data['error_msg']?.toString().isNotEmpty == true
          ? data['error_msg'].toString()
          : 'Failed to fetch SoliShift LG data',
    );
  }
}
