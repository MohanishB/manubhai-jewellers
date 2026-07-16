import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

abstract class SimilarProductsState extends Equatable {
  const SimilarProductsState();

  @override
  List<Object?> get props => [];
}

class SimilarProductsInitial extends SimilarProductsState {}

class SimilarProductsLoading extends SimilarProductsState {}

class SimilarProductsLoaded extends SimilarProductsState {
  final List<ProductModel> allProducts;
  final List<ProductModel> products;
  final String stockCode;
  final Map<String, dynamic> appliedFilters;
  final int maxSafeCount;
  final int totalFound;
  final int loadCount;

  const SimilarProductsLoaded({
    required this.allProducts,
    required this.products,
    required this.stockCode,
    required this.appliedFilters,
    required this.maxSafeCount,
    required this.totalFound,
    required this.loadCount,
  });

  SimilarProductsLoaded copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? products,
    int? totalFound,
  }) {
    return SimilarProductsLoaded(
      allProducts: allProducts ?? this.allProducts,
      products: products ?? this.products,
      stockCode: stockCode,
      appliedFilters: appliedFilters,
      maxSafeCount: maxSafeCount,
      totalFound: totalFound ?? this.totalFound,
      loadCount: loadCount,
    );
  }

  @override
  List<Object?> get props => [
        allProducts,
        products,
        stockCode,
        appliedFilters,
        maxSafeCount,
        totalFound,
        loadCount,
      ];
}

class SimilarProductsError extends SimilarProductsState {
  final String message;

  const SimilarProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
