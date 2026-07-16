// // lib/features/solitaire/bloc/filter_diamonds_bloc.dart
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_filter_diamonds_repository.dart';

// import 'filter_diamonds_event.dart';
// import 'filter_diamonds_state.dart';

// class FilterDiamondsBloc extends Bloc<dynamic, FilterDiamondsState> {
//   final SolitaireFilterDiamondsRepository repo;

//   FilterDiamondsBloc({required this.repo}) : super(const FilterDiamondsInitial()) {
//     on<FetchFilterDiamonds>(_onFetch);
//     on<ClearFilterDiamonds>(_onClear);
//   }

//   Future<void> _onFetch(
//     FetchFilterDiamonds e,
//     Emitter<FilterDiamondsState> emit,
//   ) async {
//     emit(const FilterDiamondsLoading());

//     try {
//       String? csv(List<String> v) => v.isEmpty ? null : v.join(',');

//       final resp = await repo.fetchDiamonds(
//         cseId: e.cseId,
//         stockCode: e.stockCode,
//         priceMin: e.priceMin,
//         priceMax: e.priceMax,
//         caratMin: e.caratMin,
//         caratMax: e.caratMax,
//         colorCsv: csv(e.colors),
//         clarityCsv: csv(e.clarities),
//         cutCsv: csv(e.cuts),
//         certCsv: csv(e.certificates),
//       );

//       emit(FilterDiamondsLoaded(
//         diamonds: resp.diamonds,
//         totalCount: resp.totalCount,
//       ));
//     } catch (ex) {
//       emit(FilterDiamondsError(ApiErrorHandler.message(ex)));
//     }
//   }

//   void _onClear(
//     ClearFilterDiamonds e,
//     Emitter<FilterDiamondsState> emit,
//   ) {
//     emit(const FilterDiamondsInitial());
//   }
// }

//========================================//
//========================================//
//========================================//

// lib/features/solitaire/bloc/filter_diamonds_bloc.dart
import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_filter_diamonds_repository.dart';

import 'filter_diamonds_event.dart';
import 'filter_diamonds_state.dart';

class FilterDiamondsBloc extends Bloc<dynamic, FilterDiamondsState> {
  final SolitaireFilterDiamondsRepository repo;

  FilterDiamondsBloc({required this.repo})
      : super(const FilterDiamondsInitial()) {
    on<FetchFilterDiamonds>(_onFetch);
    on<ClearFilterDiamonds>(_onClear);
  }

  Future<void> _onFetch(
    FetchFilterDiamonds e,
    Emitter<FilterDiamondsState> emit,
  ) async {
    emit(const FilterDiamondsLoading());

    try {
      String? csv(List<String> v) => v.isEmpty ? null : v.join(',');

      final resp = await repo.fetchDiamonds(
        cseId: e.cseId,
        stockCode: e.stockCode,
        shape: e.shape,

        priceMin: e.priceMin,
        priceMax: e.priceMax,
        caratMin: e.caratMin,
        caratMax: e.caratMax,
        colorCsv: csv(e.colors),
        clarityCsv: csv(e.clarities),
        cutCsv: csv(e.cuts),
        certCsv: csv(e.certificates),

        // ✅ sort forward
        sortBy: e.sortBy,
        sortOrder: e.sortOrder,

        // ✅ optional search forward
        lotNumber: e.lotNumber,
        certNumber: e.certNumber,
        searchCaratMin: e.searchCaratMin,
        searchCaratMax: e.searchCaratMax,
        searchPriceMin: e.searchPriceMin,
        searchPriceMax: e.searchPriceMax,
      );

      emit(FilterDiamondsLoaded(
        diamonds: resp.diamonds,
        totalCount: resp.totalCount,
      ));
    } catch (ex) {
      emit(FilterDiamondsError(ApiErrorHandler.message(ex)));
    }
  }

  void _onClear(
    ClearFilterDiamonds e,
    Emitter<FilterDiamondsState> emit,
  ) {
    emit(const FilterDiamondsInitial());
  }
}
