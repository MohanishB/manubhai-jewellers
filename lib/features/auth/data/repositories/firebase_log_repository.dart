import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/auth/data/models/firebase_log_model.dart';


class CSEFirebaseLogRepository {
  final String baseUrl;

  CSEFirebaseLogRepository({required this.baseUrl});

  /// 🔹 Called when user logs in or app restores session
  Future<CSEFirebaseLogResponse> logLogin({
    required String cseId,
    required String cseFirebaseId,
  }) async {
    final url = Uri.parse('$baseUrl/cse_login_log.php');
    final response = await http.post(url, body: {
      'cse_id': cseId,
      'cse_firebase_id': cseFirebaseId,
    });

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return CSEFirebaseLogResponse.fromJson(jsonBody);
    } else {
      throw Exception('Login log failed [${response.statusCode}]');
    }
  }

  /// 🔹 Called on logout
  Future<CSEFirebaseLogResponse> logLogout({
    required String cseId,
    required String cseFirebaseId,
  }) async {
    final url = Uri.parse('$baseUrl/cse_logout.php');
    final response = await http.post(url, body: {
      'cse_id': cseId,
      'cse_firebase_id': cseFirebaseId,
    });

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return CSEFirebaseLogResponse.fromJson(jsonBody);
    } else {
      throw Exception('Logout log failed [${response.statusCode}]');
    }
  }
}
