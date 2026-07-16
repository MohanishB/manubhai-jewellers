import 'package:equatable/equatable.dart';

abstract class SoliShiftLgEvent extends Equatable {
  const SoliShiftLgEvent();

  @override
  List<Object?> get props => [];
}

class SoliShiftLgSearchRequested extends SoliShiftLgEvent {
  final String cseId;
  final String stockCode;
  final String newSolitaireCt;

  const SoliShiftLgSearchRequested({
    required this.cseId,
    required this.stockCode,
    this.newSolitaireCt = '',
  });

  @override
  List<Object?> get props => [cseId, stockCode, newSolitaireCt];
}

class SoliShiftLgCustomizeClicked extends SoliShiftLgEvent {
  const SoliShiftLgCustomizeClicked();
}

class SoliShiftLgFilterChanged extends SoliShiftLgEvent {
  final String shape;
  final String colour;
  final String clarity;

  const SoliShiftLgFilterChanged({
    required this.shape,
    required this.colour,
    required this.clarity,
  });

  @override
  List<Object?> get props => [shape, colour, clarity];
}

class SoliShiftLgFiltersReset extends SoliShiftLgEvent {
  const SoliShiftLgFiltersReset();
}
