import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/freeze_product_repository.dart';
import 'freeze_product_event.dart'; import 'freeze_product_state.dart';
class FreezeProductBloc extends Bloc<FreezeProductEvent,FreezeProductState> {
 final FreezeProductRepository repository;
 FreezeProductBloc(this.repository):super(FreezeProductInitial()){ on<FreezeProductRequested>((event,emit) async {
   emit(FreezeProductLoading(event.stockCode));
   try { final r=await repository.setFreeze(cseId:event.cseId,stockCode:event.stockCode,freeze:true);
     emit(FreezeProductCompleted(stockCode:event.stockCode,status:r.status,success:r.success,errorCode:r.errorCode,message:r.message));
   } catch(e){ emit(FreezeProductFailure(event.stockCode,e.toString().replaceFirst('Exception: ',''))); }
 });}
}
