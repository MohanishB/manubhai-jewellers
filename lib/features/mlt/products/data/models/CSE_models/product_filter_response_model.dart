import 'product_filter_model.dart';
import 'product_filter_sort_by_model.dart';

class ProductFilterResponse {
  final List<ProductFilterModel> filters;
  final List<ProductSortByModel> sortBy;

  ProductFilterResponse({
    required this.filters,
    required this.sortBy,
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

    return ProductFilterResponse(filters: filterList, sortBy: sortList);
  }
}
