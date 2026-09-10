import 'package:equatable/equatable.dart';
abstract class FreezeProductEvent extends Equatable { const FreezeProductEvent(); @override List<Object?> get props=>[]; }
class FreezeProductRequested extends FreezeProductEvent {
 final String cseId, stockCode; const FreezeProductRequested({required this.cseId, required this.stockCode});
 @override List<Object?> get props=>[cseId,stockCode];
}
