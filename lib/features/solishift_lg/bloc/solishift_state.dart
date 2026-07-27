import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/solishift_lg/data/models/solishift_stock_model.dart';

class SoliShiftLgState extends Equatable {
  final bool loading;
  final bool pricingUpdating;
  final String? error;

  /// Data currently displayed on screen.
  final SoliShiftLgData? data;

  /// Last successful carat-based result.
  final SoliShiftLgData? caratData;

  /// Last successful budget-based result.
  final SoliShiftLgData? budgetData;

  final bool showCustomize;
  final String mode;
  final String shape;
  final String colour;
  final String clarity;

  const SoliShiftLgState({
    this.loading = false,
    this.pricingUpdating = false,
    this.error,
    this.data,
    this.caratData,
    this.budgetData,
    this.showCustomize = false,
    this.mode = 'carat',
    this.shape = 'All',
    this.colour = 'All',
    this.clarity = 'All',
  });

  SoliShiftLgState copyWith({
    bool? loading,
    bool? pricingUpdating,
    String? error,
    bool clearError = false,
    SoliShiftLgData? data,
    SoliShiftLgData? caratData,
    SoliShiftLgData? budgetData,
    bool clearBudgetData = false,
    bool? showCustomize,
    String? mode,
    String? shape,
    String? colour,
    String? clarity,
  }) {
    return SoliShiftLgState(
      loading: loading ?? this.loading,
      pricingUpdating: pricingUpdating ?? this.pricingUpdating,
      error: clearError ? null : error ?? this.error,
      data: data ?? this.data,
      caratData: caratData ?? this.caratData,
      budgetData: clearBudgetData ? null : budgetData ?? this.budgetData,
      showCustomize: showCustomize ?? this.showCustomize,
      mode: mode ?? this.mode,
      shape: shape ?? this.shape,
      colour: colour ?? this.colour,
      clarity: clarity ?? this.clarity,
    );
  }

  List<PricingTable> get filteredTables {
    final tables = data?.pricingTables ?? const <PricingTable>[];

    return tables.where((table) {
      final shapeOk = shape == 'All' || table.shape == shape;
      final colourOk = colour == 'All' || table.colour == colour;
      final clarityOk = clarity == 'All' || table.clarity == clarity;

      return table.visible && shapeOk && colourOk && clarityOk;
    }).toList();
  }

  @override
  List<Object?> get props => [
        loading,
        pricingUpdating,
        error,
        data,
        caratData,
        budgetData,
        showCustomize,
        mode,
        shape,
        colour,
        clarity,
      ];
}
