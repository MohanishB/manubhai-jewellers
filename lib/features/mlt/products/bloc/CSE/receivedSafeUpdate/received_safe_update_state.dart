import 'package:equatable/equatable.dart';
import '../../../data/models/CSE_models/received_safe_update_model.dart';

abstract class ReceivedSafeUpdateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReceivedSafeUpdateInitial extends ReceivedSafeUpdateState {}

class ReceivedSafeUpdateLoading extends ReceivedSafeUpdateState {}

class ReceivedSafeUpdateSuccess extends ReceivedSafeUpdateState {
  final ReceivedSafeUpdateResponse response;
  ReceivedSafeUpdateSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ReceivedSafeUpdateError extends ReceivedSafeUpdateState {
  final String message;
  ReceivedSafeUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}
