import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

abstract class ProductSearchState extends Equatable {
  const ProductSearchState();
  @override
  List<Object?> get props => [];
}

class ProductSearchInitial extends ProductSearchState {}

class ProductSearchLoading extends ProductSearchState {}

class ProductSearchLoaded extends ProductSearchState {
  final List<ProductModel> allProducts; // full list from API
  final List<ProductModel> products; // currently visible subset
  final Map<String, dynamic> appliedFilters;
  final int maxSafeCount;
  final int totalFound;
  final int loadCount; // number of products per batch (load_product_count)

  const ProductSearchLoaded({
    required this.allProducts,
    required this.products,
    required this.appliedFilters,
    required this.maxSafeCount,
    required this.totalFound,
    this.loadCount = 10,
  });

  ProductSearchLoaded copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? products,
    int? totalFound,
  }) {
    return ProductSearchLoaded(
      allProducts: allProducts ?? this.allProducts,
      products: products ?? this.products,
      appliedFilters: appliedFilters,
      maxSafeCount: maxSafeCount,
      totalFound: totalFound ?? this.totalFound,
      loadCount: loadCount,
    );
  }

  @override
  List<Object?> get props =>
      [allProducts, products, appliedFilters, totalFound, maxSafeCount];
}

class ProductSearchError extends ProductSearchState {
  final String message;
  const ProductSearchError(this.message);
}
