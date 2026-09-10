import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/theme/app_colors.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/freezedProducts/freezed_products_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/bucketSimilarProducts/bucket_similar_products_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/bucketSimilarProducts/bucket_similar_products_event.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';

class FreezedProductsScreen extends StatefulWidget { const FreezedProductsScreen({super.key}); @override State<FreezedProductsScreen> createState()=>_FreezedProductsScreenState(); }
class _FreezedProductsScreenState extends State<FreezedProductsScreen>{
 @override void initState(){super.initState();WidgetsBinding.instance.addPostFrameCallback((_){final a=context.read<AuthBloc>().state;if(a is AuthAuthenticated)context.read<FreezedProductsBloc>().add(LoadFreezedProducts(a.user.id));});}
 @override Widget build(BuildContext context){
  final auth=context.watch<AuthBloc>().state;if(auth is! AuthAuthenticated)return const SizedBox.shrink();
  return MJScaffold(username:auth.user.firstName,onLogout:()=>context.read<AuthBloc>().add(const AuthLogoutRequested()),requestSafeCount:0,receivedSafeCount:0,onRequestSafe:(){},onRequestedList:()=>context.pushReplacement('/a/requested-stock-list'),onReceivedSafe:()=>context.pushReplacement('/a/received-safe'),onCustomerExperience:()=>context.pushReplacement('/a/customer-review'),onFreezedProducts:(){},showHome:true,showBack:true,
   body:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Freezed Products',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800,color:AppColors.brand)),const SizedBox(height:16),
    Expanded(child:BlocConsumer<FreezedProductsBloc,FreezedProductsState>(listener:(context,state){
      if(state is FreezedProductsError){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(state.message)));
      } else if(state is FreezedProductsLoaded && state.lastUnfreezedStockCode != null){
        final stockCode = state.lastUnfreezedStockCode!;
        const unfrozen = FreezedProductStatus();
        context.read<ProductSearchBloc>().add(UpdateProductFreezeStatus(stockCode, unfrozen));
        context.read<BucketSimilarProductsBloc>().add(UpdateBucketProductFreezeStatus(stockCode, unfrozen));
      }
    },builder:(context,state){
      if(state is FreezedProductsLoading||state is FreezedProductsInitial)return const Center(child:CircularProgressIndicator());
      if(state is! FreezedProductsLoaded||state.products.isEmpty)return const Center(child:Text('No freezed products found'));
      final width=MediaQuery.of(context).size.width;final count=width>=900?4:width>=600?3:2;
      return GridView.builder(gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:count,crossAxisSpacing:14,mainAxisSpacing:14,childAspectRatio:.82),itemCount:state.products.length,itemBuilder:(context,i){final p=state.products[i];final busy=state.updatingStockCode==p.stockCode;
       return Card(clipBehavior:Clip.antiAlias,child:Column(children:[Expanded(child:CachedNetworkImage(imageUrl:p.productImage,width:double.infinity,fit:BoxFit.cover,errorWidget:(_,__,___)=>const Icon(Icons.broken_image))),Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text(p.stockCode,style:const TextStyle(fontWeight:FontWeight.w800)),Text('${p.lob} • ${p.category}',maxLines:1,overflow:TextOverflow.ellipsis),const SizedBox(height:8),ElevatedButton.icon(onPressed:busy?null:()=>context.read<FreezedProductsBloc>().add(UnfreezeProductRequested(auth.user.id,p.stockCode)),icon:busy?const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.ac_unit),label:const Text('UNFREEZE'))]))]));
      });
    }))
   ])));
 }
}
