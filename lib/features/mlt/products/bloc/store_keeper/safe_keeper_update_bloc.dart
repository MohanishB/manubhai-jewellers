import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/safe_keeper_repository.dart';


part 'safe_keeper_update_event.dart';
part 'safe_keeper_update_state.dart';

class SafeKeeperUpdateBloc extends Bloc<SafeKeeperUpdateEvent, SafeKeeperUpdateState> {
  final SafeKeeperRepository repository;

  SafeKeeperUpdateBloc(this.repository) : super(SafeKeeperUpdateInitial()) {
    on<UpdateSafeKeeperStatus>(_onUpdateStatus);
  }

  Future<void> _onUpdateStatus(
    UpdateSafeKeeperStatus event,
    Emitter<SafeKeeperUpdateState> emit,
  ) async {
    emit(SafeKeeperUpdateLoading());
    try {
      final response = await repository.updateRequestStatus(
        cseId: event.cseId,
        safeRequestId: event.safeRequestId,
        stockList: event.stockList,
        status: event.status,
      );

      if (response.successCode == 1) {
        emit(SafeKeeperUpdateSuccess());
      } else {
        emit(SafeKeeperUpdateError(response.errorMsg.isEmpty
            ? "Failed to update request status."
            : response.errorMsg));
      }
    } catch (e) {
      emit(SafeKeeperUpdateError(ApiErrorHandler.message(e)));
    }
  }
}
