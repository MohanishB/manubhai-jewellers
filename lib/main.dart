import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/app/app.dart';
import 'package:manubhaimlt/core/services/firebase_initializer.dart';

import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
import 'package:manubhaimlt/features/auth/data/repositories/auth_repository.dart';
import 'package:manubhaimlt/features/auth/data/repositories/firebase_log_repository.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/bucketSimilarProducts/bucket_similar_products_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/customerService/customer_experience_bloc.dart';

import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/receivedSafe/received_safe_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/receivedSafeUpdate/received_safe_update_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_bloc.dart';

import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_update_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/bucket_similar_products_repository.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/cse_requested_stock_list_repository.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/customer_experience_repository.dart';

import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/product_filter_repository.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/product_search_repository.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/request_safe_repository.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/received_safe_update_repository.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/safe_keeper_request_detail_repository.dart';

import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/received_safe_repository.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/safe_keeper_repository.dart';
import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/filter_diamonds_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/filter_options_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/save_order_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/saved_orders_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_bloc.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/save_order_repository.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/saved_orders_repository.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_confirm_order_repository.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_filter_diamonds_repository.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_filter_options_repository.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/solitaire_step3_order_summary_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();

  const baseUrl = 'https://vitazreportingservices.com/mlt_app_webservices';

  final authRepository = AuthRepository(baseUrl: baseUrl);
  final productFilterRepository = ProductFilterRepository(baseUrl: baseUrl);
  final productSearchRepository = ProductSearchRepository(baseUrl: baseUrl);
  final firebaseLogRepository = CSEFirebaseLogRepository(baseUrl: baseUrl);

  const solitaireBaseUrl =
      'https://vitazreportingservices.com/choose_jewellery/jwel_api';

  final solitaireFilterOptionsRepository =
      SolitaireFilterOptionsRepository(baseUrl: solitaireBaseUrl);
  final solitaireFilterDiamondsRepo =
      SolitaireFilterDiamondsRepository(baseUrl: solitaireBaseUrl);
  final savedOrdersRepo = SavedOrdersRepository(baseUrl: solitaireBaseUrl);
  final saveOrderRepo = SaveOrderRepository(baseUrl: solitaireBaseUrl);


  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            repository: authRepository,
            firebaseLogRepo: firebaseLogRepository,
          )..add(const AuthAppStarted()),
        ),

        BlocProvider(
          create: (_) => ProductFilterBloc(repository: productFilterRepository),
        ),

        BlocProvider(
          create: (context) {
            // keep your existing logic as-is
            return ProductSearchBloc(
              repository: productSearchRepository,
              cseId: '',
            );
          },
        ),

        BlocProvider(
          create: (_) => RequestSafeBloc(repository: RequestSafeRepository()),
        ),

        // ✅ GLOBAL: ReceivedSafeBloc (so notification handler can refresh it)
        BlocProvider(
          create: (_) => ReceivedSafeBloc(
            ReceivedSafeRepository(baseUrl: baseUrl),
          ),
        ),

        BlocProvider(
          create: (_) => CseRequestedStockListBloc(
            CseRequestedStockListRepository(
              baseUrl: baseUrl,
            ),
          ),
        ),

        BlocProvider(
          create: (_) => ReceivedSafeUpdateBloc(ReceivedSafeUpdateRepository()),
        ),

        BlocProvider(
          create: (_) => CustomerExperienceBloc(
            repo: CustomerExperienceRepository(),
          ),
        ),
        
        // ✅ GLOBAL: SafeKeeperBloc
        BlocProvider(
          create: (_) => SafeKeeperBloc(repository: SafeKeeperRepository()),
        ),

        BlocProvider(
          create: (_) => SafeKeeperUpdateBloc(SafeKeeperRepository()),
        ),
        BlocProvider(
          create: (_) => SafeKeeperRequestDetailBloc(
            repository: SafeKeeperRequestDetailRepository(baseUrl: baseUrl),
          ),
        ),
        //Solitaire
        BlocProvider(
          create: (_) => FilterOptionsBloc(
            repo: solitaireFilterOptionsRepository,
          ),
        ),
        BlocProvider(
          create: (_) => FilterDiamondsBloc(repo: solitaireFilterDiamondsRepo),
        ),
        BlocProvider(
          create: (_) => Step3OrderSummaryBloc(
            repo: SolitaireStep3OrderSummaryRepository(
              baseUrl: solitaireBaseUrl,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => ConfirmOrderBloc(
            repo: SolitaireConfirmOrderRepository(
              baseUrl: solitaireBaseUrl,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => SavedOrdersBloc(savedOrdersRepo),
        ),
        BlocProvider(
          create: (_) => SaveOrderBloc(repo: saveOrderRepo),
        ),
        BlocProvider(
         create: (_) => BucketSimilarProductsBloc(
         repository: BucketSimilarProductsRepository(),
  ),
),
      ],
      child: const MJMLTApp(),
    ),
  );
}
