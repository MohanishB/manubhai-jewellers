import 'package:equatable/equatable.dart';

abstract class StockDetailEvent extends Equatable {
  const StockDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchStockDetailEvent extends StockDetailEvent {
  final String stockCode;

  const FetchStockDetailEvent(this.stockCode);

  @override
  List<Object> get props => [stockCode];
}
