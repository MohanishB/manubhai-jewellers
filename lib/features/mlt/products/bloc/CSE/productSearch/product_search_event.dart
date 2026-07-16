import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

abstract class ProductSearchEvent extends Equatable {
  const ProductSearchEvent();
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductSearchEvent {
  final Map<String, dynamic> filters;
  final bool refresh;
  final String? cseId;

  const LoadProducts({
    this.filters = const {},
    this.refresh = false,
    this.cseId,
  });

  @override
  List<Object?> get props => [filters, refresh, cseId];
}

class ApplyFilters extends ProductSearchEvent {
  final Map<String, dynamic> filters;
  final String? cseId;

  const ApplyFilters(this.filters, {this.cseId});

  @override
  List<Object?> get props => [filters, cseId];
}

class UpdateLoadedProducts extends ProductSearchEvent {
  final List<ProductModel> newProducts;
  const UpdateLoadedProducts(this.newProducts);

  @override
  List<Object?> get props => [newProducts];
}

/// Reset everything (logout / switch user)
class ResetProductSearch extends ProductSearchEvent {
  const ResetProductSearch();
}

class SearchSingleProduct extends ProductSearchEvent {
  final String stockCode;
  final String cseId;

  const SearchSingleProduct(
    this.stockCode, {
    required this.cseId,
  });

  @override
  List<Object?> get props => [stockCode, cseId];
}
