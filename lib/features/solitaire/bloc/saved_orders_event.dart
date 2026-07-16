import 'package:equatable/equatable.dart';

abstract class SavedOrdersEvent extends Equatable {
  const SavedOrdersEvent();
  @override
  List<Object?> get props => [];
}

class FetchSavedOrders extends SavedOrdersEvent {
  final String cseId;
  final String fromDate; // yyyy-MM-dd
  final String toDate;   // yyyy-MM-dd
  final String customerName;
  final String customerPhone;

  const FetchSavedOrders({
    required this.cseId,
    required this.fromDate,
    required this.toDate,
    this.customerName = '',
    this.customerPhone = '',
  });

  @override
  List<Object?> get props => [cseId, fromDate, toDate, customerName, customerPhone];
}