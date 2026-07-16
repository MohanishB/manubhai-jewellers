import 'package:equatable/equatable.dart';

abstract class ReceivedSafeEvent extends Equatable {
  const ReceivedSafeEvent();

  @override
  List<Object?> get props => [];
}

class FetchReceivedSafeList extends ReceivedSafeEvent {
  final String cseId;

  const FetchReceivedSafeList(this.cseId);

  @override
  List<Object?> get props => [cseId];
}
