import 'package:equatable/equatable.dart';

class SubmitConfirmOrder extends Equatable {
  final String cseId;
  final String stockCode;
  final String diamondId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final Map<String, dynamic> originalProduct;
  final Map<String, dynamic> priceCalculation;

  const SubmitConfirmOrder({
    required this.cseId,
    required this.stockCode,
    required this.diamondId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
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
        originalProduct,
        priceCalculation,
      ];
}
