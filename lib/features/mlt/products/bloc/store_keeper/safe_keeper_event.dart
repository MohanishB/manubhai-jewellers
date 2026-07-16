import 'package:equatable/equatable.dart';

abstract class SafeKeeperEvent extends Equatable {
  const SafeKeeperEvent();

  @override
  List<Object?> get props => [];
}

class FetchSafeKeeperRequests extends SafeKeeperEvent {
  final String cseId;

  const FetchSafeKeeperRequests(this.cseId);

  @override
  List<Object?> get props => [cseId];
}
