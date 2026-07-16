import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/shop_keeper_models/safe_keeper_request_detail_model.dart';

abstract class SafeKeeperRequestDetailState extends Equatable {
  const SafeKeeperRequestDetailState();

  @override
  List<Object?> get props => [];
}

class SafeKeeperRequestDetailInitial extends SafeKeeperRequestDetailState {
  const SafeKeeperRequestDetailInitial();
}

class SafeKeeperRequestDetailLoading extends SafeKeeperRequestDetailState {
  const SafeKeeperRequestDetailLoading();
}

class SafeKeeperRequestDetailLoaded extends SafeKeeperRequestDetailState {
  final SafeKeeperRequestDetailProduct request;

  const SafeKeeperRequestDetailLoaded({required this.request});

  @override
  List<Object?> get props => [request];
}

class SafeKeeperRequestDetailError extends SafeKeeperRequestDetailState {
  final String message;

  const SafeKeeperRequestDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class SafeKeeperRequestDetailCompleted extends SafeKeeperRequestDetailState {
  final String message;

  const SafeKeeperRequestDetailCompleted({
    this.message = 'This request is completed and has no pending items.',
  });

  @override
  List<Object?> get props => [message];
}
