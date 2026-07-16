import 'package:equatable/equatable.dart';

abstract class FilterOptionsEvent extends Equatable {
  const FilterOptionsEvent();

  @override
  List<Object?> get props => [];
}

class FetchFilterOptions extends FilterOptionsEvent {
  final String cseId;
  final String stockCode;

  const FetchFilterOptions({
    required this.cseId,
    required this.stockCode,
  });

  @override
  List<Object?> get props => [cseId, stockCode];
}


class FetchFilterShapes extends FilterOptionsEvent {
  final String cseId;
  final String stockCode;

  const FetchFilterShapes({
    required this.cseId,
    required this.stockCode,
  });

  @override
  List<Object?> get props => [cseId, stockCode];
}

class FetchFilterOptionsByShape extends FilterOptionsEvent {
  final String cseId;
  final String stockCode;
  final String shape;

  const FetchFilterOptionsByShape({
    required this.cseId,
    required this.stockCode,
    required this.shape,
  });

  @override
  List<Object?> get props => [cseId, stockCode, shape];
}
