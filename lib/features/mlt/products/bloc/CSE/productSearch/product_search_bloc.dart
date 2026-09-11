import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/product_search_repository.dart';
import 'product_search_event.dart';
import 'product_search_state.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

class ProductSearchBloc extends Bloc<ProductSearchEvent, ProductSearchState> {
  final ProductSearchRepository repository;
  final String cseId;

  String _effectiveCseId(String? eventCseId, Map<String, dynamic>? filters) {
    final fromEvent = (eventCseId ?? '').trim();
    if (fromEvent.isNotEmpty) return fromEvent;

    final fromFilters = (filters?['cse_id'] ?? '').toString().trim();
    if (fromFilters.isNotEmpty) return fromFilters;

    return cseId.trim();
  }

  ProductSearchBloc({required this.repository, required this.cseId})
      : super(ProductSearchInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<ApplyFilters>(_onApplyFilters);
    on<UpdateLoadedProducts>(_onUpdateLoadedProducts);
    on<ResetProductSearch>(_onReset);
    on<SearchSingleProduct>(_onSearchSingleProduct);
    on<UpdateProductFreezeStatus>(_onUpdateFreezeStatus);
    on<ProductsSilentlyUnfreezed>(_onProductsSilentlyUnfreezed);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductSearchState> emit) async {
    try {
      emit(ProductSearchLoading());
      final effectiveCseId = _effectiveCseId(event.cseId, event.filters);

      final response = await repository.searchProducts(
        cseId: effectiveCseId,
        filters: event.filters,
      );

      final allProducts = response.products;
      const int loadCount = 10; // your load_product_count constant
      final initial = allProducts.take(loadCount).toList();

      emit(ProductSearchLoaded(
        allProducts: allProducts,
        products: initial,
        appliedFilters: event.filters,
        maxSafeCount: response.maxSafeCount,
        totalFound: response.totalFound,
        loadCount: loadCount,
      ));
    } catch (e) {
      emit(ProductSearchError(ApiErrorHandler.message(e)));
    }
  }

  Future<void> _onApplyFilters(
      ApplyFilters event, Emitter<ProductSearchState> emit) async {
    emit(ProductSearchLoading());
    try {
      final String singleStockCode =
          (event.filters['__single_stock_code'] ?? '').toString().trim();
      final effectiveCseId = _effectiveCseId(event.cseId, event.filters);

      final response = singleStockCode.isNotEmpty
          ? await repository.searchSingleProduct(
              cseId: effectiveCseId,
              stockCode: singleStockCode,
            )
          : await repository.searchProducts(
              cseId: effectiveCseId,
              filters: event.filters,
            );

      int loadCount = response.loadCount;
      final allProducts = response.products;
      final initial = allProducts.take(loadCount).toList();

      emit(ProductSearchLoaded(
        allProducts: allProducts,
        products: initial,
        appliedFilters: event.filters,
        maxSafeCount: response.maxSafeCount,
        totalFound: response.totalFound,
        loadCount: loadCount,
      ));
    } catch (e) {
      emit(ProductSearchError(ApiErrorHandler.message(e)));
    }
  }

  Future<void> _onSearchSingleProduct(
      SearchSingleProduct event, Emitter<ProductSearchState> emit) async {
    emit(ProductSearchLoading());
    try {
      final stockCode = event.stockCode.trim();
      if (stockCode.isEmpty) {
        throw Exception('Please enter stock code');
      }

      final effectiveCseId = _effectiveCseId(event.cseId, null);
      if (effectiveCseId.isEmpty) {
        throw Exception('CSE id not found');
      }

      final response = await repository.searchSingleProduct(
        cseId: effectiveCseId,
        stockCode: stockCode,
      );

      final allProducts = response.products;
      final loadCount = response.loadCount;

      emit(ProductSearchLoaded(
        allProducts: allProducts,
        products: allProducts.take(loadCount).toList(),
        appliedFilters: {
          'cse_id': effectiveCseId,
          '__single_stock_code': stockCode,
        },
        maxSafeCount: response.maxSafeCount,
        totalFound: response.totalFound,
        loadCount: loadCount,
      ));
    } catch (e) {
      emit(ProductSearchError(ApiErrorHandler.message(e)));
    }
  }


  void _onUpdateFreezeStatus(UpdateProductFreezeStatus event, Emitter<ProductSearchState> emit) {
    final current = state;
    if (current is! ProductSearchLoaded) return;
    ProductModel update(ProductModel p) => p.stockCode == event.stockCode ? p.copyWith(freezedProduct: event.status) : p;
    emit(current.copyWith(
      allProducts: current.allProducts.map(update).toList(),
      products: current.products.map(update).toList(),
    ));
  }


  void _onProductsSilentlyUnfreezed(
    ProductsSilentlyUnfreezed event,
    Emitter<ProductSearchState> emit,
  ) {
    final current = state;
    if (current is! ProductSearchLoaded || event.stockCodes.isEmpty) return;

    const available = FreezedProductStatus();
    ProductModel update(ProductModel product) {
      return event.stockCodes.contains(product.stockCode.trim())
          ? product.copyWith(freezedProduct: available)
          : product;
    }

    emit(
      current.copyWith(
        allProducts: current.allProducts.map(update).toList(),
        products: current.products.map(update).toList(),
      ),
    );
  }

  void _onUpdateLoadedProducts(
      UpdateLoadedProducts event, Emitter<ProductSearchState> emit) {
    final current = state;
    if (current is ProductSearchLoaded) {
      emit(current.copyWith(products: event.newProducts));
    }
  }

  ///  Logout reset
  void _onReset(ResetProductSearch event, Emitter<ProductSearchState> emit) {
    emit(ProductSearchInitial());
  }
}
