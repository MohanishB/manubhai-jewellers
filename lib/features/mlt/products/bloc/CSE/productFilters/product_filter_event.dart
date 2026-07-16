// import 'package:equatable/equatable.dart';

// abstract class ProductFilterEvent extends Equatable {
//   const ProductFilterEvent();

//   @override
//   List<Object?> get props => [];
// }

// class FetchProductFilters extends ProductFilterEvent {
//   final String cseId;

//   const FetchProductFilters(this.cseId);

//   @override
//   List<Object?> get props => [cseId];
// }

// /// ✅ Persist user's filter selections
// class UpdateSelectedFilter extends ProductFilterEvent {
//   final String label;
//   final dynamic value;

//   const UpdateSelectedFilter(this.label, this.value);

//   @override
//   List<Object?> get props => [label, value];
// }

// /// ✅ replace full selectedFilters map
// class SetSelectedFilters extends ProductFilterEvent {
//   final Map<String, dynamic> selected;
//   const SetSelectedFilters(this.selected);

//   @override
//   List<Object?> get props => [selected];
// }

// class ResetProductFilters extends ProductFilterEvent {
//   const ResetProductFilters();
// }

//===========================================//
import 'package:equatable/equatable.dart';

abstract class ProductFilterEvent extends Equatable {
  const ProductFilterEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductFilters extends ProductFilterEvent {
  final String cseId;

  const FetchProductFilters(this.cseId);

  @override
  List<Object?> get props => [cseId];
}

class FetchProductSubFilters extends ProductFilterEvent {
  final String cseId;
  final String lob;
  final String category;

  const FetchProductSubFilters({
    required this.cseId,
    required this.lob,
    required this.category,
  });

  @override
  List<Object?> get props => [cseId, lob, category];
}

class UpdateSelectedFilter extends ProductFilterEvent {
  final String label;
  final dynamic value;

  const UpdateSelectedFilter(this.label, this.value);

  @override
  List<Object?> get props => [label, value];
}

class SetSelectedFilters extends ProductFilterEvent {
  final Map<String, dynamic> selected;

  const SetSelectedFilters(this.selected);

  @override
  List<Object?> get props => [selected];
}

class ResetProductFilters extends ProductFilterEvent {
  const ResetProductFilters();
}
