import 'package:equatable/equatable.dart';

class ReceivedSafeUpdateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateReceivedSafeStatus extends ReceivedSafeUpdateEvent {
  final String cseId;
  final String safeRequestId;
  final List<String> stockList;
  final int status; // 1 = received, 2 = not received

  UpdateReceivedSafeStatus({
    required this.cseId,
    required this.safeRequestId,
    required this.stockList,
    required this.status,
  });

  @override
  List<Object?> get props => [cseId, safeRequestId, stockList, status];
}
