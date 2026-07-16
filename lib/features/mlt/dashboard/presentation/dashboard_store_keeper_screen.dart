// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:go_router/go_router.dart';
// import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
// import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
// import 'package:manubhaimlt/core/widgets/bottom_pill_bar.dart';
// import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
// import 'package:manubhaimlt/features/mlt/dashboard/presentation/received_safe_screen.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/receivedSafe/received_safe_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_event.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_state.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_update_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/data/models/shop_keeper_models/safe_keeper_request_model.dart';
// import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/received_safe_repository.dart';
// import 'package:screen_protector/screen_protector.dart';
// import '../../../auth/bloc/auth_bloc.dart';
// import '../../../auth/bloc/auth_event.dart';
// import '../../../auth/bloc/auth_state.dart';

// class DashboardStoreKeeperScreen extends StatefulWidget {
//   const DashboardStoreKeeperScreen({super.key});

//   @override
//   State<DashboardStoreKeeperScreen> createState() =>
//       _DashboardStoreKeeperScreenState();
// }

// class _DashboardStoreKeeperScreenState
//     extends State<DashboardStoreKeeperScreen> {
//   final Map<String, Set<int>> _selectedByRequest = {};
//   int openRequestsCount = 0; // ✅ Track total open requests

//   @override
//   void initState() {
//     super.initState();
//     ScreenProtector.preventScreenshotOn();
//     final authState = context.read<AuthBloc>().state;
//     if (authState is AuthAuthenticated) {
//       context
//           .read<SafeKeeperBloc>()
//           .add(FetchSafeKeeperRequests(authState.user.id));
//     }
//   }

//    void dispose() {
//     ScreenProtector.preventScreenshotOff();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = context.watch<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final auth = authState;

//     return BlocBuilder<SafeKeeperBloc, SafeKeeperState>(
//       builder: (context, state) {
//         if (state is SafeKeeperLoaded) {
//           openRequestsCount = state.requests.length;
//         }

//         return MJScaffold(
//           bottomMode: BottomPillBarMode.storeKeeper,
//           username: auth.user.firstName,
//           onLogout: () =>
//               context.read<AuthBloc>().add(const AuthLogoutRequested()),

//           showHome: true,

//           // ✅ Pass request count dynamically
//           requestSafeCount: openRequestsCount,
//           receivedSafeCount: 1,
//           onRequestSafe: () {},
//           onRequestedList: () => {},
//           onReceivedSafe: () {
//             context.push(
//               '/received-safe',
//               extra: BlocProvider(
//                 create: (_) => ReceivedSafeBloc(
//                   ReceivedSafeRepository(
//                     baseUrl:
//                         'https://vitazreportingservices.com/mlt_app_webservices',
//                   ),
//                 ),
//                 child: const ReceivedSafeScreen(),
//               ),
//             );
//           },
//           onCustomerExperience: () {},

//           body: Padding(
//             padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ✅ Dynamic title with count
//                 Text(
//                   '$openRequestsCount Open Requests',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Divider(height: 1),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: BlocConsumer<SafeKeeperBloc, SafeKeeperState>(
//                     listener: (context, state) {
//                       if (state is SafeKeeperError) {
//                         showMJAlertDialog(
//                           context,
//                           title: "Error",
//                           message: state.message,
//                           primaryButtonText: "OK",
//                         );
//                       }
//                     },
//                     builder: (context, state) {
//                       if (state is SafeKeeperInitial) {
//                         return const Center(
//                           child: Text(
//                             "Waiting for requests...",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black54,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         );
//                       } else if (state is SafeKeeperLoading) {
//                         return const Center(
//                             child: CircularProgressIndicator());
//                       } else if (state is SafeKeeperError) {
//                         return const Center(
//                           child: Text(
//                             "Could not load requests. Please try again.",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black54,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         );
//                       } else if (state is SafeKeeperLoaded) {
//                         if (state.requests.isEmpty) {
//                           return const Center(
//                             child: Text(
//                               "No open requests available",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black54,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           );
//                         }

//                         final requests = state.requests;
//                         openRequestsCount = requests.length;

//                         return ListView.separated(
//                           itemCount: requests.length,
//                           separatorBuilder: (_, __) => const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 10),
//                             child: Divider(height: 1),
//                           ),
//                           itemBuilder: (context, index) {
//                             final r = requests[index];
//                             return _requestRow(context, request: r);
//                           },
//                         );
//                       } else {
//                         return const SizedBox.shrink();
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _requestRow(BuildContext context,
//       {required SafeKeeperRequestModel request}) {
//     final selectedSet =
//         _selectedByRequest.putIfAbsent(request.safeRequestId, () => <int>{});

//     final screenWidth = MediaQuery.of(context).size.width;
//     final isPhone = screenWidth < 600; // ✅ Define phone layout threshold

//     final titleLine = RichText(
//       text: TextSpan(
//         style: const TextStyle(fontSize: 13, color: Colors.black87),
//         children: [
//           TextSpan(
//             text: request.ssoName,
//             style: const TextStyle(
//               decoration: TextDecoration.underline,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const TextSpan(text: '   '),
//           TextSpan(
//             text: request.timeSince,
//             style: const TextStyle(
//               fontWeight: FontWeight.w700,
//               color: Color(0xFFD32F2F),
//             ),
//           ),
//         ],
//       ),
//     );

//     Widget buttonsRow(bool compact) => compact
//         ? Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: MJPrimaryButton(
//                       text: "CAN'T FIND",
//                       height: 40,
//                       onPressed: () =>
//                           _updateSelectedStatus(request, selectedSet, 2),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: MJPrimaryButton(
//                       text: "DISPATCHED",
//                       height: 40,
//                       onPressed: () =>
//                           _updateSelectedStatus(request, selectedSet, 1),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           )
//         : Row(
//             children: [
//               Expanded(
//                 child: MJPrimaryButton(
//                   text: "CAN'T FIND",
//                   onPressed: () =>
//                       _updateSelectedStatus(request, selectedSet, 2),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: MJPrimaryButton(
//                   text: "DISPATCHED",
//                   onPressed: () =>
//                       _updateSelectedStatus(request, selectedSet, 1),
//                 ),
//               ),
//             ],
//           );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ✅ Responsive Title + Buttons
//         if (isPhone) ...[
//           titleLine,
//           const SizedBox(height: 8),
//           buttonsRow(true),
//         ] else ...[
//           Row(
//             children: [
//               Expanded(child: titleLine),
//               const SizedBox(width: 10),
//               SizedBox(width: 300, child: buttonsRow(false)),
//             ],
//           ),
//         ],

//         const SizedBox(height: 10),

//         // ✅ Responsive GridView
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: request.stockList.length,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: isPhone ? 3 : 5, // ✅ fewer columns on small screens
//             mainAxisSpacing: 12,
//             crossAxisSpacing: 12,
//             childAspectRatio: isPhone ? 0.8 : 0.9,
//           ),
//           itemBuilder: (context, i) {
//             final product = request.stockList[i];
//             final selected = selectedSet.contains(i);

//             return _productTile(
//               product: _ProductVm(
//                 id: i,
//                 imageUrl: product.productImage,
//                 stockCode: product.stockCode,
//               ),
//               selected: selected,
//               dense: false,
//               onToggleSelect: () {
//                 setState(() {
//                   if (selected) {
//                     selectedSet.remove(i);
//                   } else {
//                     selectedSet.add(i);
//                   }
//                 });
//               },
//               onOpen: () => _openImageViewer(
//                 _ProductVm(
//                   id: i,
//                   imageUrl: product.productImage,
//                   stockCode: product.stockCode,
//                 ),
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }


//   void _updateSelectedStatus(
//       SafeKeeperRequestModel request, Set<int> selectedSet, int status) {
//     if (selectedSet.isEmpty) {
//       showMJAlertDialog(
//         context,
//         title: "No Products Selected",
//         message:
//             "Please select at least one product before updating the request.",
//         primaryButtonText: "OK",
//       );
//       return;
//     }

//     final authState = context.read<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) return;

//     final cseId = authState.user.id;
//     final stockCodes =
//         selectedSet.map((i) => request.stockList[i].stockCode).toList();

//     context.read<SafeKeeperUpdateBloc>().add(
//           UpdateSafeKeeperStatus(
//             cseId: cseId,
//             safeRequestId: request.safeRequestId,
//             stockList: stockCodes,
//             status: status,
//           ),
//         );

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => BlocConsumer<SafeKeeperUpdateBloc, SafeKeeperUpdateState>(
//         listener: (context, state) {
//           if (state is SafeKeeperUpdateSuccess) {
//             Navigator.pop(context);
//             final authState = context.read<AuthBloc>().state;
//             if (authState is AuthAuthenticated) {
//               context
//                   .read<SafeKeeperBloc>()
//                   .add(FetchSafeKeeperRequests(authState.user.id));
//             }
//             setState(() => selectedSet.clear());
//           } else if (state is SafeKeeperUpdateError) {
//             Navigator.pop(context);
//             showMJAlertDialog(
//               context,
//               title: "Error",
//               message: state.message,
//               primaryButtonText: "OK",
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is SafeKeeperUpdateLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _productTile({
//     required _ProductVm product,
//     required bool selected,
//     required bool dense,
//     required VoidCallback onToggleSelect,
//     required VoidCallback onOpen,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(6),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(6),
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Hero(
//                 tag: 'product_${product.id}',
//                 child: Image.network(
//                   product.imageUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) =>
//                       const Center(child: Icon(Icons.broken_image)),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 6,
//               right: 6,
//               child: GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: onOpen,
//                 child: Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: Colors.black45,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Icon(
//                     Icons.zoom_in,
//                     color: Colors.white,
//                     size: 18,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 6,
//               bottom: 6,
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 color: Colors.black54,
//                 child: Text(
//                   product.stockCode,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               right: 6,
//               bottom: 6,
//               child: GestureDetector(
//                 onTap: onToggleSelect,
//                 child: _selectionCheckbox(selected: selected, dense: false),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _selectionCheckbox({required bool selected, required bool dense}) {
//     const blue = Color(0xFF1E5AA8);
//     const size = 22.0;
//     const iconSize = 14.0;

//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: selected ? blue : Colors.white,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: blue, width: 1),
//       ),
//       alignment: Alignment.center,
//       child: selected
//           ? const Icon(Icons.check, color: Colors.white, size: iconSize)
//           : null,
//     );
//   }

//   void _openImageViewer(_ProductVm product) {
//     showDialog(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.92),
//       builder: (_) {
//         return Dialog(
//           insetPadding: EdgeInsets.zero,
//           backgroundColor: Colors.transparent,
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: InteractiveViewer(
//                   minScale: 1.0,
//                   maxScale: 5.0,
//                   child: Center(
//                     child: Hero(
//                       tag: 'product_${product.id}',
//                       child: Image.network(
//                         product.imageUrl,
//                         fit: BoxFit.contain,
//                         errorBuilder: (_, __, ___) =>
//                             const Icon(Icons.broken_image),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 24,
//                 right: 16,
//                 child: SafeArea(
//                   child: InkWell(
//                     onTap: () => Navigator.pop(context),
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.35),
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white24),
//                       ),
//                       child: const Icon(Icons.close, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _ProductVm {
//   final int id;
//   final String imageUrl;
//   final String stockCode;

//   const _ProductVm({
//     required this.id,
//     required this.imageUrl,
//     required this.stockCode,
//   });
// }


// //=======================================//
// //=======================================//
// //=======================================//

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/core/widgets/bottom_pill_bar.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/features/mlt/dashboard/presentation/received_safe_screen.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/receivedSafe/received_safe_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_state.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/shop_keeper_models/safe_keeper_request_model.dart';
import 'package:manubhaimlt/features/mlt/products/repositories/shop_keeper_repo/received_safe_repository.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';

class DashboardStoreKeeperScreen extends StatefulWidget {
  const DashboardStoreKeeperScreen({super.key});

  @override
  State<DashboardStoreKeeperScreen> createState() =>
      _DashboardStoreKeeperScreenState();
}

class _DashboardStoreKeeperScreenState extends State<DashboardStoreKeeperScreen> {
  int openRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SafeKeeperBloc>().add(FetchSafeKeeperRequests(authState.user.id));
    }
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final auth = authState;

    return BlocBuilder<SafeKeeperBloc, SafeKeeperState>(
      builder: (context, state) {
        if (state is SafeKeeperLoaded) {
          openRequestsCount = state.requests.length;
        }

        return MJScaffold(
          bottomMode: BottomPillBarMode.storeKeeper,
          username: auth.user.firstName,
          onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
          showHome: true,

          requestSafeCount: openRequestsCount,
          receivedSafeCount: 1,

          onRequestSafe: () {},

          // if your MJScaffold requires this new callback, keep it
          onRequestedList: () {},

          onReceivedSafe: () {
            context.push(
              '/received-safe',
              extra: BlocProvider(
                create: (_) => ReceivedSafeBloc(
                  ReceivedSafeRepository(
                    baseUrl: 'https://vitazreportingservices.com/mlt_app_webservices',
                  ),
                ),
                child: const ReceivedSafeScreen(),
              ),
            );
          },
          onCustomerExperience: () {},

          body: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$openRequestsCount Open Requests',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 10),

                Expanded(
                  child: BlocConsumer<SafeKeeperBloc, SafeKeeperState>(
                    listener: (context, state) {
                      if (state is SafeKeeperError) {
                        showMJAlertDialog(
                          context,
                          title: "Error",
                          message: state.message,
                          primaryButtonText: "OK",
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is SafeKeeperInitial) {
                        return const Center(
                          child: Text(
                            "Waiting for requests...",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      if (state is SafeKeeperLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is SafeKeeperError) {
                        return const Center(
                          child: Text(
                            "Could not load requests. Please try again.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      if (state is SafeKeeperLoaded) {
                        if (state.requests.isEmpty) {
                          return const Center(
                            child: Text(
                              "No open requests available",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }

                        final requests = state.requests;
                        openRequestsCount = requests.length;

                        return ListView.separated(
                          itemCount: requests.length,
                          separatorBuilder: (_, __) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1),
                          ),
                          itemBuilder: (context, index) {
                            final r = requests[index];
                            return _requestCard(context, request: r);
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _requestCard(BuildContext context, {required SafeKeeperRequestModel request}) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 600;

    // ✅ smaller true thumbnails
    final double thumb = isPhone ? 64 : 76;
    final double gap = isPhone ? 10 : 12;

    // (optional) hook for detail screen later
    void openDetails() {
      context.push('/b/request-detail/${request.safeRequestId}');
    }

    return InkWell(
      onTap: openDetails,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header with disclosure indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.ssoName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  request.timeSince,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(width: 8),

                // ✅ disclosure / detail hint
                const Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: Color(0xFF616161),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ Thumbnails (Wrap instead of GridView so they stay small)
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(request.stockList.length, (i) {
                final p = request.stockList[i];
                final vm = _ProductVm(
                  id: '${request.safeRequestId}_$i',
                  imageUrl: p.productImage,
                  stockCode: p.stockCode,
                );

                return SizedBox(
                  width: thumb,
                  height: thumb,
                  child: _thumbTile(
                    product: vm,
                    onOpen: () => _openImageViewer(vm),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbTile({
    required _ProductVm product,
    required VoidCallback onOpen,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onOpen, // ✅ tap thumbnail to zoom
              child: Hero(
                tag: 'product_${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ),

          // ✅ small zoom icon (optional, keeps UX clear)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onOpen,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),

          // ✅ stock code overlay (tight)
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: Colors.black54,
              child: Text(
                product.stockCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

   void _openImageViewer(_ProductVm product) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // ✅ Image viewer
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Center(
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ Stock code badge (always visible)
              Positioned(
                top: 24,
                left: 16,
                child: SafeArea(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      product.stockCode, // ✅ make sure _ProductVm has stockCode
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ Close button
              Positioned(
                top: 24,
                right: 16,
                child: SafeArea(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // void _openImageViewer(_ProductVm product) {
  //   showDialog(
  //     context: context,
  //     barrierColor: Colors.black.withOpacity(0.92),
  //     builder: (_) {
  //       return Dialog(
  //         insetPadding: EdgeInsets.zero,
  //         backgroundColor: Colors.transparent,
  //         child: Stack(
  //           children: [
  //             Positioned.fill(
  //               child: InteractiveViewer(
  //                 minScale: 1.0,
  //                 maxScale: 5.0,
  //                 child: Center(
  //                   child: Hero(
  //                     tag: 'product_${product.id}',
  //                     child: Image.network(
  //                       product.imageUrl,
  //                       fit: BoxFit.contain,
  //                       errorBuilder: (_, __, ___) =>
  //                           const Icon(Icons.broken_image, color: Colors.white54),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               top: 24,
  //               right: 16,
  //               child: SafeArea(
  //                 child: InkWell(
  //                   onTap: () => Navigator.pop(context),
  //                   borderRadius: BorderRadius.circular(20),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(10),
  //                     decoration: BoxDecoration(
  //                       color: Colors.black.withOpacity(0.35),
  //                       shape: BoxShape.circle,
  //                       border: Border.all(color: Colors.white24),
  //                     ),
  //                     child: const Icon(Icons.close, color: Colors.white),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

class _ProductVm {
  final String id;
  final String imageUrl;
  final String stockCode;

  const _ProductVm({
    required this.id,
    required this.imageUrl,
    required this.stockCode,
  });
}
