import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/cse_requested_stock_list_repository.dart';
import 'cse_requested_stock_list_event.dart';
import 'cse_requested_stock_list_state.dart';

class CseRequestedStockListBloc
    extends Bloc<CseRequestedStockListEvent, CseRequestedStockListState> {
  final CseRequestedStockListRepository repo;

  CseRequestedStockListBloc(this.repo)
      : super(const CseRequestedStockListInitial()) {
    on<FetchCseRequestedStockList>(_onFetch);
    on<ResetCseRequestedStockList>(_onReset);
  }

  Future<void> _onFetch(
    FetchCseRequestedStockList event,
    Emitter<CseRequestedStockListState> emit,
  ) async {
    emit(const CseRequestedStockListLoading());
    try {
      final res = await repo.fetchRequestedStockList(cseId: event.cseId);
      emit(CseRequestedStockListLoaded(
        totalProduct: res.totalProduct,
        groups: res.productList,
      ));
    } catch (e) {
      emit(CseRequestedStockListError(ApiErrorHandler.message(e)));
    }
  }

  void _onReset(
    ResetCseRequestedStockList event,
    Emitter<CseRequestedStockListState> emit,
  ) {
    emit(const CseRequestedStockListInitial());
  }
}
