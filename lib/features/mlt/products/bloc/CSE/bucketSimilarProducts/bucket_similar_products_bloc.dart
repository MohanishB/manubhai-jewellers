import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/similar_bucket_models.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/bucket_similar_products_repository.dart';

import 'bucket_similar_products_event.dart';
import 'bucket_similar_products_state.dart';

class BucketSimilarProductsBloc
    extends Bloc<BucketSimilarProductsEvent, BucketSimilarProductsState> {
  final BucketSimilarProductsRepository repository;
  static const int _defaultLoadCount = 6;

  BucketSimilarProductsBloc({required this.repository})
      : super(BucketSimilarProductsInitial()) {
    on<LookupBucketSimilarProducts>(_onLookup);
    on<LoadBucketSimilarProducts>(_onLoadBucket);
    on<SelectSeeAlsoBucketSimilarProducts>(_onSelectSeeAlsoBucket);
    on<ApplyBucketSimilarFilters>(_onApplyFilters);
    on<UpdateLoadedBucketSimilarProducts>(_onUpdateLoaded);
    on<ResetBucketSimilarProducts>(_onReset);
  }

  Future<void> _onLookup(
    LookupBucketSimilarProducts event,
    Emitter<BucketSimilarProductsState> emit,
  ) async {
    emit(BucketSimilarProductsLoading());
    try {
      final lookup = await repository.lookup(stockCode: event.stockCode);
      emit(BucketSimilarProductsLookupLoaded(lookup));
    } catch (e) {
      emit(BucketSimilarProductsError(ApiErrorHandler.message(e)));
    }
  }

  Future<void> _onLoadBucket(
    LoadBucketSimilarProducts event,
    Emitter<BucketSimilarProductsState> emit,
  ) async {
    final current = state;
    emit(BucketSimilarProductsLoading());

    try {
      final lookup = current is BucketSimilarProductsLookupLoaded
          ? current.lookup
          : current is BucketSimilarProductsLoaded
              ? current.lookup
              : await repository.lookup(stockCode: event.stockCode);

      final result = await repository.results(
        stockCode: event.stockCode,
        bucketId: event.bucketId,
      );

      final normalBuckets = lookup.buckets;
      final otherBuckets = result.seeAlso.map((e) => e.targetBucket).toList();

      final dropdownBuckets = <SimilarBucket>[
        ...normalBuckets,
        ...otherBuckets,
      ];

      final selectedBucket = normalBuckets.firstWhere(
        (e) => e.id == event.bucketId,
        orElse: () => result.bucket,
      );

      emit(
        _loadedStateFromItems(
          lookup: lookup,
          result: result,
          selectedBucket: selectedBucket,
          selectedBucketKey: selectedBucket.optionKey,
          dropdownBuckets: dropdownBuckets,
          items: result.items,
          filterOptions: result.filterOptions,
          filters: const {},
        ),
      );
    } catch (e) {
      emit(BucketSimilarProductsError(ApiErrorHandler.message(e)));
    }
  }

  void _onSelectSeeAlsoBucket(
    SelectSeeAlsoBucketSimilarProducts event,
    Emitter<BucketSimilarProductsState> emit,
  ) {
    final current = state;
    if (current is! BucketSimilarProductsLoaded) return;

    SimilarSeeAlsoBucket? seeAlso;
    for (final item in current.result.seeAlso) {
      if (item.targetBucket.optionKey == event.bucketKey) {
        seeAlso = item;
        break;
      }
    }

    if (seeAlso == null) return;

    emit(
      _loadedStateFromItems(
        lookup: current.lookup,
        result: current.result,
        selectedBucket: seeAlso.targetBucket,
        selectedBucketKey: seeAlso.targetBucket.optionKey,
        dropdownBuckets: current.dropdownBuckets,
        items: seeAlso.items,
        filterOptions: seeAlso.filterOptions.isNotEmpty
            ? seeAlso.filterOptions
            : current.result.filterOptions,
        filters: const {},
      ),
    );
  }

  void _onApplyFilters(
    ApplyBucketSimilarFilters event,
    Emitter<BucketSimilarProductsState> emit,
  ) {
    final current = state;
    if (current is! BucketSimilarProductsLoaded) return;

    final filteredItems = current.rawItems
        .where((item) => item.matchesFilters(event.filters))
        .toList();

    final allProducts = filteredItems.map((e) => e.toProductModel()).toList();
    emit(
      current.copyWith(
        allProducts: allProducts,
        products: allProducts.take(current.loadCount).toList(),
        appliedFilters: event.filters,
        totalFound: allProducts.length,
      ),
    );
  }

  void _onUpdateLoaded(
    UpdateLoadedBucketSimilarProducts event,
    Emitter<BucketSimilarProductsState> emit,
  ) {
    final current = state;
    if (current is BucketSimilarProductsLoaded) {
      emit(current.copyWith(products: event.products));
    }
  }

  void _onReset(
    ResetBucketSimilarProducts event,
    Emitter<BucketSimilarProductsState> emit,
  ) {
    emit(BucketSimilarProductsInitial());
  }

  BucketSimilarProductsLoaded _loadedStateFromItems({
    required SimilarLookupResponse lookup,
    required BucketSimilarResultsResponse result,
    required SimilarBucket selectedBucket,
    required String selectedBucketKey,
    required List<SimilarBucket> dropdownBuckets,
    required List<BucketSimilarResultItem> items,
    required List<SimilarFilterOption> filterOptions,
    required Map<String, Set<String>> filters,
  }) {
    final filteredItems =
        filters.isEmpty ? items : items.where((e) => e.matchesFilters(filters)).toList();
    final allProducts = filteredItems.map((e) => e.toProductModel()).toList();

    return BucketSimilarProductsLoaded(
      lookup: lookup,
      selectedBucket: selectedBucket,
      selectedBucketKey: selectedBucketKey,
      result: result,
      dropdownBuckets: dropdownBuckets,
      rawItems: items,
      allProducts: allProducts,
      products: allProducts.take(_defaultLoadCount).toList(),
      filterOptions: _filterOptionsForItems(filterOptions, items),
      appliedFilters: filters,
      totalFound: allProducts.length,
      loadCount: _defaultLoadCount,
    );
  }

  List<SimilarFilterOption> _filterOptionsForItems(
    List<SimilarFilterOption> options,
    List<BucketSimilarResultItem> items,
  ) {
    return options.map((option) {
      if (option.isNumeric) return option;

      // results.php sends discrete filter values in filter_options. Keep those
      // values as-is so the drawer remains in API sequence and does not become
      // empty when product cards expose only a subset of fields.
      if (option.values.isNotEmpty) return option;

      final values = <String>{};
      for (final item in items) {
        values.addAll(item.valuesForColumn(option.column));
      }

      return option.copyWithValues(values.toList());
    }).where((option) {
      return option.isNumeric || option.values.isNotEmpty;
    }).toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
  }
}
