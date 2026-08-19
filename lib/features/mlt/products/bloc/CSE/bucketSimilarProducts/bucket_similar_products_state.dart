import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/similar_bucket_models.dart';

abstract class BucketSimilarProductsState extends Equatable {
  const BucketSimilarProductsState();

  @override
  List<Object?> get props => [];
}

class BucketSimilarProductsInitial extends BucketSimilarProductsState {}

class BucketSimilarProductsLoading extends BucketSimilarProductsState {}

class BucketSimilarProductsLookupLoaded extends BucketSimilarProductsState {
  final SimilarLookupResponse lookup;

  const BucketSimilarProductsLookupLoaded(this.lookup);

  @override
  List<Object?> get props => [lookup];
}

class BucketSimilarProductsLoaded extends BucketSimilarProductsState {
  final SimilarLookupResponse lookup;
  final SimilarBucket selectedBucket;
  final String selectedBucketKey;
  final BucketSimilarResultsResponse result;
  final List<SimilarBucket> dropdownBuckets;
  final List<BucketSimilarResultItem> rawItems;
  final List<ProductModel> allProducts;
  final List<ProductModel> products;
  final List<SimilarFilterOption> filterOptions;
  final Map<String, Set<String>> appliedFilters;
  final String preferredBranch;
  final int totalFound;
  final int loadCount;
  final int maxSafeCount;

  const BucketSimilarProductsLoaded({
    required this.lookup,
    required this.selectedBucket,
    required this.selectedBucketKey,
    required this.result,
    required this.dropdownBuckets,
    required this.rawItems,
    required this.allProducts,
    required this.products,
    required this.filterOptions,
    required this.appliedFilters,
    this.preferredBranch = '',
    required this.totalFound,
    this.loadCount = 6,
    this.maxSafeCount = 6,
  });

  BucketSimilarProductsLoaded copyWith({
    SimilarBucket? selectedBucket,
    String? selectedBucketKey,
    List<SimilarBucket>? dropdownBuckets,
    List<BucketSimilarResultItem>? rawItems,
    List<ProductModel>? allProducts,
    List<ProductModel>? products,
    Map<String, Set<String>>? appliedFilters,
    String? preferredBranch,
    int? totalFound,
  }) {
    return BucketSimilarProductsLoaded(
      lookup: lookup,
      selectedBucket: selectedBucket ?? this.selectedBucket,
      selectedBucketKey: selectedBucketKey ?? this.selectedBucketKey,
      result: result,
      dropdownBuckets: dropdownBuckets ?? this.dropdownBuckets,
      rawItems: rawItems ?? this.rawItems,
      allProducts: allProducts ?? this.allProducts,
      products: products ?? this.products,
      filterOptions: filterOptions,
      appliedFilters: appliedFilters ?? this.appliedFilters,
      preferredBranch: preferredBranch ?? this.preferredBranch,
      totalFound: totalFound ?? this.totalFound,
      loadCount: loadCount,
      maxSafeCount: maxSafeCount,
    );
  }

  @override
  List<Object?> get props => [
        lookup,
        selectedBucket,
        selectedBucketKey,
        result,
        dropdownBuckets,
        rawItems,
        allProducts,
        products,
        filterOptions,
        appliedFilters,
        preferredBranch,
        totalFound,
        loadCount,
        maxSafeCount,
      ];
}

class BucketSimilarProductsError extends BucketSimilarProductsState {
  final String message;

  const BucketSimilarProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
