import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/solitaire/data/models/step3_order_summary_models.dart';

abstract class Step3OrderSummaryState extends Equatable {
  const Step3OrderSummaryState();

  @override
  List<Object?> get props => [];
}

class Step3OrderSummaryInitial extends Step3OrderSummaryState {
  const Step3OrderSummaryInitial();
}

class Step3OrderSummaryLoading extends Step3OrderSummaryState {
  const Step3OrderSummaryLoading();
}

class Step3OrderSummaryLoaded extends Step3OrderSummaryState {
  final Step3OrderSummaryVm summary;
  const Step3OrderSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class Step3OrderSummaryError extends Step3OrderSummaryState {
  final String message;
  const Step3OrderSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
