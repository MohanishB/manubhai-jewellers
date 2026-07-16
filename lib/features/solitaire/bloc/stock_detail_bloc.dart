import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/stock_repository.dart';
import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  final StockRepository repository;

  StockDetailBloc(this.repository) : super(StockInitial()) {
    on<FetchStockDetailEvent>(_onFetchStockDetail);
  }

  Future<void> _onFetchStockDetail(
      FetchStockDetailEvent event, Emitter<StockDetailState> emit) async {
    emit(StockLoading());
    try {
      final stock = await repository.fetchStockDetail(
        cseId: '1',
        stockCode: event.stockCode,
      );
      emit(StockLoaded(stock));
    } catch (e) {
      emit(StockError(ApiErrorHandler.message(e)));
    }
  }
}
