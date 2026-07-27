import 'package:equatable/equatable.dart';

abstract class SoliShiftLgEvent extends Equatable {
  const SoliShiftLgEvent();

  @override
  List<Object?> get props => [];
}

class SoliShiftLgSearchRequested extends SoliShiftLgEvent {
  final String cseId;
  final String stockCode;

  const SoliShiftLgSearchRequested({
    required this.cseId,
    required this.stockCode,
  });

  @override
  List<Object?> get props => [cseId, stockCode];
}

class SoliShiftLgCustomizeClicked extends SoliShiftLgEvent {
  const SoliShiftLgCustomizeClicked();
}

class SoliShiftLgModeChanged extends SoliShiftLgEvent {
  final String mode;

  const SoliShiftLgModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SoliShiftLgCaratUpdateRequested extends SoliShiftLgEvent {
  final String newSolitaireCt;
  final String newDiamondCt;

  const SoliShiftLgCaratUpdateRequested({
    required this.newSolitaireCt,
    required this.newDiamondCt,
  });

  @override
  List<Object?> get props => [newSolitaireCt, newDiamondCt];
}

class SoliShiftLgBudgetUpdateRequested extends SoliShiftLgEvent {
  final String budget;

  const SoliShiftLgBudgetUpdateRequested({required this.budget});

  @override
  List<Object?> get props => [budget];
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
