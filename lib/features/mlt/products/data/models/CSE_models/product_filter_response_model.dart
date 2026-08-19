import 'product_filter_model.dart';
import 'product_filter_sort_by_model.dart';

class ProductFilterResponse {
  final List<ProductFilterModel> filters;
  final List<ProductSortByModel> sortBy;
  final String cseId;
  final String cseMltBranch;
  final List<String> cseMltLocation;

  ProductFilterResponse({
    required this.filters,
    required this.sortBy,
    this.cseId = '',
    this.cseMltBranch = '',
    this.cseMltLocation = const [],
  });

  factory ProductFilterResponse.fromJson(Map<String, dynamic> json) {
    final filterList = (json['product_filter'] is List)
        ? (json['product_filter'] as List)
            .map((e) => ProductFilterModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ProductFilterModel>[];

    final sortList = (json['product_sort_by'] is List)
        ? (json['product_sort_by'] as List)
            .map((e) => ProductSortByModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ProductSortByModel>[];

    final cseDetails = json['cse_details'] is Map
        ? Map<String, dynamic>.from(json['cse_details'] as Map)
        : const <String, dynamic>{};

    return ProductFilterResponse(
      filters: filterList,
      sortBy: sortList,
      cseId: cseDetails['cse_id']?.toString().trim() ?? '',
      cseMltBranch: cseDetails['cse_mlt_branch']?.toString().trim() ?? '',
      cseMltLocation: cseDetails['cse_mlt_location'] is List
          ? (cseDetails['cse_mlt_location'] as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
    );
  }
}
