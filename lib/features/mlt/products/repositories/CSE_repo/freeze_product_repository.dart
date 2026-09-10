import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

class FreezeProductResult {
  final bool success;
  final int errorCode;
  final String message;
  final FreezedProductStatus status;
  const FreezeProductResult({required this.success, required this.errorCode, required this.message, required this.status});
}

class FreezedProductListItem {
  final String stockCode, lob, category, productImage;
  const FreezedProductListItem({required this.stockCode, required this.lob, required this.category, required this.productImage});
  factory FreezedProductListItem.fromJson(Map<String,dynamic> j) => FreezedProductListItem(
    stockCode: '${j['stock_code'] ?? ''}', lob: '${j['lob'] ?? ''}', category: '${j['category'] ?? ''}', productImage: '${j['product_image'] ?? ''}');
}

class FreezeProductRepository {
  final String baseUrl;
  const FreezeProductRepository({required this.baseUrl});

  Future<FreezeProductResult> setFreeze({required String cseId, required String stockCode, required bool freeze}) async {
    final response = await http.post(Uri.parse('$baseUrl/cse_freeze_unfreeze_product.php'), body: {
      'cse_id': cseId, 'stock_code': stockCode, 'freeze': freeze ? '1' : '0',
    });
    if (response.statusCode != 200) throw Exception('Network error: ${response.statusCode}');
    final data = json.decode(response.body) as Map<String,dynamic>;
    final errorCode = int.tryParse('${data['error_code'] ?? 0}') ?? 0;
    final parsedStatus = FreezedProductStatus.fromJson(data['freezed_product']);
    // 2004 means this freeze attempt lost a race to another CSE. Treat the
    // server response as authoritative and render it as "by other" even if
    // an older backend payload reports inconsistent by_own/by_other flags.
    final status = errorCode == 2004
        ? FreezedProductStatus(
            freezed: true,
            byOwn: false,
            byOther: true,
            cseName: parsedStatus.cseName,
          )
        : parsedStatus;
    final result = FreezeProductResult(
      success: int.tryParse('${data['success_code'] ?? 0}') == 1,
      errorCode: errorCode,
      message: '${data['error_msg'] ?? ''}',
      status: status,
    );
    // Error 2004 still carries authoritative current freeze status.
    if (!result.success && result.errorCode != 2004) throw Exception(result.message.isEmpty ? 'Unable to update product' : result.message);
    return result;
  }

  Future<List<FreezedProductListItem>> getFreezedProducts(String cseId) async {
    final response = await http.post(Uri.parse('$baseUrl/cse_product_freezed_list.php'), body: {'cse_id': cseId});
    if (response.statusCode != 200) throw Exception('Network error: ${response.statusCode}');
    final data = json.decode(response.body) as Map<String,dynamic>;
    if (int.tryParse('${data['success_code'] ?? 0}') != 1) throw Exception('${data['error_msg'] ?? 'Unable to load freezed products'}');
    return (data['product_list'] as List<dynamic>? ?? []).whereType<Map>().map((e)=>FreezedProductListItem.fromJson(Map<String,dynamic>.from(e))).toList();
  }
}
