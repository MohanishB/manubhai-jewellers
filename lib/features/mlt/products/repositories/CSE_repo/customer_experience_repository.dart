import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/customer_experience_models.dart';



class CustomerExperienceRepository {
   

      static const _baseUrl =
      'https://vitazreportingservices.com/mlt_app_webservices';

  final http.Client _client;

  CustomerExperienceRepository({http.Client? client})
      : _client = client ?? http.Client();

  Future<CustomerExperienceResponse> submit(
    CustomerExperienceRequest request,
  ) async {
    try {
      // Use multipart to match Postman "form-data" exactly
      // final uri = Uri.parse(_url);
      final uri = Uri.parse('$_baseUrl/cse_customer_experience_save.php');
      final req = http.MultipartRequest('POST', uri);
      req.fields.addAll(request.toFields());

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode != 200) {
        throw Exception('Server error (${resp.statusCode}). Please try again.');
      }

      final parsed = CustomerExperienceResponse.fromRaw(resp.body);

      if (!parsed.isSuccess) {
        final msg = (parsed.errorMsg.trim().isNotEmpty)
            ? parsed.errorMsg
            : 'Unable to submit feedback. Please try again.';
        throw Exception(msg);
      }

      return parsed;
    } catch (e) {
      // Keep messages user-friendly
      final msg = e.toString().replaceFirst('Exception:', '').trim();
      throw Exception(msg.isEmpty ? 'Something went wrong. Please try again.' : msg);
    }
  }
}
