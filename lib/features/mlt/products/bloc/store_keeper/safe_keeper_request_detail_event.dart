import 'package:equatable/equatable.dart';

abstract class SafeKeeperRequestDetailEvent extends Equatable {
  const SafeKeeperRequestDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchSafeKeeperRequestDetail extends SafeKeeperRequestDetailEvent {
  final String cseId;
  final String safeRequestId;

  const FetchSafeKeeperRequestDetail({
    required this.cseId,
    required this.safeRequestId,
  });

  @override
  List<Object?> get props => [cseId, safeRequestId];
}
