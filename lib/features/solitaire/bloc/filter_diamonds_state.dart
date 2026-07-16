// lib/features/solitaire/bloc/filter_diamonds_state.dart
import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/solitaire/data/models/solitaire_diamond_models.dart';

abstract class FilterDiamondsState extends Equatable {
  const FilterDiamondsState();

  @override
  List<Object?> get props => [];
}

class FilterDiamondsInitial extends FilterDiamondsState {
  const FilterDiamondsInitial();
}

class FilterDiamondsLoading extends FilterDiamondsState {
  const FilterDiamondsLoading();
}

class FilterDiamondsLoaded extends FilterDiamondsState {
  final List<SolitaireDiamondVm> diamonds;
  final int totalCount;

  const FilterDiamondsLoaded({
    required this.diamonds,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [diamonds, totalCount];
}

class FilterDiamondsError extends FilterDiamondsState {
  final String message;
  const FilterDiamondsError(this.message);

  @override
  List<Object?> get props => [message];
}
