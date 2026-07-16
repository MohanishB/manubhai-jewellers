import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'saved_orders_event.dart';
import 'saved_orders_state.dart';
import '../data/repositories/saved_orders_repository.dart';

class SavedOrdersBloc extends Bloc<SavedOrdersEvent, SavedOrdersState> {
  final SavedOrdersRepository repo;

  SavedOrdersBloc(this.repo) : super(const SavedOrdersInitial()) {
    on<FetchSavedOrders>(_onFetch);
  }

  Future<void> _onFetch(
    FetchSavedOrders e,
    Emitter<SavedOrdersState> emit,
  ) async {
    emit(const SavedOrdersLoading());
    try {
      final res = await repo.fetchSavedOrders(
        cseId: e.cseId,
        fromDate: e.fromDate,
        toDate: e.toDate,
        customerName: e.customerName,
        customerPhone: e.customerPhone,
      );

      emit(SavedOrdersLoaded(
        orders: res.orders,
        totalCount: res.totalCount,
      ));
    } catch (ex) {
      emit(SavedOrdersError(ApiErrorHandler.message(ex)));
    }
  }
}