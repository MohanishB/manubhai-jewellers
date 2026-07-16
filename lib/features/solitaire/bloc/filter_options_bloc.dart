import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_filter_options_repository.dart';

import 'filter_options_event.dart';
import 'filter_options_state.dart';

class FilterOptionsBloc extends Bloc<FilterOptionsEvent, FilterOptionsState> {
  final SolitaireFilterOptionsRepository repo;

  FilterOptionsBloc({required this.repo}) : super(FilterOptionsInitial()) {
    on<FetchFilterOptions>(_onFetch);
    on<FetchFilterShapes>(_onFetchShapes);
    on<FetchFilterOptionsByShape>(_onFetchByShape);
  }


  Future<void> _onFetchShapes(
    FetchFilterShapes event,
    Emitter<FilterOptionsState> emit,
  ) async {
    emit(FilterOptionsLoading());
    try {
      final res = await repo.fetchFilterShapes(
        cseId: event.cseId,
        stockCode: event.stockCode,
      );
      emit(FilterShapesLoaded(res.shapes));
    } catch (e) {
      emit(FilterOptionsError(ApiErrorHandler.message(e)));
    }
  }

  Future<void> _onFetchByShape(
    FetchFilterOptionsByShape event,
    Emitter<FilterOptionsState> emit,
  ) async {
    emit(FilterOptionsLoading());
    try {
      final res = await repo.fetchFilterOptionsByShape(
        cseId: event.cseId,
        stockCode: event.stockCode,
        shape: event.shape,
      );
      emit(FilterOptionsLoaded(res.filterOptions));
    } catch (e) {
      emit(FilterOptionsError(ApiErrorHandler.message(e)));
    }
  }

  Future<void> _onFetch(
    FetchFilterOptions event,
    Emitter<FilterOptionsState> emit,
  ) async {
    emit(FilterOptionsLoading());
    try {
      final res = await repo.fetchFilterOptions(
        cseId: event.cseId,
        stockCode: event.stockCode,
      );
      emit(FilterOptionsLoaded(res.filterOptions));
    } catch (e) {
      emit(FilterOptionsError(ApiErrorHandler.message(e)));
    }
  }
}
