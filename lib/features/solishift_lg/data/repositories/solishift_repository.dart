import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/solishift_lg/data/models/solishift_stock_model.dart';

class SoliShiftLgRepository {
  final String baseUrl;

  const SoliShiftLgRepository({
    this.baseUrl =
        'https://vitazreportingservices.com/solishift-lg/app_webservices',
  });

  Future<SoliShiftLgResponse> fetchRingData({
    required String cseId,
    required String stockCode,
  }) {
    return _post(
      endpoint: 'get_solishift_lg_data.php',
      body: {
        'cse_id': cseId,
        'stock_code': stockCode,
      },
    );
  }

  Future<SoliShiftLgResponse> updateByCarat({
    required RawEntries rawEntries,
    required String newSolitaireCt,
    required String newDiamondCt,
  }) {
    final solitaire = num.tryParse(newSolitaireCt.trim()) ?? 0;
    final diamond = solitaire > 0
        ? 0
        : (num.tryParse(newDiamondCt.replaceAll('ct', '').trim()) ?? 0);

    return _post(
      endpoint: 'get_lg_carat_update.php',
      body: {
        'labour_amount': rawEntries.labourAmount.toString(),
        'metal_amount': rawEntries.metalAmount.toString(),
        'solitaire_wt': rawEntries.solitaireWt.toString(),
        'solitaire_details': jsonEncode(rawEntries.solitaireDetails),
        'diamond_details': jsonEncode(rawEntries.diamondDetails),
        'new_solitaire_ct': solitaire.toString(),
        'new_diamond_ct': diamond.toString(),
      },
    );
  }

  Future<SoliShiftLgResponse> updateByBudget({
    required RawEntries rawEntries,
    required String budget,
  }) {
    return _post(
      endpoint: 'get_lg_budget_update.php',
      body: {
        'labour_amount': rawEntries.labourAmount.toString(),
        'metal_amount': rawEntries.metalAmount.toString(),
        'solitaire_details': jsonEncode(rawEntries.solitaireDetails),
        'diamond_details': jsonEncode(rawEntries.diamondDetails),
        'budget': (num.tryParse(budget.trim()) ?? 0).toString(),
      },
    );
  }

  Future<SoliShiftLgResponse> _post({
    required String endpoint,
    required Map<String, String> body,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    print('🔹 [POST] $url');
    body.forEach((key, value) => print('   $key = $value'));

    final response = await http.post(url, body: body);

    print('🔹 Status: ${response.statusCode}');
    print(
      '✅ Response: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception('Network error: ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid server response');
    }

    if (decoded['success_code'] == 1) {
      return SoliShiftLgResponse.fromJson(decoded);
    }

    throw Exception(
      decoded['error_msg']?.toString().isNotEmpty == true
          ? decoded['error_msg'].toString()
          : 'Failed to fetch SoliShift LG data',
    );
  }
}
