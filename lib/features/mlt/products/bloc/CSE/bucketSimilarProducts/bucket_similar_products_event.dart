import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

abstract class BucketSimilarProductsEvent extends Equatable {
  const BucketSimilarProductsEvent();

  @override
  List<Object?> get props => [];
}

class LookupBucketSimilarProducts extends BucketSimilarProductsEvent {
  final String stockCode;
  final String cseId;
  final String cseMltBranch;
  final List<String> cseMltLocation;

  const LookupBucketSimilarProducts({
    required this.stockCode,
    this.cseId = '',
    this.cseMltBranch = '',
    this.cseMltLocation = const [],
  });

  @override
  List<Object?> get props => [
        stockCode,
        cseId,
        cseMltBranch,
        cseMltLocation,
      ];
}

class LoadBucketSimilarProducts extends BucketSimilarProductsEvent {
  final String stockCode;
  final int bucketId;
  final String preferredBranch;
  final String cseId;
  final String cseMltBranch;
  final List<String> cseMltLocation;

  const LoadBucketSimilarProducts({
    required this.stockCode,
    required this.bucketId,
    this.preferredBranch = '',
    this.cseId = '',
    this.cseMltBranch = '',
    this.cseMltLocation = const [],
  });

  @override
  List<Object?> get props => [
        stockCode,
        bucketId,
        preferredBranch,
        cseId,
        cseMltBranch,
        cseMltLocation,
      ];
}

class SelectSeeAlsoBucketSimilarProducts extends BucketSimilarProductsEvent {
  final String bucketKey;

  const SelectSeeAlsoBucketSimilarProducts({required this.bucketKey});

  @override
  List<Object?> get props => [bucketKey];
}

class ApplyBucketSimilarFilters extends BucketSimilarProductsEvent {
  final Map<String, Set<String>> filters;

  const ApplyBucketSimilarFilters(this.filters);

  @override
  List<Object?> get props => [filters];
}

class UpdateLoadedBucketSimilarProducts extends BucketSimilarProductsEvent {
  final List<ProductModel> products;

  const UpdateLoadedBucketSimilarProducts(this.products);

  @override
  List<Object?> get props => [products];
}

class ResetBucketSimilarProducts extends BucketSimilarProductsEvent {
  const ResetBucketSimilarProducts();
}
