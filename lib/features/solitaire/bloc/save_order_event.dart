// import 'package:equatable/equatable.dart';

// abstract class SaveOrderEvent extends Equatable {
//   const SaveOrderEvent();
//   @override
//   List<Object?> get props => [];
// }

// class SubmitSaveOrder extends SaveOrderEvent {
//   final String cseId;
//   final String stockCode;
//   final String diamondId;
//   final String customerName;
//   final String customerPhone;
//   final String customerEmail;

//   final Map<String, dynamic> originalProduct;
//   final Map<String, dynamic> priceCalculation;

//   const SubmitSaveOrder({
//     required this.cseId,
//     required this.stockCode,
//     required this.diamondId,
//     required this.customerName,
//     required this.customerPhone,
//     required this.customerEmail,
//     required this.originalProduct,
//     required this.priceCalculation,
//   });

//   @override
//   List<Object?> get props => [
//         cseId,
//         stockCode,
//         diamondId,
//         customerName,
//         customerPhone,
//         customerEmail,
//         originalProduct,
//         priceCalculation,
//       ];
// }

// class ClearSaveOrder extends SaveOrderEvent {
//   const ClearSaveOrder();
// }

//==================================//
//==================================//
//==================================//

import 'package:equatable/equatable.dart';

abstract class SaveOrderEvent extends Equatable {
  const SaveOrderEvent();

  @override
  List<Object?> get props => [];
}

class SubmitSaveOrder extends SaveOrderEvent {
  final String cseId;
  final String stockCode;
  final String diamondId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String selectedKarat;

  final Map<String, dynamic> originalProduct;
  final Map<String, dynamic> priceCalculation;

  const SubmitSaveOrder({
    required this.cseId,
    required this.stockCode,
    required this.diamondId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.selectedKarat,
    required this.originalProduct,
    required this.priceCalculation,
  });

  @override
  List<Object?> get props => [
        cseId,
        stockCode,
        diamondId,
        customerName,
        customerPhone,
        customerEmail,
        selectedKarat,
        originalProduct,
        priceCalculation,
      ];
}

class ClearSaveOrder extends SaveOrderEvent {
  const ClearSaveOrder();
}