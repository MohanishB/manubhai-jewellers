import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/solitaire/data/models/confirm_order_models.dart';

abstract class ConfirmOrderState extends Equatable {
  const ConfirmOrderState();
  @override
  List<Object?> get props => [];
}

class ConfirmOrderInitial extends ConfirmOrderState {
  const ConfirmOrderInitial();
}

class ConfirmOrderLoading extends ConfirmOrderState {
  const ConfirmOrderLoading();
}

class ConfirmOrderSuccess extends ConfirmOrderState {
  final ConfirmOrderResponse response;
  const ConfirmOrderSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ConfirmOrderError extends ConfirmOrderState {
  final String message;
  const ConfirmOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
