import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/cse_requested_stock_list_model.dart';


abstract class CseRequestedStockListState extends Equatable {
  const CseRequestedStockListState();
  @override
  List<Object?> get props => [];
}

class CseRequestedStockListInitial extends CseRequestedStockListState {
  const CseRequestedStockListInitial();
}

class CseRequestedStockListLoading extends CseRequestedStockListState {
  const CseRequestedStockListLoading();
}

class CseRequestedStockListLoaded extends CseRequestedStockListState {
  final int totalProduct;
  final List<CseRequestedStockGroup> groups;

  const CseRequestedStockListLoaded({
    required this.totalProduct,
    required this.groups,
  });

  @override
  List<Object?> get props => [totalProduct, groups];
}

class CseRequestedStockListError extends CseRequestedStockListState {
  final String message;
  const CseRequestedStockListError(this.message);

  @override
  List<Object?> get props => [message];
}
