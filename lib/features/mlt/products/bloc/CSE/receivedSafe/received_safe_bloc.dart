import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/received_safe_repository.dart';
import 'received_safe_event.dart';
import 'received_safe_state.dart';


class ReceivedSafeBloc extends Bloc<ReceivedSafeEvent, ReceivedSafeState> {
  final ReceivedSafeRepository repository;

  ReceivedSafeBloc(this.repository) : super(ReceivedSafeInitial()) {
    on<FetchReceivedSafeList>(_onFetchReceivedSafeList);
  }

  Future<void> _onFetchReceivedSafeList(
    FetchReceivedSafeList event,
    Emitter<ReceivedSafeState> emit,
  ) async {
    emit(ReceivedSafeLoading());
    try {
      final data = await repository.fetchReceivedSafeList(event.cseId);
      if (data.errorCode == 0 && data.successCode == 1) {
        emit(ReceivedSafeLoaded(data));
      } else {
        emit(ReceivedSafeError(data.errorMsg.isNotEmpty
            ? data.errorMsg
            : 'Failed to load received safe list'));
      }
    } catch (e) {
      emit(ReceivedSafeError(ApiErrorHandler.message(e)));
    }
  }
}
