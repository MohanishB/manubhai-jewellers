import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/CSE_models/received_safe_model.dart';

class ReceivedSafeRepository {
  final String baseUrl;

  ReceivedSafeRepository({required this.baseUrl});

  Future<ReceivedSafeResponse> fetchReceivedSafeList(String cseId) async {
    final uri = Uri.parse('$baseUrl/cse_request_out_of_safe_stock_list.php');
    final response = await http.post(uri, body: {'cse_id': cseId});

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ReceivedSafeResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch received safe list');
    }
  }
}
