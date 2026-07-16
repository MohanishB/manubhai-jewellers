import 'package:equatable/equatable.dart';

abstract class RequestSafeEvent extends Equatable {
  const RequestSafeEvent();

  @override
  List<Object?> get props => [];
}

class SubmitRequestSafe extends RequestSafeEvent {
  final String cseId;
  final List<String> stockList;

  const SubmitRequestSafe({
    required this.cseId,
    required this.stockList,
  });

  @override
  List<Object?> get props => [cseId, stockList];
}
