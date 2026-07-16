import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/safe_keeper_repository.dart';
import 'safe_keeper_event.dart';
import 'safe_keeper_state.dart';


class SafeKeeperBloc extends Bloc<SafeKeeperEvent, SafeKeeperState> {
  final SafeKeeperRepository repository;

  SafeKeeperBloc({required this.repository}) : super(SafeKeeperInitial()) {
    on<FetchSafeKeeperRequests>(_onFetchRequests);
  }

  Future<void> _onFetchRequests(
      FetchSafeKeeperRequests event, Emitter<SafeKeeperState> emit) async {
    emit(SafeKeeperLoading());
    try {
      final requests = await repository.fetchSafeKeeperRequests(event.cseId);
      emit(SafeKeeperLoaded(requests));
    } catch (e) {
      emit(SafeKeeperError(ApiErrorHandler.message(e)));
    }
  }
}
