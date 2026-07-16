part of 'safe_keeper_update_bloc.dart';

abstract class SafeKeeperUpdateEvent {}

class UpdateSafeKeeperStatus extends SafeKeeperUpdateEvent {
  final String cseId;
  final String safeRequestId;
  final List<String> stockList;
  final int status; // 1: dispatched, 2: not found

  UpdateSafeKeeperStatus({
    required this.cseId,
    required this.safeRequestId,
    required this.stockList,
    required this.status,
  });
}
