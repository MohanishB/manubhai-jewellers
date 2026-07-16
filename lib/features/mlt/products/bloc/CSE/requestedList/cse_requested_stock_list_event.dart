import 'package:equatable/equatable.dart';

abstract class CseRequestedStockListEvent extends Equatable {
  const CseRequestedStockListEvent();
  @override
  List<Object?> get props => [];
}

class FetchCseRequestedStockList extends CseRequestedStockListEvent {
  final String cseId;
  const FetchCseRequestedStockList(this.cseId);

  @override
  List<Object?> get props => [cseId];
}

class ResetCseRequestedStockList extends CseRequestedStockListEvent {
  const ResetCseRequestedStockList();
}
