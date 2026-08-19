// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/product_filter_repository.dart';
// import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_response_model.dart';
// import 'product_filter_event.dart';
// import 'product_filter_state.dart';

// class ProductFilterBloc extends Bloc<ProductFilterEvent, ProductFilterState> {
//   final ProductFilterRepository repository;

//   ProductFilterBloc({required this.repository}) : super(ProductFilterInitial()) {
//     on<FetchProductFilters>(_onFetchFilters);
//     on<UpdateSelectedFilter>(_onUpdateSelectedFilter);
//     on<SetSelectedFilters>(_onSetSelectedFilters);
//     on<ResetProductFilters>(_onReset);
//   }

//   Future<void> _onFetchFilters(
//     FetchProductFilters event,
//     Emitter<ProductFilterState> emit,
//   ) async {
//     // ✅ Preserve selections BEFORE loading state
//     Map<String, dynamic> oldSelections = {};
//     final prev = state;
//     if (prev is ProductFilterLoaded) {
//       oldSelections = Map<String, dynamic>.from(prev.selectedFilters);
//     }

//     emit(ProductFilterLoading());

//     try {
//       final ProductFilterResponse resp = await repository.fetchFilters(event.cseId);

//       emit(ProductFilterLoaded(
//         resp.filters,
//         sortBy: resp.sortBy,
//         selectedFilters: oldSelections,
//       ));
//     } catch (e) {
//       emit(ProductFilterError(ApiErrorHandler.message(e)));
//     }
//   }

//   void _onUpdateSelectedFilter(
//     UpdateSelectedFilter event,
//     Emitter<ProductFilterState> emit,
//   ) {
//     if (state is! ProductFilterLoaded) return;

//     final current = state as ProductFilterLoaded;
//     final updated = Map<String, dynamic>.from(current.selectedFilters);

//     if (event.value == null ||
//         (event.value is Set && (event.value as Set).isEmpty)) {
//       updated.remove(event.label);
//     } else {
//       updated[event.label] = event.value;
//     }

//     emit(current.copyWith(selectedFilters: updated));
//   }

//   void _onSetSelectedFilters(
//     SetSelectedFilters event,
//     Emitter<ProductFilterState> emit,
//   ) {
//     final current = state;
//     if (current is ProductFilterLoaded) {
//       emit(current.copyWith(selectedFilters: event.selected));
//     }
//   }

//    void _onReset(
//     ResetProductFilters event,
//     Emitter<ProductFilterState> emit,
//   ) {
//     emit(ProductFilterInitial());
//   }
// }

//==========================================//

import 'package:manubhaimlt/core/errors/api_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_model.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_response_model.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/product_filter_repository.dart';

import 'product_filter_event.dart';
import 'product_filter_state.dart';

class ProductFilterBloc extends Bloc<ProductFilterEvent, ProductFilterState> {
  final ProductFilterRepository repository;

  ProductFilterBloc({required this.repository}) : super(ProductFilterInitial()) {
    on<FetchProductFilters>(_onFetchFilters);
    on<FetchProductSubFilters>(_onFetchSubFilters);
    on<UpdateSelectedFilter>(_onUpdateSelectedFilter);
    on<SetSelectedFilters>(_onSetSelectedFilters);
    on<ResetProductFilters>(_onReset);
  }

  Future<void> _onFetchFilters(
    FetchProductFilters event,
    Emitter<ProductFilterState> emit,
  ) async {
    Map<String, dynamic> oldSelections = {};

    final prev = state;
    if (prev is ProductFilterLoaded) {
      oldSelections = Map<String, dynamic>.from(prev.selectedFilters);
    }

    emit(ProductFilterLoading());

    try {
      final ProductFilterResponse resp =
          await repository.fetchMainFilters(event.cseId);

      final selected = _sanitizeSelections(resp.filters, oldSelections);

      emit(ProductFilterLoaded(
        resp.filters,
        mainFilters: resp.filters,
        sortBy: resp.sortBy,
        selectedFilters: selected,
        cseId: resp.cseId.isNotEmpty ? resp.cseId : event.cseId,
        cseMltBranch: resp.cseMltBranch,
        cseMltLocation: resp.cseMltLocation,
        subFiltersLoaded: false,
        subFiltersLoading: false,
      ));

      final lob = _selectedValueByPostName(resp.filters, selected, 'lob');
      final category =
          _selectedValueByPostName(resp.filters, selected, 'category');

      if (lob.isNotEmpty && category.isNotEmpty) {
        add(FetchProductSubFilters(
          cseId: event.cseId,
          lob: lob,
          category: category,
        ));
      }
    } catch (e) {
      emit(ProductFilterError(ApiErrorHandler.message(e)));
    }
  }

  Future<void> _onFetchSubFilters(
    FetchProductSubFilters event,
    Emitter<ProductFilterState> emit,
  ) async {
    final current = state;
    if (current is! ProductFilterLoaded) return;

    emit(current.copyWith(
      subFiltersLoading: true,
      subFilterError: null,
    ));

    try {
      final resp = await repository.fetchSubFilters(
        cseId: event.cseId,
        lob: event.lob,
        category: event.category,
      );

      final mainMandatory = current.mainFilters.where(_isMainFilter).toList();
      final mergedFilters = <ProductFilterModel>[
        ...mainMandatory,
        ...resp.filters,
      ];

      final selected = _sanitizeSelections(
        mergedFilters,
        current.selectedFilters,
      );

      emit(current.copyWith(
        filters: mergedFilters,
        sortBy: resp.sortBy,
        selectedFilters: selected,
        subFiltersLoading: false,
        subFiltersLoaded: true,
        subFilterError: null,
      ));
    } catch (e) {
      emit(current.copyWith(
        subFiltersLoading: false,
        subFiltersLoaded: false,
        subFilterError: ApiErrorHandler.message(e),
      ));
    }
  }

  void _onUpdateSelectedFilter(
    UpdateSelectedFilter event,
    Emitter<ProductFilterState> emit,
  ) {
    if (state is! ProductFilterLoaded) return;

    final current = state as ProductFilterLoaded;
    final updated = Map<String, dynamic>.from(current.selectedFilters);

    if (event.value == null ||
        (event.value is Set && (event.value as Set).isEmpty)) {
      updated.remove(event.label);
    } else {
      updated[event.label] = event.value;
    }

    final changedFilter = current.filters
        .where((f) => f.labelDisplay == event.label)
        .cast<ProductFilterModel?>()
        .firstWhere((f) => f != null, orElse: () => null);

    final changedPostName =
        changedFilter?.postName['para1']?.toString().trim() ?? '';

    final isLobOrCategory =
        changedPostName == 'lob' || changedPostName == 'category';

    if (isLobOrCategory) {
      final mainOnlySelections = <String, dynamic>{};

      for (final f in current.mainFilters.where(_isMainFilter)) {
        if (updated.containsKey(f.labelDisplay)) {
          mainOnlySelections[f.labelDisplay] = updated[f.labelDisplay];
        }
      }

      emit(current.copyWith(
        filters: current.mainFilters,
        selectedFilters: mainOnlySelections,
        subFiltersLoaded: false,
        subFiltersLoading: false,
        subFilterError: null,
      ));
    } else {
      emit(current.copyWith(selectedFilters: updated));
    }
  }

  void _onSetSelectedFilters(
    SetSelectedFilters event,
    Emitter<ProductFilterState> emit,
  ) {
    final current = state;
    if (current is ProductFilterLoaded) {
      emit(current.copyWith(selectedFilters: event.selected));
    }
  }

  void _onReset(
    ResetProductFilters event,
    Emitter<ProductFilterState> emit,
  ) {
    emit(ProductFilterInitial());
  }

  bool _isMainFilter(ProductFilterModel filter) {
    final postName = filter.postName['para1']?.toString().trim() ?? '';
    return postName == 'lob' || postName == 'category';
  }

  String _selectedValueByPostName(
    List<ProductFilterModel> filters,
    Map<String, dynamic> selectedFilters,
    String postName,
  ) {
    for (final filter in filters) {
      final para1 = filter.postName['para1']?.toString().trim() ?? '';
      if (para1 == postName) {
        return selectedFilters[filter.labelDisplay]?.toString().trim() ?? '';
      }
    }
    return '';
  }

  Map<String, dynamic> _sanitizeSelections(
    List<ProductFilterModel> filters,
    Map<String, dynamic> oldSelections,
  ) {
    final result = <String, dynamic>{};

    for (final filter in filters) {
      if (!oldSelections.containsKey(filter.labelDisplay)) continue;

      final value = oldSelections[filter.labelDisplay];

      if (filter.fieldType == 'radio') {
        final selected = value?.toString() ?? '';
        if (selected.isNotEmpty && filter.values.contains(selected)) {
          result[filter.labelDisplay] = selected;
        }
      } else if (filter.fieldType == 'checkbox') {
        final oldSet = value is Set
            ? value.map((e) => e.toString()).toSet()
            : value is List
                ? value.map((e) => e.toString()).toSet()
                : <String>{};

        final validSet =
            oldSet.where((e) => filter.values.contains(e)).toSet();

        if (validSet.isNotEmpty) {
          result[filter.labelDisplay] = validSet;
        }
      } else if (filter.fieldType == 'input_from_to') {
        if (value is Map) {
          result[filter.labelDisplay] = {
            'from': value['from']?.toString() ?? '',
            'to': value['to']?.toString() ?? '',
          };
        }
      }
    }

    return result;
  }
}