import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/solishift_lg/data/models/solishift_stock_model.dart';

class SoliShiftLgState extends Equatable {
  final bool loading;
  final bool pricingUpdating;
  final String? error;
  final SoliShiftLgData? data;
  final bool showCustomize;
  final String shape;
  final String colour;
  final String clarity;

  const SoliShiftLgState({
    this.loading = false,
    this.pricingUpdating = false,
    this.error,
    this.data,
    this.showCustomize = false,
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
    bool? showCustomize,
    String? shape,
    String? colour,
    String? clarity,
  }) {
    return SoliShiftLgState(
      loading: loading ?? this.loading,
      pricingUpdating: pricingUpdating ?? this.pricingUpdating,
      error: clearError ? null : error ?? this.error,
      data: data ?? this.data,
      showCustomize: showCustomize ?? this.showCustomize,
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
        showCustomize,
        shape,
        colour,
        clarity,
      ];
}
