import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/CSE_models/received_safe_update_model.dart';

class ReceivedSafeUpdateRepository {
  static const _baseUrl =
      'https://vitazreportingservices.com/mlt_app_webservices';
  // ReceivedSafeUpdateRepository({required this.baseUrl});

  Future<ReceivedSafeUpdateResponse> updateStatus({
    required String cseId,
    required String safeRequestId,
    required List<String> stockList,
    required int status,
  }) async {
    final uri = Uri.parse('$_baseUrl/cse_update_out_of_safe_request_status.php');

    final body = {
      'cse_id': cseId,
      'safe_request_id': safeRequestId,
      'status': status.toString(),
      for (int i = 0; i < stockList.length; i++) 'stock_list[$i]': stockList[i],
    };

    final response = await http.post(uri, body: body);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ReceivedSafeUpdateResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to update safe request status');
    }
  }
}
