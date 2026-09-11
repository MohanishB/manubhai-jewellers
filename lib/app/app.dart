// import 'dart:async';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:go_router/go_router.dart';
// import 'package:manubhaimlt/core/services/firebase_initializer.dart';
// import 'package:manubhaimlt/core/theme/app_theme.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_event.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_event.dart';

// import 'router.dart';
// import '../features/auth/bloc/auth_bloc.dart';
// import '../features/auth/bloc/auth_state.dart';
// import '../features/mlt/products/bloc/CSE/receivedSafe/received_safe_bloc.dart';
// import '../features/mlt/products/bloc/CSE/receivedSafe/received_safe_event.dart';
// import '../features/mlt/products/bloc/store_keeper/safe_keeper_bloc.dart';
// import '../features/mlt/products/bloc/store_keeper/safe_keeper_event.dart';

// class MJMLTApp extends StatefulWidget {
//   const MJMLTApp({super.key});

//   @override
//   State<MJMLTApp> createState() => _MJMLTAppState();
// }

// class _MJMLTAppState extends State<MJMLTApp> {
//   late final GoRouter _router;
//   late final StreamSubscription<Map<String, dynamic>> _tapSub;

//   @override
//   void initState() {
//     super.initState();
//     _router = buildRouter(context.read<AuthBloc>());

//     // ✅ Listen all taps (foreground local + background system)
//     _tapSub = NotificationTapBus.stream.listen((data) {
//       _handleTapData(data);
//     });

//     // ✅ KILLED state tap (must be after UI is ready)
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final initial = await FirebaseMessaging.instance.getInitialMessage();
//       if (initial != null) {
//         print('🚀 [SYSTEM TAP - TERMINATED] Data: ${initial.data}');
//         _handleTapData(initial.data);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tapSub.cancel();
//     super.dispose();
//   }

//   void _handleTapData(Map<String, dynamic> data) async {
//     final clickUrl = (data['click_url'] ?? '').toString();

//     final authState = context.read<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) {
//       print('⚠️ [NAV] Not authenticated yet, ignoring tap');
//       return;
//     }
//     final userId = authState.user.id;


//     // ✅ accept both spellings to avoid mismatch issues
//     final isCse =
//         clickUrl == 'cse_request_out_of_safe_stock_list' ||
//         clickUrl == 'cse_request_out_from_safe_stock_list';

//     final isStoreKeeper = clickUrl == 'safe_keeper_request_received_list';

//     final isCseRequestList = clickUrl == 'cse_requested_stock_list';

//     print('🔀 [NAV] click_url=$clickUrl');

//     if (isCse) {
//       _router.go('/a');
//       await Future.delayed(const Duration(milliseconds: 450));
//       _router.push('/a/received-safe');
//       await Future.delayed(const Duration(milliseconds: 300));

//       // ✅ refresh using GLOBAL bloc
//       context.read<ReceivedSafeBloc>().add(FetchReceivedSafeList(userId));
//       print('✅ [CSE] fetch received safe fired');
//       return;
//     }

//      if (isCseRequestList) {
//       _router.go('/a');
//       await Future.delayed(const Duration(milliseconds: 450));
//       _router.push('/a/requested-stock-list');
//       await Future.delayed(const Duration(milliseconds: 300));

//       // ✅ refresh using GLOBAL bloc
//       context.read<CseRequestedStockListBloc>().add(FetchCseRequestedStockList(userId));
//       print('✅ [CSE] fetch request list fired');
//       return;
//     }

//     if (isStoreKeeper) {
//       _router.go('/b');
//       await Future.delayed(const Duration(milliseconds: 450));

//       context.read<SafeKeeperBloc>().add(FetchSafeKeeperRequests(userId));
//       print('✅ [STOREKEEPER] fetch requests fired');
//       return;
//     }

//     print('ℹ️ [NAV] Unknown click_url, no action');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listenWhen: (prev, curr) => curr is AuthUnauthenticated,
//       listener: (context, state) {
//         // ✅ LOGOUT SUCCESS -> reset filter bloc globally
//         context.read<ProductFilterBloc>().add(const ResetProductFilters());
//         print('🧹 [GLOBAL] ProductFilterBloc reset on logout');
//       },
//       child: MaterialApp.router(
//         debugShowCheckedModeBanner: false,
//         title: 'MJ-MLT',
//         theme: buildAppTheme(),
//         routerConfig: _router,
//         localizationsDelegates: const [
//           AppLocalizations.delegate,
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//         ],
//         supportedLocales: AppLocalizations.supportedLocales,
//       ),
//     );
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return MaterialApp.router(
//   //     debugShowCheckedModeBanner: false,
//   //     title: 'MJ-MLT',
//   //     theme: buildAppTheme(),
//   //     routerConfig: _router,
//   //     localizationsDelegates: const [
//   //       AppLocalizations.delegate,
//   //       GlobalMaterialLocalizations.delegate,
//   //       GlobalWidgetsLocalizations.delegate,
//   //       GlobalCupertinoLocalizations.delegate,
//   //     ],
//   //     supportedLocales: AppLocalizations.supportedLocales,
//   //   );
//   // }
// }

//============================================//
//============================================//
//============================================//

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/services/firebase_initializer.dart';
import 'package:manubhaimlt/core/theme/app_theme.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_event.dart';

import 'router.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/mlt/products/bloc/CSE/receivedSafe/received_safe_bloc.dart';
import '../features/mlt/products/bloc/CSE/receivedSafe/received_safe_event.dart';
import '../features/mlt/products/bloc/CSE/productSearch/product_search_bloc.dart';
import '../features/mlt/products/bloc/CSE/productSearch/product_search_event.dart';
import '../features/mlt/products/bloc/CSE/bucketSimilarProducts/bucket_similar_products_bloc.dart';
import '../features/mlt/products/bloc/CSE/bucketSimilarProducts/bucket_similar_products_event.dart';
import '../features/mlt/products/bloc/CSE/freezedProducts/freezed_products_bloc.dart';
import '../features/mlt/products/bloc/store_keeper/safe_keeper_bloc.dart';
import '../features/mlt/products/bloc/store_keeper/safe_keeper_event.dart';

class MJMLTApp extends StatefulWidget {
  const MJMLTApp({super.key});

  @override
  State<MJMLTApp> createState() => _MJMLTAppState();
}

class _MJMLTAppState extends State<MJMLTApp> with WidgetsBindingObserver {
  late final GoRouter _router;
  late final StreamSubscription<Map<String, dynamic>> _tapSub;
  late final StreamSubscription<Set<String>> _productUnfreezeSub;

  AppLifecycleState? _lastLifecycleState;
  bool _resumeLoginLogInProgress = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _lastLifecycleState = WidgetsBinding.instance.lifecycleState;

    _router = buildRouter(context.read<AuthBloc>());

    // ✅ Listen all taps (foreground local + background system)
    _tapSub = NotificationTapBus.stream.listen((data) {
      _handleTapData(data);
    });

    _productUnfreezeSub = ProductUnfreezeBus.stream.listen((stockCodes) {
      _applyProductUnfreezes(stockCodes);
    });

    // ✅ KILLED state tap (must be after UI is ready)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        print('🚀 [SYSTEM TAP - TERMINATED] Data: ${initial.data}');
        _handleTapData(initial.data);
      }
      await _syncPendingProductUnfreezes();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tapSub.cancel();
    _productUnfreezeSub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasBackgroundLike =
        _lastLifecycleState == AppLifecycleState.paused ||
        _lastLifecycleState == AppLifecycleState.inactive ||
        _lastLifecycleState == AppLifecycleState.hidden;

    final cameToForeground =
        wasBackgroundLike && state == AppLifecycleState.resumed;

    _lastLifecycleState = state;

    if (cameToForeground) {
      _sendLoginLogOnResume();
      _syncPendingProductUnfreezes();
    }
  }

  Future<void> _sendLoginLogOnResume() async {
    if (!mounted || _resumeLoginLogInProgress) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return;
    }

    final cseId = authState.user.id.toString().trim();
    final cseFirebaseId = authState.user.firebaseId.toString().trim();

    if (cseId.isEmpty) return;

    _resumeLoginLogInProgress = true;
    try {
      await context.read<AuthBloc>().firebaseLogRepo.logLogin(
            cseId: cseId,
            cseFirebaseId: cseFirebaseId,
          );
      print('📡 [CSE LOGIN LOG] sent successfully on app resume');
    } catch (e) {
      print('⚠️ [CSE LOGIN LOG] failed on app resume: $e');
    } finally {
      _resumeLoginLogInProgress = false;
    }
  }


  Future<void> _syncPendingProductUnfreezes() async {
    if (!mounted || context.read<AuthBloc>().state is! AuthAuthenticated) {
      return;
    }

    final pending = await ProductUnfreezeBus.takePending();
    if (!mounted || pending.isEmpty) return;
    _applyProductUnfreezes(pending);
  }

  void _applyProductUnfreezes(Set<String> stockCodes) {
    if (!mounted || stockCodes.isEmpty) return;

    final normalized = stockCodes
        .map((code) => code.trim())
        .where((code) => code.isNotEmpty)
        .toSet();
    if (normalized.isEmpty) return;

    context
        .read<ProductSearchBloc>()
        .add(ProductsSilentlyUnfreezed(normalized));
    context
        .read<BucketSimilarProductsBloc>()
        .add(BucketProductsSilentlyUnfreezed(normalized));
    context
        .read<FreezedProductsBloc>()
        .add(ProductsSilentlyRemovedFromFreezedList(normalized));

    print('✅ [PRODUCT UNFREEZE] applied=$normalized');
  }

  void _handleTapData(Map<String, dynamic> data) async {
    final clickUrl = (data['click_url'] ?? '').toString();

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      print('⚠️ [NAV] Not authenticated yet, ignoring tap');
      return;
    }
    final userId = authState.user.id;

    // ✅ accept both spellings to avoid mismatch issues
    final isCse =
        clickUrl == 'cse_request_out_of_safe_stock_list' ||
        clickUrl == 'cse_request_out_from_safe_stock_list';

    final isStoreKeeper = clickUrl == 'safe_keeper_request_received_list';

    final isCseRequestList = clickUrl == 'cse_requested_stock_list';

    print('🔀 [NAV] click_url=$clickUrl');

    if (isCse) {
      _router.go('/a');
      await Future.delayed(const Duration(milliseconds: 450));
      _router.push('/a/received-safe');
      await Future.delayed(const Duration(milliseconds: 300));

      // ✅ refresh using GLOBAL bloc
      context.read<ReceivedSafeBloc>().add(FetchReceivedSafeList(userId));
      print('✅ [CSE] fetch received safe fired');
      return;
    }

    if (isCseRequestList) {
      _router.go('/a');
      await Future.delayed(const Duration(milliseconds: 450));
      _router.push('/a/requested-stock-list');
      await Future.delayed(const Duration(milliseconds: 300));

      // ✅ refresh using GLOBAL bloc
      context
          .read<CseRequestedStockListBloc>()
          .add(FetchCseRequestedStockList(userId));
      print('✅ [CSE] fetch request list fired');
      return;
    }

    if (isStoreKeeper) {
      _router.go('/b');
      await Future.delayed(const Duration(milliseconds: 450));

      context.read<SafeKeeperBloc>().add(FetchSafeKeeperRequests(userId));
      print('✅ [STOREKEEPER] fetch requests fired');
      return;
    }

    print('ℹ️ [NAV] Unknown click_url, no action');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is AuthAuthenticated || curr is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _syncPendingProductUnfreezes();
          return;
        }

        // ✅ LOGOUT SUCCESS -> reset filter bloc globally
        context.read<ProductFilterBloc>().add(const ResetProductFilters());
        print('🧹 [GLOBAL] ProductFilterBloc reset on logout');
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MJ-MLT',
        theme: buildAppTheme(),
        routerConfig: _router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}