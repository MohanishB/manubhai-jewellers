import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_user_model.dart';

class AuthRepository {
  final String baseUrl;

  AuthRepository({required this.baseUrl});

  Future<AuthUser> login({
    required String username,
    required String password,
    required String deviceToken,
    required String cseDevice,
  }) async {
    final url = Uri.parse('$baseUrl/cse_login.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_email': username, 'user_password': password, 'device_token': deviceToken, 'cse_device': cseDevice},
      );

      if (response.statusCode != 200) {
        throw 'Network error: ${response.statusCode}';
      }

      final jsonBody = json.decode(response.body);

      // Handle failure response from backend
      if (jsonBody['success_code'] == 0 || jsonBody['error_code'] != 0) {
        final msg = jsonBody['error_msg']?.toString() ?? 'Login failed';
        throw msg;
      }

      // Parse user data
      return AuthUser.fromJson(jsonBody);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Something went wrong. Please try again.';
    }
  }
}
