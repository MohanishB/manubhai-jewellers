import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/solitaire/data/models/save_order_models.dart';

abstract class SaveOrderState extends Equatable {
  const SaveOrderState();
  @override
  List<Object?> get props => [];
}

class SaveOrderInitial extends SaveOrderState {
  const SaveOrderInitial();
}

class SaveOrderLoading extends SaveOrderState {
  const SaveOrderLoading();
}

class SaveOrderSuccess extends SaveOrderState {
  final SaveOrderResponse response;
  const SaveOrderSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class SaveOrderError extends SaveOrderState {
  final String message;
  const SaveOrderError(this.message);

  @override
  List<Object?> get props => [message];
}