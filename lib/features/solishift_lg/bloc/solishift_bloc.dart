import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:manubhaimlt/features/solishift_lg/bloc/solishift_event.dart';
import 'package:manubhaimlt/features/solishift_lg/bloc/solishift_state.dart';
import 'package:manubhaimlt/features/solishift_lg/data/repositories/solishift_repository.dart';

class SoliShiftLgBloc extends Bloc<SoliShiftLgEvent, SoliShiftLgState> {
  final SoliShiftLgRepository repository;

  SoliShiftLgBloc({required this.repository}) : super(const SoliShiftLgState()) {
    on<SoliShiftLgSearchRequested>(_onSearch);
    on<SoliShiftLgCustomizeClicked>(_onCustomizeClicked);
    on<SoliShiftLgModeChanged>(_onModeChanged);
    on<SoliShiftLgCaratUpdateRequested>(_onCaratUpdate);
    on<SoliShiftLgBudgetUpdateRequested>(_onBudgetUpdate);
    on<SoliShiftLgFilterChanged>(_onFilterChanged);
    on<SoliShiftLgFiltersReset>(_onFiltersReset);
  }

  Future<void> _onSearch(
    SoliShiftLgSearchRequested event,
    Emitter<SoliShiftLgState> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      pricingUpdating: false,
      clearError: true,
    ));

    try {
      final response = await repository.fetchRingData(
        cseId: event.cseId,
        stockCode: event.stockCode,
      );

      emit(state.copyWith(
        loading: false,
        pricingUpdating: false,
        data: response.data,
        caratData: response.data,
        clearBudgetData: true,
        showCustomize: false,
        mode: 'carat',
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

  Future<void> _onCaratUpdate(
    SoliShiftLgCaratUpdateRequested event,
    Emitter<SoliShiftLgState> emit,
  ) async {
    // Always use the original/last carat data as request source.
    // Budget responses must never become the source for carat calculations.
    final source = state.caratData ?? state.data;
    if (source == null) return;

    emit(state.copyWith(pricingUpdating: true, clearError: true));

    try {
      final response = await repository.updateByCarat(
        rawEntries: source.rawEntries,
        newSolitaireCt: event.newSolitaireCt,
        newDiamondCt: event.newDiamondCt,
      );

      final updatedCaratData = source.mergeUpdate(response.data);

      emit(state.copyWith(
        pricingUpdating: false,
        data: updatedCaratData,
        caratData: updatedCaratData,
        showCustomize: true,
        mode: 'carat',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        pricingUpdating: false,
        error: ApiErrorHandler.message(e),
      ));
    }
  }

  Future<void> _onBudgetUpdate(
    SoliShiftLgBudgetUpdateRequested event,
    Emitter<SoliShiftLgState> emit,
  ) async {
    // Budget requests must use the original carat/raw stock data.
    final source = state.caratData ?? state.data;
    if (source == null) return;

    emit(state.copyWith(pricingUpdating: true, clearError: true));

    try {
      final response = await repository.updateByBudget(
        rawEntries: source.rawEntries,
        budget: event.budget,
      );

      final updatedBudgetData = source.mergeUpdate(response.data);

      emit(state.copyWith(
        pricingUpdating: false,
        data: updatedBudgetData,
        budgetData: updatedBudgetData,
        showCustomize: true,
        mode: 'budget',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
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

  void _onModeChanged(
    SoliShiftLgModeChanged event,
    Emitter<SoliShiftLgState> emit,
  ) {
    final nextMode = event.mode == 'budget' ? 'budget' : 'carat';

    if (nextMode == 'carat') {
      emit(state.copyWith(
        mode: 'carat',
        data: state.caratData ?? state.data,
        // Keep the currently selected Shape, Colour and Clarity.
        clearError: true,
      ));
      return;
    }

    emit(state.copyWith(
      mode: 'budget',
      // Show last budget result if one exists. Otherwise keep current data
      // until Find Diamond is pressed.
      data: state.budgetData ?? state.data,
      // Keep the currently selected Shape, Colour and Clarity.
      clearError: true,
    ));
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
