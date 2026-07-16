import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_event.dart';
import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_state.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_confirm_order_repository.dart';

class ConfirmOrderBloc extends Bloc<SubmitConfirmOrder, ConfirmOrderState> {
  final SolitaireConfirmOrderRepository repo;

  ConfirmOrderBloc({required this.repo}) : super(const ConfirmOrderInitial()) {
    on<SubmitConfirmOrder>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitConfirmOrder e,
    Emitter<ConfirmOrderState> emit,
  ) async {
    emit(const ConfirmOrderLoading());
    try {
      final resp = await repo.confirmOrder(
        cseId: e.cseId,
        stockCode: e.stockCode,
        diamondId: e.diamondId,
        customerName: e.customerName,
        customerPhone: e.customerPhone,
        customerEmail: e.customerEmail,
        originalProduct: e.originalProduct,
        priceCalculation: e.priceCalculation,
      );
      emit(ConfirmOrderSuccess(resp));
    } catch (ex) {
      emit(ConfirmOrderError(ApiErrorHandler.message(ex)));
    }
  }
}
