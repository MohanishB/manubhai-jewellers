// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:manubhaimlt/features/solitaire/bloc/save_order_event.dart';
// import 'package:manubhaimlt/features/solitaire/bloc/save_order_state.dart';
// import 'package:manubhaimlt/features/solitaire/data/repositories/save_order_repository.dart';

// class SaveOrderBloc extends Bloc<SaveOrderEvent, SaveOrderState> {
//   final SaveOrderRepository repo;

//   SaveOrderBloc({required this.repo}) : super(const SaveOrderInitial()) {
//     on<SubmitSaveOrder>(_onSubmit);
//     on<ClearSaveOrder>((_, emit) => emit(const SaveOrderInitial()));
//   }

//   Future<void> _onSubmit(
//     SubmitSaveOrder e,
//     Emitter<SaveOrderState> emit,
//   ) async {
//     emit(const SaveOrderLoading());
//     try {
//       final res = await repo.saveOrder(
//         cseId: e.cseId,
//         stockCode: e.stockCode,
//         diamondId: e.diamondId,
//         customerName: e.customerName,
//         customerPhone: e.customerPhone,
//         customerEmail: e.customerEmail,
//         originalProduct: e.originalProduct,
//         priceCalculation: e.priceCalculation,
//       );

//       emit(SaveOrderSuccess(res));
//     } catch (ex) {
//       emit(SaveOrderError(ApiErrorHandler.message(ex)));
//     }
//   }
// }

//================================//
//================================//
//================================//

import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/save_order_event.dart';
import 'package:manubhaimlt/features/solitaire/bloc/save_order_state.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/save_order_repository.dart';

class SaveOrderBloc extends Bloc<SaveOrderEvent, SaveOrderState> {
  final SaveOrderRepository repo;

  SaveOrderBloc({required this.repo}) : super(const SaveOrderInitial()) {
    on<SubmitSaveOrder>(_onSubmit);
    on<ClearSaveOrder>((_, emit) => emit(const SaveOrderInitial()));
  }

  Future<void> _onSubmit(
    SubmitSaveOrder e,
    Emitter<SaveOrderState> emit,
  ) async {
    emit(const SaveOrderLoading());
    try {
      final res = await repo.saveOrder(
        cseId: e.cseId,
        stockCode: e.stockCode,
        diamondId: e.diamondId,
        customerName: e.customerName,
        customerPhone: e.customerPhone,
        customerEmail: e.customerEmail,
        selectedKarat: e.selectedKarat,
        originalProduct: e.originalProduct,
        priceCalculation: e.priceCalculation,
      );

      emit(SaveOrderSuccess(res));
    } catch (ex) {
      emit(SaveOrderError(ApiErrorHandler.message(ex)));
    }
  }
}