import 'package:equatable/equatable.dart';
import '../data/models/saved_orders_response_model.dart';

abstract class SavedOrdersState extends Equatable {
  const SavedOrdersState();
  @override
  List<Object?> get props => [];
}

class SavedOrdersInitial extends SavedOrdersState {
  const SavedOrdersInitial();
}

class SavedOrdersLoading extends SavedOrdersState {
  const SavedOrdersLoading();
}

class SavedOrdersLoaded extends SavedOrdersState {
  final List<SavedOrderApiModel> orders;
  final int totalCount;

  const SavedOrdersLoaded({
    required this.orders,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [orders, totalCount];
}

class SavedOrdersError extends SavedOrdersState {
  final String message;
  const SavedOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}