import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:manubhaimlt/features/auth/data/models/auth_user_model.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/bucket_similar_products_screen.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/customer_review_screen.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/freezed_products_screen.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/product_grid_screen.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/received_safe_screen.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/requested_stock_list_screen.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/safe_keeper_request_detail_screen.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/similar_products_screen.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/receivedSafe/received_safe_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/CSE_repo/similar_products_repository.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/received_safe_repository.dart';
import 'package:manubhaimlt/features/solishift_lg/bloc/solishift_bloc.dart';
import 'package:manubhaimlt/features/solishift_lg/data/repositories/solishift_repository.dart';
import 'package:manubhaimlt/features/solitaire/presentation/saved_orders_screen.dart';
import 'package:manubhaimlt/features/solishift_lg/presentation/solishift_lg_screen.dart';
import 'package:manubhaimlt/features/solitaire/presentation/solitaire_order_confirmed_screen.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';

import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/auth/presentation/login_screen.dart';

import '../features/mlt/dashboard/presentation/project_select_screen.dart';
import '../features/mlt/dashboard/presentation/dashboard_cse_screen.dart';
import '../features/mlt/dashboard/presentation/dashboard_store_keeper_screen.dart';



// ✅ Solitaire flow
import '../features/mlt/products/bloc/CSE/viewSimilarProducts/similar_products_bloc.dart';
import '../features/solitaire/presentation/solitaire_flow_shell.dart';
import '../features/solitaire/presentation/solitaire_step1_ring_screen.dart';
import '../features/solitaire/presentation/solitaire_step2_solitaire_screen.dart';
import '../features/solitaire/presentation/solitaire_step3_details_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
GoRouter buildRouter(AuthBloc authBloc) {

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    // --------------------
    // ✅ ROUTES
    // --------------------
    routes: [
      // -------- AUTH FLOW --------
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),

      // -------- MAIN FLOW --------
      GoRoute(
        path: '/project',
        builder: (_, __) => const ProjectSelectScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (_, __) => const ProductGridScreen(),
      ),
      GoRoute(
        path: '/solishift-lg',
        builder: (_, __) => BlocProvider(
          create: (_) => SoliShiftLgBloc(
            repository: const SoliShiftLgRepository(),
          ),
          child: const SoliShiftLgScreen(),
        ),
      ),

      // GoRoute(
      //   path: '/a',
      //   builder: (_, __) => const DashboardCSEScreen(),
      //   routes: [
      //     GoRoute(
      //       path: 'received-safe',
      //       builder: (context, state) => BlocProvider(
      //         create: (_) => ReceivedSafeBloc(
      //           ReceivedSafeRepository(
      //             baseUrl:
      //                 'https://vitazreportingservices.com/mlt_app_webservices',
      //           ),
      //         ),
      //         child: const ReceivedSafeScreen(),
      //       ),
      //     ),
      //   ],
      // ),
      GoRoute(
        path: '/a',
        builder: (_, __) => const DashboardCSEScreen(),
        routes: [
          GoRoute(
            path: 'received-safe',
            builder: (context, state) => BlocProvider.value(
              value: context.read<ReceivedSafeBloc>(),
              child: const ReceivedSafeScreen(),
            ),
          ),
          GoRoute(
            path: 'customer-review',
            builder: (context, state) => BlocProvider.value(
              value: context.read<ReceivedSafeBloc>(),
              child: const CustomerExperienceScreen(),
            ),
          ),
          GoRoute(
            path: 'requested-stock-list',
            builder: (context, state) => BlocProvider.value(
              value: context.read<CseRequestedStockListBloc>(),
              child: const RequestedStockListScreen(),
            ),
          ),
          GoRoute(
            path: 'freezed-products',
            builder: (context, state) => const FreezedProductsScreen(),
          ),
          GoRoute(
            path: 'similar-products',
             builder: (context, state) {
             final extra = state.extra as Map<String, dynamic>? ?? {};
             return BucketSimilarProductsScreen(
             selectedStockCode: extra['selectedStockCode']?.toString() ?? '',
           );
             },
          ),
          // GoRoute(
          //   path: 'similar-products',
          //   builder: (context, state) {
          //     final extra = state.extra;
          //     final data = extra is Map<String, dynamic>
          //         ? extra
          //         : <String, dynamic>{};

          //     return BlocProvider(
          //       create: (_) => SimilarProductsBloc(
          //         repository: SimilarProductsRepository(
          //           baseUrl: 'https://vitazreportingservices.com/mlt_app_webservices',
          //         ),
          //       ),
          //       child: SimilarProductsScreen(
          //         selectedStockCode:
          //             (data['selectedStockCode'] ?? '').toString(),
          //         initialFilters:
          //             (data['initialFilters'] is Map<String, dynamic>)
          //                 ? Map<String, dynamic>.from(
          //                     data['initialFilters'] as Map<String, dynamic>,
          //                   )
          //                 : <String, dynamic>{},
          //       ),
          //     );
          //   },
          // ),
        ],
      ),

      GoRoute(
        path: '/b',
        builder: (_, __) => const DashboardStoreKeeperScreen(),
      ),

      GoRoute(
        path: '/b',
        builder: (_, __) => const DashboardStoreKeeperScreen(),
        routes: [
          GoRoute(
            path: 'request-detail/:safeRequestId',
            builder: (context, state) {
              final id = state.pathParameters['safeRequestId'] ?? '';
              return BlocProvider.value(
                value: context.read<SafeKeeperRequestDetailBloc>(),
                child: SafeKeeperRequestDetailScreen(safeRequestId: id),
              );
            },
          ),
        ],
      ),

      // ✅ MJ-MLT entry route (redirects to dashboard per role)
      GoRoute(
        path: '/mjt',
        builder: (_, __) => const SizedBox.shrink(),
      ),


      // -------- SOLITAIRE FLOW --------
      ShellRoute(
        builder: (context, state, child) => SolitaireFlowShell(child: child),
        routes: [
          GoRoute(
            path: '/solitaire/step1',
            builder: (_, __) => const SolitaireStep1RingScreen(),
          ),
          GoRoute(
            path: '/solitaire/step2',
            builder: (_, __) => const SolitaireStep2SolitaireScreen(),
          ),
          GoRoute(
            path: '/solitaire/step3',
            // builder: (_, __) => SolitaireStep3DetailsScreen(),
             builder: (context, state) {

              final extra = (state.extra is Map<String, dynamic>)
                  ? (state.extra as Map<String, dynamic>)
                  : <String, dynamic>{};

              return SolitaireStep3DetailsScreen(
                cseId: (extra['cseId'] ?? '1').toString(),
              );
            },
          ),
          GoRoute(
            path: '/solitaire/step3-view/:orderId',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId'] ?? '';
              final extra = (state.extra is Map<String, dynamic>)
                  ? (state.extra as Map<String, dynamic>)
                  : <String, dynamic>{};

              return SolitaireStep3DetailsScreen(
                cseId: (extra['cseId'] ?? '1').toString(),
                viewMode: true,
                viewOrderId: orderId, // numeric
                viewOrderUniqueId:
                    extra['orderUniqueId']?.toString(), // ORD-...
              );
            },
          ),
        ],
      ),
      //  GoRoute(
      //   // path: '/solitaire/saved-orders',
      //   path: '/saved-orders',
      //   builder: (_, __) => const SavedOrdersScreen(),
      // ),
      GoRoute(
        path: '/saved-orders',
        builder: (context, state) {
          final refresh = state.uri.queryParameters['refresh'] == '1';
          return SavedOrdersScreen(forceRefresh: refresh);
        },
      ),
      GoRoute(
        path: '/solitaire/order-confirmed',
        builder: (context, state) {
          final extra = (state.extra as Map<String, dynamic>);
          return SolitaireOrderConfirmedScreen(
            orderId: extra['orderId'],
            customerName: extra['customerName'],
            phone: extra['phone'],
            stockCode: extra['stockCode'],
            selectedDiamondLabel: extra['selectedDiamondLabel'],
            diamondSpecs: extra['diamondSpecs'],
            weightDiffText: extra['weightDiffText'],
            priceDiffText: extra['priceDiffText'],
            finalTotalText: extra['finalTotalText'],
          );
        },
      ),

    ],

    // --------------------
    // ✅ REDIRECT LOGIC
    // --------------------
    redirect: (context, state) {
      final authState = authBloc.state; // ✅ use the same authBloc reference
      final loc = state.matchedLocation;

      final isSplash = loc == '/splash';
      final isWelcome = loc == '/welcome';
      final isLogin = loc == '/login';
      final isAuthPage = isSplash || isWelcome || isLogin;

      // 🔹 1. Still loading / unknown → stay on splash
      if (authState is AuthUnknown || authState is AuthLoading) {
        return isSplash ? null : '/splash';
      }

      // 🔹 2. Unauthenticated → only allow splash/welcome/login
      if (authState is AuthUnauthenticated) {
        return isAuthPage ? null : '/welcome';
      }

      // 🔹 3. Authenticated → send to appropriate screen
      if (authState is AuthAuthenticated) {
        // If they are on splash or login, push them forward
        if (isAuthPage) return '/project';

        // Force product/project selection if root
        if (loc.isEmpty || loc == '/') return '/project';

        // If navigating to /mjt, redirect based on role
        if (loc == '/mjt') {
          return authState.user.role == UserRole.cse ? '/a' : '/b';
        }

        // Everything else (like /project, /a, /b, /products) is allowed
        return null;
      }

      // 🔹 Default: stay
      return null;
    },
  );
}

/// ✅ Keeps GoRouter in sync with AuthBloc
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
