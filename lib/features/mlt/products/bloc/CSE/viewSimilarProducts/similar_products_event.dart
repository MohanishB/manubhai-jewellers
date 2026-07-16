import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

abstract class SimilarProductsEvent extends Equatable {
  const SimilarProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSimilarProducts extends SimilarProductsEvent {
  final String cseId;
  final String stockCode;
  final Map<String, dynamic> filters;

  const LoadSimilarProducts({
    required this.cseId,
    required this.stockCode,
    this.filters = const {},
  });

  @override
  List<Object?> get props => [cseId, stockCode, filters];
}

class UpdateLoadedSimilarProducts extends SimilarProductsEvent {
  final List<ProductModel> newProducts;

  const UpdateLoadedSimilarProducts(this.newProducts);

  @override
  List<Object?> get props => [newProducts];
}

class ResetSimilarProducts extends SimilarProductsEvent {
  const ResetSimilarProducts();
}
