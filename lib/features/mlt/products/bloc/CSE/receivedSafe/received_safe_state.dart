import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/received_safe_model.dart';


abstract class ReceivedSafeState extends Equatable {
  const ReceivedSafeState();

  @override
  List<Object?> get props => [];
}

class ReceivedSafeInitial extends ReceivedSafeState {}

class ReceivedSafeLoading extends ReceivedSafeState {}

class ReceivedSafeLoaded extends ReceivedSafeState {
  final ReceivedSafeResponse response;

  const ReceivedSafeLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

class ReceivedSafeError extends ReceivedSafeState {
  final String message;

  const ReceivedSafeError(this.message);

  @override
  List<Object?> get props => [message];
}
