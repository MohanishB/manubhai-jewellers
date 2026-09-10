import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';
abstract class FreezeProductState extends Equatable { const FreezeProductState(); @override List<Object?> get props=>[]; }
class FreezeProductInitial extends FreezeProductState {}
class FreezeProductLoading extends FreezeProductState { final String stockCode; const FreezeProductLoading(this.stockCode); @override List<Object?> get props=>[stockCode]; }
class FreezeProductCompleted extends FreezeProductState {
 final String stockCode, message; final FreezedProductStatus status; final bool success; final int errorCode;
 const FreezeProductCompleted({required this.stockCode,required this.status,required this.success,required this.errorCode,required this.message});
 @override List<Object?> get props=>[stockCode,status.freezed,status.byOwn,status.byOther,status.cseName,success,errorCode,message];
}
class FreezeProductFailure extends FreezeProductState { final String stockCode,message; const FreezeProductFailure(this.stockCode,this.message); @override List<Object?> get props=>[stockCode,message]; }
