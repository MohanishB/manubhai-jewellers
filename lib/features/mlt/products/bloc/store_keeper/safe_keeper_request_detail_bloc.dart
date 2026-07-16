import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_state.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/safe_keeper_request_detail_repository.dart';
 

class SafeKeeperRequestDetailBloc
    extends Bloc<SafeKeeperRequestDetailEvent, SafeKeeperRequestDetailState> {
  final SafeKeeperRequestDetailRepository repository;

  SafeKeeperRequestDetailBloc({required this.repository})
      : super(const SafeKeeperRequestDetailInitial()) {
    on<FetchSafeKeeperRequestDetail>(_onFetch);
  }

  Future<void> _onFetch(
    FetchSafeKeeperRequestDetail event,
    Emitter<SafeKeeperRequestDetailState> emit,
  ) async {
    emit(const SafeKeeperRequestDetailLoading());
    try {
      final resp = await repository.fetchDetail(
        cseId: event.cseId,
        safeRequestId: event.safeRequestId,
      );

      // if (resp.productList.isEmpty) {
      //   emit(const SafeKeeperRequestDetailError('No details found.'));
      //   return;
      // }

      if (resp.productList.isEmpty) {
        emit(const SafeKeeperRequestDetailCompleted(
          message: 'Request updated successfully. No pending items remain.',
        ));
        return;
      }


      emit(SafeKeeperRequestDetailLoaded(request: resp.productList.first));
    } catch (e) {
      emit(SafeKeeperRequestDetailError(ApiErrorHandler.message(e)));
    }
  }
}
