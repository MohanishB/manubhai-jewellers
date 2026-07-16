// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_step3_order_summary_repository.dart';
// import 'step3_order_summary_event.dart';
// import 'step3_order_summary_state.dart';

// class Step3OrderSummaryBloc extends Bloc<dynamic, Step3OrderSummaryState> {
//   final SolitaireStep3OrderSummaryRepository repo;

//   Step3OrderSummaryBloc({required this.repo})
//       : super(const Step3OrderSummaryInitial()) {
//     on<FetchStep3OrderSummary>(_onFetch);
//     on<ClearStep3OrderSummary>(_onClear);
//   }

//   Future<void> _onFetch(
//     FetchStep3OrderSummary e,
//     Emitter<Step3OrderSummaryState> emit,
//   ) async {
//     emit(const Step3OrderSummaryLoading());

//     try {
//       final resp = await repo.fetchOrderSummary(
//         cseId: e.cseId,
//         stockCode: e.stockCode,
//         diamondId: e.diamondId,
//         customerName: e.customerName,
//         customerPhone: e.customerPhone,
//         customerEmail: e.customerEmail,
//       );

//       final summary = resp.orderSummary;
//       if (summary == null) {
//         emit(const Step3OrderSummaryError('No order summary returned'));
//         return;
//       }

//       emit(Step3OrderSummaryLoaded(summary));
//     } catch (ex) {
//       emit(Step3OrderSummaryError(ApiErrorHandler.message(ex)));
//     }
//   }

//   void _onClear(
//     ClearStep3OrderSummary e,
//     Emitter<Step3OrderSummaryState> emit,
//   ) {
//     emit(const Step3OrderSummaryInitial());
//   }
// }

//============================================//
//============================================//
//============================================//

import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_step3_order_summary_repository.dart';
import 'step3_order_summary_event.dart';
import 'step3_order_summary_state.dart';

class Step3OrderSummaryBloc extends Bloc<dynamic, Step3OrderSummaryState> {
  final SolitaireStep3OrderSummaryRepository repo;

  Step3OrderSummaryBloc({required this.repo})
      : super(const Step3OrderSummaryInitial()) {
    on<FetchStep3OrderSummary>(_onFetch);
    on<FetchStep3OrderSummaryByOrderId>(_onFetchByOrderId);  
    on<ClearStep3OrderSummary>(_onClear);
  }

  Future<void> _onFetch(
    FetchStep3OrderSummary e,
    Emitter<Step3OrderSummaryState> emit,
  ) async {
    emit(const Step3OrderSummaryLoading());

    try {
      final resp = await repo.fetchOrderSummary(
        cseId: e.cseId,
        stockCode: e.stockCode,
        diamondId: e.diamondId,
        customerName: e.customerName,
        customerPhone: e.customerPhone,
        customerEmail: e.customerEmail,
      );

      final summary = resp.orderSummary;
      if (summary == null) {
        emit(const Step3OrderSummaryError('No order summary returned'));
        return;
      }

      emit(Step3OrderSummaryLoaded(summary));
    } catch (ex) {
      emit(Step3OrderSummaryError(ApiErrorHandler.message(ex)));
    }
  }

  /// ✅ NEW: by order_id
  Future<void> _onFetchByOrderId(
    FetchStep3OrderSummaryByOrderId e,
    Emitter<Step3OrderSummaryState> emit,
  ) async {
    emit(const Step3OrderSummaryLoading());

    try {
      final resp = await repo.fetchOrderSummaryByOrderId(
        cseId: e.cseId,
        orderId: e.orderId,
      );

      final summary = resp.orderSummary;
      if (summary == null) {
        emit(const Step3OrderSummaryError('No order summary returned'));
        return;
      }

      emit(Step3OrderSummaryLoaded(summary));
    } catch (ex) {
      emit(Step3OrderSummaryError(ApiErrorHandler.message(ex)));
    }
  }

  void _onClear(
    ClearStep3OrderSummary e,
    Emitter<Step3OrderSummaryState> emit,
  ) {
    emit(const Step3OrderSummaryInitial());
  }
}

