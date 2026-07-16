// import 'package:equatable/equatable.dart';

// class FetchStep3OrderSummary extends Equatable {
//   final String cseId;
//   final String stockCode;
//   final String diamondId;
//   final String customerName;
//   final String customerPhone;
//   final String? customerEmail;

//   const FetchStep3OrderSummary({
//     required this.cseId,
//     required this.stockCode,
//     required this.diamondId,
//     required this.customerName,
//     required this.customerPhone,
//     this.customerEmail,
//   });

//   @override
//   List<Object?> get props => [
//         cseId,
//         stockCode,
//         diamondId,
//         customerName,
//         customerPhone,
//         customerEmail,
//       ];
// }

// class ClearStep3OrderSummary extends Equatable {
//   const ClearStep3OrderSummary();

//   @override
//   List<Object?> get props => [];
// }

//============================================//
//============================================//
//============================================//  

import 'package:equatable/equatable.dart';

class FetchStep3OrderSummary extends Equatable {
  final String cseId;
  final String stockCode;
  final String diamondId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;

  const FetchStep3OrderSummary({
    required this.cseId,
    required this.stockCode,
    required this.diamondId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
  });

  @override
  List<Object?> get props => [
        cseId,
        stockCode,
        diamondId,
        customerName,
        customerPhone,
        customerEmail,
      ];
}

/// ✅ NEW: fetch step-3 summary for saved order view (order_id + cse_id)
class FetchStep3OrderSummaryByOrderId extends Equatable {
  final String cseId;
  final String orderId; // numeric order_id from saved orders list ("25")

  const FetchStep3OrderSummaryByOrderId({
    required this.cseId,
    required this.orderId,
  });

  @override
  List<Object?> get props => [cseId, orderId];
}

class ClearStep3OrderSummary extends Equatable {
  const ClearStep3OrderSummary();

  @override
  List<Object?> get props => [];
}