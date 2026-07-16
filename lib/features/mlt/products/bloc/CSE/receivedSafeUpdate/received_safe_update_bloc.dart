import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'received_safe_update_event.dart';
import 'received_safe_update_state.dart';
import '../../../repositories/CSE_repo/received_safe_update_repository.dart';

class ReceivedSafeUpdateBloc
    extends Bloc<ReceivedSafeUpdateEvent, ReceivedSafeUpdateState> {
  final ReceivedSafeUpdateRepository repository;

  ReceivedSafeUpdateBloc(this.repository)
      : super(ReceivedSafeUpdateInitial()) {
    on<UpdateReceivedSafeStatus>(_onUpdateStatus);
  }

  Future<void> _onUpdateStatus(UpdateReceivedSafeStatus event,
      Emitter<ReceivedSafeUpdateState> emit) async {
    emit(ReceivedSafeUpdateLoading());
    try {
      final response = await repository.updateStatus(
        cseId: event.cseId,
        safeRequestId: event.safeRequestId,
        stockList: event.stockList,
        status: event.status,
      );

      if (response.errorCode == 0 && response.successCode == 1) {
        emit(ReceivedSafeUpdateSuccess(response));
      } else {
        emit(ReceivedSafeUpdateError(response.errorMsg));
      }
    } catch (e) {
      emit(ReceivedSafeUpdateError(ApiErrorHandler.message(e)));
    }
  }
}
