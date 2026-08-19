import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/similar_bucket_models.dart';

class BucketSimilarProductsRepository {
  final String baseUrl;
  final http.Client _client;

  BucketSimilarProductsRepository({
    this.baseUrl = 'https://vitazreportingservices.com/mlt_api/v1/',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Uri _uri(String endpoint) => Uri.parse('$baseUrl$endpoint');

  

  Future<SimilarLookupResponse> lookup({
    required String stockCode,
    required String cseId,
    required String cseMltBranch,
    required List<String> cseMltLocation,
  }) async {
  final request = {
    'stock_code': stockCode,
    'cse_id': cseId,
    'cse_mlt_branch': cseMltBranch,
    'cse_mlt_location': cseMltLocation,
  };

  print('========== LOOKUP API ==========');
  print('URL      : ${_uri('lookup.php')}');
  print('REQUEST  : ${jsonEncode(request)}');

  final response = await _client.post(
    _uri('lookup.php'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode(request),
  );

  print('STATUS   : ${response.statusCode}');
  print('RESPONSE : ${response.body}');
  print('===============================');

  if (response.statusCode != 200) {
    // throw Exception('Lookup failed: ${response.statusCode}');
    throw Exception('Bucket not found for stock code: $stockCode');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (data['ok'] == true) return SimilarLookupResponse.fromJson(data);

  throw Exception(data['message'] ?? data['error'] ?? 'Bucket not found for stock code: $stockCode');
}

  

  Future<BucketSimilarResultsResponse> results({
    required String stockCode,
    required int bucketId,
    required String cseId,
    required String cseMltBranch,
    required List<String> cseMltLocation,
  }) async {
  final request = {
    'stock_code': stockCode,
    'bucket_id': bucketId,
    'cse_id': cseId,
    'cse_mlt_branch': cseMltBranch,
    'cse_mlt_location': cseMltLocation,
  };

  print('========== RESULTS API ==========');
  print('URL      : ${_uri('results.php')}');
  print('REQUEST  : ${jsonEncode(request)}');

  final response = await _client.post(
    _uri('results.php'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode(request),
  );

  print('STATUS   : ${response.statusCode}');
  print('RESPONSE : ${response.body}');
  print('================================');

  if (response.statusCode != 200) {
    throw Exception('Results failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  if (data['ok'] == true) return BucketSimilarResultsResponse.fromJson(data);

  throw Exception(data['message'] ?? data['error'] ?? 'Results failed');
}
}
