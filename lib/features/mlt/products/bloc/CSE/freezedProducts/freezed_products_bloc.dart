import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/freeze_product_repository.dart';
abstract class FreezedProductsEvent extends Equatable { const FreezedProductsEvent(); @override List<Object?> get props=>[]; }
class LoadFreezedProducts extends FreezedProductsEvent { final String cseId; const LoadFreezedProducts(this.cseId); @override List<Object?> get props=>[cseId]; }
class UnfreezeProductRequested extends FreezedProductsEvent { final String cseId,stockCode; const UnfreezeProductRequested(this.cseId,this.stockCode); @override List<Object?> get props=>[cseId,stockCode]; }
abstract class FreezedProductsState extends Equatable { const FreezedProductsState(); @override List<Object?> get props=>[]; }
class FreezedProductsInitial extends FreezedProductsState {}
class FreezedProductsLoading extends FreezedProductsState {}
class FreezedProductsLoaded extends FreezedProductsState { final List<FreezedProductListItem> products; final String? updatingStockCode; final String? lastUnfreezedStockCode; const FreezedProductsLoaded(this.products,{this.updatingStockCode,this.lastUnfreezedStockCode}); @override List<Object?> get props=>[products,updatingStockCode,lastUnfreezedStockCode]; }
class FreezedProductsError extends FreezedProductsState { final String message; const FreezedProductsError(this.message); @override List<Object?> get props=>[message]; }
class FreezedProductsBloc extends Bloc<FreezedProductsEvent,FreezedProductsState>{
 final FreezeProductRepository repository; FreezedProductsBloc(this.repository):super(FreezedProductsInitial()){
 on<LoadFreezedProducts>((e,emit) async {emit(FreezedProductsLoading()); try{emit(FreezedProductsLoaded(await repository.getFreezedProducts(e.cseId)));}catch(x){emit(FreezedProductsError(x.toString().replaceFirst('Exception: ','')));}});
 on<UnfreezeProductRequested>((e,emit) async {final s=state;if(s is! FreezedProductsLoaded)return; emit(FreezedProductsLoaded(s.products,updatingStockCode:e.stockCode));try{final r=await repository.setFreeze(cseId:e.cseId,stockCode:e.stockCode,freeze:false);if(!r.success)throw Exception(r.message);emit(FreezedProductsLoaded(s.products.where((p)=>p.stockCode!=e.stockCode).toList(),lastUnfreezedStockCode:e.stockCode));}catch(x){emit(FreezedProductsError(x.toString().replaceFirst('Exception: ','')));}});
 }}
