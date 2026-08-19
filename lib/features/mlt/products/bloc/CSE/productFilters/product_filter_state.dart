// import 'package:equatable/equatable.dart';
// import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_model.dart';
// import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_sort_by_model.dart';

// abstract class ProductFilterState extends Equatable {
//   const ProductFilterState();
//   @override
//   List<Object?> get props => [];
// }

// class ProductFilterInitial extends ProductFilterState {}

// class ProductFilterLoading extends ProductFilterState {}

// class ProductFilterLoaded extends ProductFilterState {
//   final List<ProductFilterModel> filters;

//   /// ✅ NEW: sort options from API
//   final List<ProductSortByModel> sortBy;

//   /// ✅ User selections map (labelDisplay -> value)
//   final Map<String, dynamic> selectedFilters;

//   const ProductFilterLoaded(
//     this.filters, {
//     this.sortBy = const [],
//     this.selectedFilters = const {},
//   });

//   ProductFilterLoaded copyWith({
//     List<ProductFilterModel>? filters,
//     List<ProductSortByModel>? sortBy,
//     Map<String, dynamic>? selectedFilters,
//   }) {
//     return ProductFilterLoaded(
//       filters ?? this.filters,
//       sortBy: sortBy ?? this.sortBy,
//       selectedFilters: selectedFilters ?? this.selectedFilters,
//     );
//   }

//   @override
//   List<Object?> get props => [filters, sortBy, selectedFilters];
// }

// class ProductFilterError extends ProductFilterState {
//   final String message;
//   const ProductFilterError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

//==========================================//

import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_model.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_sort_by_model.dart';

abstract class ProductFilterState extends Equatable {
  const ProductFilterState();

  @override
  List<Object?> get props => [];
}

class ProductFilterInitial extends ProductFilterState {}

class ProductFilterLoading extends ProductFilterState {}

class ProductFilterLoaded extends ProductFilterState {
  final List<ProductFilterModel> filters;
  final List<ProductFilterModel> mainFilters;
  final List<ProductSortByModel> sortBy;
  final Map<String, dynamic> selectedFilters;
  final String cseId;
  final String cseMltBranch;
  final List<String> cseMltLocation;

  final bool subFiltersLoading;
  final bool subFiltersLoaded;
  final String? subFilterError;

  const ProductFilterLoaded(
    this.filters, {
    this.mainFilters = const [],
    this.sortBy = const [],
    this.selectedFilters = const {},
    this.cseId = '',
    this.cseMltBranch = '',
    this.cseMltLocation = const [],
    this.subFiltersLoading = false,
    this.subFiltersLoaded = false,
    this.subFilterError,
  });

  ProductFilterLoaded copyWith({
    List<ProductFilterModel>? filters,
    List<ProductFilterModel>? mainFilters,
    List<ProductSortByModel>? sortBy,
    Map<String, dynamic>? selectedFilters,
    String? cseId,
    String? cseMltBranch,
    List<String>? cseMltLocation,
    bool? subFiltersLoading,
    bool? subFiltersLoaded,
    String? subFilterError,
  }) {
    return ProductFilterLoaded(
      filters ?? this.filters,
      mainFilters: mainFilters ?? this.mainFilters,
      sortBy: sortBy ?? this.sortBy,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      cseId: cseId ?? this.cseId,
      cseMltBranch: cseMltBranch ?? this.cseMltBranch,
      cseMltLocation: cseMltLocation ?? this.cseMltLocation,
      subFiltersLoading: subFiltersLoading ?? this.subFiltersLoading,
      subFiltersLoaded: subFiltersLoaded ?? this.subFiltersLoaded,
      subFilterError: subFilterError,
    );
  }

  @override
  List<Object?> get props => [
        filters,
        mainFilters,
        sortBy,
        selectedFilters,
        cseId,
        cseMltBranch,
        cseMltLocation,
        subFiltersLoading,
        subFiltersLoaded,
        subFilterError,
      ];
}

class ProductFilterError extends ProductFilterState {
  final String message;

  const ProductFilterError(this.message);

  @override
  List<Object?> get props => [message];
}

