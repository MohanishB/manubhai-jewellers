import 'package:equatable/equatable.dart';
import '../data/models/stock_detail_model.dart';

abstract class StockDetailState extends Equatable {
  const StockDetailState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockDetailState {}

class StockLoading extends StockDetailState {}

class StockLoaded extends StockDetailState {
  final StockDetailModel stock;

  const StockLoaded(this.stock);

  @override
  List<Object?> get props => [stock];
}

class StockError extends StockDetailState {
  final String message;

  const StockError(this.message);

  @override
  List<Object?> get props => [message];
}
