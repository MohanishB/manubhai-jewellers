import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/solitaire/data/models/filter_options_response_model.dart';

abstract class FilterOptionsState extends Equatable {
  const FilterOptionsState();

  @override
  List<Object?> get props => [];
}

class FilterOptionsInitial extends FilterOptionsState {}

class FilterOptionsLoading extends FilterOptionsState {}

class FilterOptionsLoaded extends FilterOptionsState {
  final FilterOptions options;

  const FilterOptionsLoaded(this.options);

  @override
  List<Object?> get props => [options];
}

class FilterOptionsError extends FilterOptionsState {
  final String message;

  const FilterOptionsError(this.message);

  @override
  List<Object?> get props => [message];
}


class FilterShapesLoaded extends FilterOptionsState {
  final List<String> shapes;

  const FilterShapesLoaded(this.shapes);

  @override
  List<Object?> get props => [shapes];
}
