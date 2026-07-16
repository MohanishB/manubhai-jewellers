// // lib/features/solitaire/bloc/filter_diamonds_event.dart
// import 'package:equatable/equatable.dart';

// class FetchFilterDiamonds extends Equatable {
//   final String cseId;
//   final String stockCode;

//   final String? priceMin;
//   final String? priceMax;
//   final String? caratMin;
//   final String? caratMax;

//   final List<String> colors;
//   final List<String> clarities;
//   final List<String> cuts;
//   final List<String> certificates;

//   const FetchFilterDiamonds({
//     required this.cseId,
//     required this.stockCode,
//     this.priceMin,
//     this.priceMax,
//     this.caratMin,
//     this.caratMax,
//     this.colors = const [],
//     this.clarities = const [],
//     this.cuts = const [],
//     this.certificates = const [],
//   });

//   @override
//   List<Object?> get props => [
//         cseId,
//         stockCode,
//         priceMin,
//         priceMax,
//         caratMin,
//         caratMax,
//         colors,
//         clarities,
//         cuts,
//         certificates,
//       ];
// }

// class ClearFilterDiamonds extends Equatable {
//   const ClearFilterDiamonds();

//   @override
//   List<Object?> get props => [];
// }

//========================================//
//========================================//
//========================================//

// lib/features/solitaire/bloc/filter_diamonds_event.dart
import 'package:equatable/equatable.dart';

class FetchFilterDiamonds extends Equatable {
  final String cseId;
  final String stockCode;
  final String? shape;

  final String? priceMin;
  final String? priceMax;
  final String? caratMin;
  final String? caratMax;

  final List<String> colors;
  final List<String> clarities;
  final List<String> cuts;
  final List<String> certificates;

  // ✅ NEW: sort
  final String? sortBy;     // e.g. carats,color,cut,value_inr,cert
  final String? sortOrder;  // ASC / DESC

  // ✅ NEW: optional search-within-results (if you later want it via API)
  final String? lotNumber;
  final String? certNumber;
  final String? searchCaratMin;
  final String? searchCaratMax;
  final String? searchPriceMin;
  final String? searchPriceMax;

  const FetchFilterDiamonds({
    required this.cseId,
    required this.stockCode,
    this.shape,
    this.priceMin,
    this.priceMax,
    this.caratMin,
    this.caratMax,
    this.colors = const [],
    this.clarities = const [],
    this.cuts = const [],
    this.certificates = const [],

    this.sortBy,
    this.sortOrder,

    this.lotNumber,
    this.certNumber,
    this.searchCaratMin,
    this.searchCaratMax,
    this.searchPriceMin,
    this.searchPriceMax,
  });

  @override
  List<Object?> get props => [
        cseId,
        stockCode,
        shape,
        priceMin,
        priceMax,
        caratMin,
        caratMax,
        colors,
        clarities,
        cuts,
        certificates,
        sortBy,
        sortOrder,
        lotNumber,
        certNumber,
        searchCaratMin,
        searchCaratMax,
        searchPriceMin,
        searchPriceMax,
      ];
}

class ClearFilterDiamonds extends Equatable {
  const ClearFilterDiamonds();

  @override
  List<Object?> get props => [];
}
