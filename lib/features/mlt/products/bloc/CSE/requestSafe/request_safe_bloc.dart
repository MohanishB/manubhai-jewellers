import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'request_safe_event.dart';
import 'request_safe_state.dart';
import '../../../repositories/CSE_repo/request_safe_repository.dart';

class RequestSafeBloc extends Bloc<RequestSafeEvent, RequestSafeState> {
  final RequestSafeRepository repository;

  RequestSafeBloc({required this.repository}) : super(RequestSafeInitial()) {
    on<SubmitRequestSafe>(_onSubmitRequestSafe);
  }

  Future<void> _onSubmitRequestSafe(
    SubmitRequestSafe event,
    Emitter<RequestSafeState> emit,
  ) async {
    emit(RequestSafeLoading());
    try {
      final response = await repository.requestSafe(
        cseId: event.cseId,
        stockList: event.stockList,
      );

      if (response.isSuccess) {
        emit(RequestSafeSuccess(response));
      } else {
        emit(RequestSafeError(response.errorMsg.isNotEmpty
            ? response.errorMsg
            : 'Unknown error occurred.'));
      }
    } catch (e) {
      emit(RequestSafeError(ApiErrorHandler.message(e)));
    }
  }
}
