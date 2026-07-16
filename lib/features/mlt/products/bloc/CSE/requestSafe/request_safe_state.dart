import 'package:equatable/equatable.dart';
import '../../../data/models/CSE_models/request_safe_response_model.dart';

abstract class RequestSafeState extends Equatable {
  const RequestSafeState();

  @override
  List<Object?> get props => [];
}

class RequestSafeInitial extends RequestSafeState {}

class RequestSafeLoading extends RequestSafeState {}

class RequestSafeSuccess extends RequestSafeState {
  final RequestSafeResponseModel response;
  const RequestSafeSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class RequestSafeError extends RequestSafeState {
  final String message;
  const RequestSafeError(this.message);

  @override
  List<Object?> get props => [message];
}
