import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/solishift_lg/bloc/solishift_event.dart';
import 'package:manubhaimlt/features/solishift_lg/bloc/solishift_state.dart';
import 'package:manubhaimlt/features/solishift_lg/data/repositories/solishift_repository.dart';


class SoliShiftLgBloc extends Bloc<SoliShiftLgEvent, SoliShiftLgState> {
  final SoliShiftLgRepository repository;

  SoliShiftLgBloc({required this.repository}) : super(const SoliShiftLgState()) {
    on<SoliShiftLgSearchRequested>(_onSearch);
    on<SoliShiftLgCustomizeClicked>(_onCustomizeClicked);
    on<SoliShiftLgFilterChanged>(_onFilterChanged);
    on<SoliShiftLgFiltersReset>(_onFiltersReset);
  }

  Future<void> _onSearch(
    SoliShiftLgSearchRequested event,
    Emitter<SoliShiftLgState> emit,
  ) async {
    final isUpdatePricing = state.data != null && event.newSolitaireCt.trim().isNotEmpty;

    emit(state.copyWith(
      loading: !isUpdatePricing,
      pricingUpdating: isUpdatePricing,
      clearError: true,
    ));

    try {
      final response = await repository.fetchRingData(
        cseId: event.cseId,
        stockCode: event.stockCode,
        newSolitaireCt: event.newSolitaireCt,
      );

      emit(state.copyWith(
        loading: false,
        pricingUpdating: false,
        data: response.data,
        showCustomize: isUpdatePricing ? state.showCustomize : false,
        shape: 'All',
        colour: 'All',
        clarity: 'All',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        pricingUpdating: false,
        error: ApiErrorHandler.message(e),
      ));
    }
  }

  void _onCustomizeClicked(
    SoliShiftLgCustomizeClicked event,
    Emitter<SoliShiftLgState> emit,
  ) {
    emit(state.copyWith(showCustomize: true));
  }

  void _onFilterChanged(
    SoliShiftLgFilterChanged event,
    Emitter<SoliShiftLgState> emit,
  ) {
    emit(state.copyWith(
      shape: event.shape,
      colour: event.colour,
      clarity: event.clarity,
    ));
  }

  void _onFiltersReset(
    SoliShiftLgFiltersReset event,
    Emitter<SoliShiftLgState> emit,
  ) {
    emit(state.copyWith(shape: 'All', colour: 'All', clarity: 'All'));
  }
}
