import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/shop_keeper_models/safe_keeper_request_model.dart';
 

abstract class SafeKeeperState extends Equatable {
  const SafeKeeperState();

  @override
  List<Object?> get props => [];
}

class SafeKeeperInitial extends SafeKeeperState {}

class SafeKeeperLoading extends SafeKeeperState {}

class SafeKeeperLoaded extends SafeKeeperState {
  final List<SafeKeeperRequestModel> requests;
  const SafeKeeperLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class SafeKeeperError extends SafeKeeperState {
  final String message;
  const SafeKeeperError(this.message);

  @override
  List<Object?> get props => [message];
}
