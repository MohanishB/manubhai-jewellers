import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/similar_products_repository.dart';
import 'similar_products_event.dart';
import 'similar_products_state.dart';

class SimilarProductsBloc
    extends Bloc<SimilarProductsEvent, SimilarProductsState> {
  final SimilarProductsRepository repository;

  SimilarProductsBloc({required this.repository})
      : super(SimilarProductsInitial()) {
    on<LoadSimilarProducts>(_onLoadSimilarProducts);
    on<UpdateLoadedSimilarProducts>(_onUpdateLoadedProducts);
    on<ResetSimilarProducts>(_onReset);
  }

  Future<void> _onLoadSimilarProducts(
    LoadSimilarProducts event,
    Emitter<SimilarProductsState> emit,
  ) async {
    emit(SimilarProductsLoading());

    try {
      final response = await repository.searchSimilarProducts(
        cseId: event.cseId,
        stockCode: event.stockCode,
        filters: event.filters,
      );

      final allProducts = response.products;
      final loadCount = response.loadCount > 0 ? response.loadCount : 10;
      final initial = allProducts.take(loadCount).toList();

      emit(
        SimilarProductsLoaded(
          allProducts: allProducts,
          products: initial,
          stockCode: event.stockCode,
          appliedFilters: event.filters,
          maxSafeCount: response.maxSafeCount,
          totalFound: response.totalFound,
          loadCount: loadCount,
        ),
      );
    } catch (e) {
      emit(SimilarProductsError(ApiErrorHandler.message(e)));
    }
  }

  void _onUpdateLoadedProducts(
    UpdateLoadedSimilarProducts event,
    Emitter<SimilarProductsState> emit,
  ) {
    final current = state;
    if (current is SimilarProductsLoaded) {
      emit(current.copyWith(products: event.newProducts));
    }
  }

  void _onReset(
    ResetSimilarProducts event,
    Emitter<SimilarProductsState> emit,
  ) {
    emit(SimilarProductsInitial());
  }
}
