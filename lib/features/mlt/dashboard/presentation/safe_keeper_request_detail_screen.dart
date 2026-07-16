// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
// import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
// import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_event.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_event.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_state.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_update_bloc.dart';
// import 'package:screen_protector/screen_protector.dart';
// import '../../../auth/bloc/auth_bloc.dart';
// import '../../../auth/bloc/auth_event.dart';
// import '../../../auth/bloc/auth_state.dart';

// class SafeKeeperRequestDetailScreen extends StatefulWidget {
//   final String safeRequestId;
//   const SafeKeeperRequestDetailScreen({super.key, required this.safeRequestId});

//   @override
//   State<SafeKeeperRequestDetailScreen> createState() =>
//       _SafeKeeperRequestDetailScreenState();
// }

// class _SafeKeeperRequestDetailScreenState
//     extends State<SafeKeeperRequestDetailScreen> {
//   final Set<int> _selected = <int>{};

//   @override
//   void initState() {
//     super.initState();
//     ScreenProtector.preventScreenshotOn();

//     final authState = context.read<AuthBloc>().state;
//     if (authState is AuthAuthenticated) {
//       context.read<SafeKeeperRequestDetailBloc>().add(
//             FetchSafeKeeperRequestDetail(
//               cseId: authState.user.id,
//               safeRequestId: widget.safeRequestId,
//             ),
//           );
//     }
//   }

//   @override
//   void dispose() {
//     ScreenProtector.preventScreenshotOff();
//     super.dispose();
//   }

//   void _updateStatus({
//     required String safeRequestId,
//     required List<String> stockCodes,
//     required int status, // 1 dispatched, 2 can't find
//   }) {
//     if (stockCodes.isEmpty) {
//       showMJAlertDialog(
//         context,
//         title: "No Products Selected",
//         message: "Please select at least one product.",
//         primaryButtonText: "OK",
//       );
//       return;
//     }

//     final authState = context.read<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) return;

//     context.read<SafeKeeperUpdateBloc>().add(
//           UpdateSafeKeeperStatus(
//             cseId: authState.user.id,
//             safeRequestId: safeRequestId,
//             stockList: stockCodes,
//             status: status,
//           ),
//         );

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => BlocConsumer<SafeKeeperUpdateBloc, SafeKeeperUpdateState>(
//         listener: (context, st) {
//           if (st is SafeKeeperUpdateSuccess) {
//             Navigator.pop(context);

//             // refresh detail + clear selection
//             setState(() => _selected.clear());

//             final auth = context.read<AuthBloc>().state;
//             if (auth is AuthAuthenticated) {
//               context.read<SafeKeeperRequestDetailBloc>().add(
//                     FetchSafeKeeperRequestDetail(
//                       cseId: auth.user.id,
//                       safeRequestId: widget.safeRequestId,
//                     ),
//                   );
//             }
//           } else if (st is SafeKeeperUpdateError) {
//             Navigator.pop(context);
//             showMJAlertDialog(
//               context,
//               title: "Error",
//               message: st.message,
//               primaryButtonText: "OK",
//             );
//           }
//         },
//         builder: (context, st) {
//           if (st is SafeKeeperUpdateLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = context.watch<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return MJScaffold(
//       username: authState.user.firstName,
//       onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
//       showHome: true,
//       showBack: true,
//       requestSafeCount: 0,
//       receivedSafeCount: 0,
//       onRequestSafe: () {},
//       onRequestedList: () => {},
//       onReceivedSafe: () {},
//       onCustomerExperience: () {},
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//         child: BlocConsumer<SafeKeeperRequestDetailBloc,
//             SafeKeeperRequestDetailState>(
//           listener: (context, state) {
//             if (state is SafeKeeperRequestDetailError) {
//               showMJAlertDialog(
//                 context,
//                 title: "Error",
//                 message: state.message,
//                 primaryButtonText: "OK",
//               );
//             }
//           },
//           builder: (context, state) {
//             if (state is SafeKeeperRequestDetailLoading ||
//                 state is SafeKeeperRequestDetailInitial) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (state is SafeKeeperRequestDetailError) {
//               return const Center(
//                 child: Text(
//                   "Could not load details. Please try again.",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black54,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               );
//             }

//             final loaded = state as SafeKeeperRequestDetailLoaded;
//             final req = loaded.request;

//             final screenWidth = MediaQuery.of(context).size.width;
//             final isPhone = screenWidth < 600;

//             final titleLine = RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 13, color: Colors.black87),
//                 children: [
//                   TextSpan(
//                     text: req.ssoName,
//                     style: const TextStyle(
//                       decoration: TextDecoration.underline,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const TextSpan(text: '   '),
//                   TextSpan(
//                     text: req.timeSince,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFFD32F2F),
//                     ),
//                   ),
//                 ],
//               ),
//             );

//             final selectedStockCodes =
//                 _selected.map((i) => req.stockList[i].stockCode).toList();

//             Widget buttonsRow({required bool compact}) {
//               if (compact) {
//                 return Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: MJPrimaryButton(
//                             text: "CAN'T FIND",
//                             height: 40,
//                             onPressed: () => _updateStatus(
//                               safeRequestId: req.safeRequestId,
//                               stockCodes: selectedStockCodes,
//                               status: 2,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: MJPrimaryButton(
//                             text: "DISPATCHED",
//                             height: 40,
//                             onPressed: () => _updateStatus(
//                               safeRequestId: req.safeRequestId,
//                               stockCodes: selectedStockCodes,
//                               status: 1,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     MJPrimaryButton(
//                       text: "DISCARD",
//                       height: 40,
//                       onPressed: () {
//                         // TODO: discard action later (empty for now)
//                       },
//                     ),
//                   ],
//                 );
//               }

//               return Row(
//                 children: [
//                   Expanded(
//                     child: MJPrimaryButton(
//                       text: "CAN'T FIND",
//                       onPressed: () => _updateStatus(
//                         safeRequestId: req.safeRequestId,
//                         stockCodes: selectedStockCodes,
//                         status: 2,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: MJPrimaryButton(
//                       text: "DISPATCHED",
//                       onPressed: () => _updateStatus(
//                         safeRequestId: req.safeRequestId,
//                         stockCodes: selectedStockCodes,
//                         status: 1,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: MJPrimaryButton(
//                       text: "DISCARD",
//                       onPressed: () {
//                         // TODO: discard action later (empty for now)
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             }

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // title + buttons (same logic as old, but single request)
//                 if (isPhone) ...[
//                   titleLine,
//                   const SizedBox(height: 8),
//                   buttonsRow(compact: true),
//                 ] else ...[
//                   Row(
//                     children: [
//                       Expanded(child: titleLine),
//                       const SizedBox(width: 10),
//                       SizedBox(width: 460, child: buttonsRow(compact: false)),
//                     ],
//                   ),
//                 ],

//                 const SizedBox(height: 10),
//                 const Divider(height: 1),
//                 const SizedBox(height: 10),

//                 Expanded(
//                   child: GridView.builder(
//                     itemCount: req.stockList.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: isPhone ? 3 : 5,
//                       mainAxisSpacing: 12,
//                       crossAxisSpacing: 12,
//                       childAspectRatio: isPhone ? 0.8 : 0.9,
//                     ),
//                     itemBuilder: (context, i) {
//                       final item = req.stockList[i];
//                       final selected = _selected.contains(i);

//                       return _productTile(
//                         id: i,
//                         imageUrl: item.productImage,
//                         stockCode: item.stockCode,
//                         selected: selected,
//                         onToggle: () {
//                           setState(() {
//                             if (selected) {
//                               _selected.remove(i);
//                             } else {
//                               _selected.add(i);
//                             }
//                           });
//                         },
//                         onOpen: () => _openImageViewer(
//                           id: i,
//                           imageUrl: item.productImage,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _productTile({
//     required int id,
//     required String imageUrl,
//     required String stockCode,
//     required bool selected,
//     required VoidCallback onToggle,
//     required VoidCallback onOpen,
//   }) {
//     const blue = Color(0xFF1E5AA8);

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
//                 tag: 'sk_detail_$id',
//                 child: Image.network(
//                   imageUrl,
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
//                   child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
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
//                   stockCode,
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
//                 onTap: onToggle,
//                 child: Container(
//                   width: 22,
//                   height: 22,
//                   decoration: BoxDecoration(
//                     color: selected ? blue : Colors.white,
//                     borderRadius: BorderRadius.zero, // square checkbox
//                     border: Border.all(color: blue, width: 1),
//                   ),
//                   alignment: Alignment.center,
//                   child: selected
//                       ? const Icon(Icons.check, color: Colors.white, size: 14)
//                       : null,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openImageViewer({required int id, required String imageUrl}) {
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
//                       tag: 'sk_detail_$id',
//                       child: Image.network(
//                         imageUrl,
//                         fit: BoxFit.contain,
//                         errorBuilder: (_, __, ___) =>
//                             const Icon(Icons.broken_image, color: Colors.white54),
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

//==============================================================//
//==============================================================//
//==============================================================//

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/widgets/bottom_pill_bar.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_request_detail_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/store_keeper/safe_keeper_update_bloc.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';

class SafeKeeperRequestDetailScreen extends StatefulWidget {
  final String safeRequestId;
  const SafeKeeperRequestDetailScreen({super.key, required this.safeRequestId});

  @override
  State<SafeKeeperRequestDetailScreen> createState() =>
      _SafeKeeperRequestDetailScreenState();
}

class _SafeKeeperRequestDetailScreenState
    extends State<SafeKeeperRequestDetailScreen> {
  final Set<int> _selected = <int>{};

  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    _fetchDetail();
  }

  void _fetchDetail() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SafeKeeperRequestDetailBloc>().add(
            FetchSafeKeeperRequestDetail(
              cseId: authState.user.id,
              safeRequestId: widget.safeRequestId,
            ),
          );
    }
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  void _refreshListAndPop() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<SafeKeeperBloc>().add(FetchSafeKeeperRequests(auth.user.id));
    }
    if (context.canPop()) context.pop();
  }

  void _updateStatus({
    required String safeRequestId,
    required List<String> stockCodes,
    required int status, // 1 dispatched, 2 can't find, 3 discard
  }) {
    if (stockCodes.isEmpty) {
      showMJAlertDialog(
        context,
        title: "No Products Selected",
        message: "Please select at least one product.",
        primaryButtonText: "OK",
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<SafeKeeperUpdateBloc>().add(
          UpdateSafeKeeperStatus(
            cseId: authState.user.id,
            safeRequestId: safeRequestId,
            stockList: stockCodes,
            status: status,
          ),
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocConsumer<SafeKeeperUpdateBloc, SafeKeeperUpdateState>(
        listener: (context, st) {
          if (st is SafeKeeperUpdateSuccess) {
            Navigator.pop(context);

            // refresh detail + clear selection
            setState(() => _selected.clear());
            _fetchDetail();
          } else if (st is SafeKeeperUpdateError) {
            Navigator.pop(context);
            showMJAlertDialog(
              context,
              title: "Error",
              message: st.message,
              primaryButtonText: "OK",
            );
          }
        },
        builder: (context, st) {
          if (st is SafeKeeperUpdateLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MJScaffold(
      bottomMode: BottomPillBarMode.storeKeeper,
      username: authState.user.firstName,
      onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
      showHome: true,
      showBack: true,
      requestSafeCount: 1,
      receivedSafeCount: 0,
      onRequestSafe: () {},
      onRequestedList: () => {},
      onReceivedSafe: () {},
      onBackPressed: _refreshListAndPop,
      onCustomerExperience: () {},
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: BlocConsumer<SafeKeeperRequestDetailBloc,
            SafeKeeperRequestDetailState>(
          listener: (context, state) async {
            // ✅ real errors only
            if (state is SafeKeeperRequestDetailError) {
              showMJAlertDialog(
                context,
                title: "Error",
                message: state.message,
                primaryButtonText: "OK",
              );
              return;
            }

            // ✅ NOT an error: request completed / no pending items
            if (state is SafeKeeperRequestDetailCompleted) {
              // show friendly dialog, then go back + refresh list
              await showMJAlertDialog(
                context,
                title: "Request Completed",
                message: state.message,
                primaryButtonText: "OK",
              );

              if (!mounted) return;
              _refreshListAndPop();
            }
          },
          builder: (context, state) {
            if (state is SafeKeeperRequestDetailLoading ||
                state is SafeKeeperRequestDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // ✅ completed: we are going to pop after OK (listener),
            // but keep safe UI in case build happens before pop.
            if (state is SafeKeeperRequestDetailCompleted) {
              return const Center(
                child: Text(
                  "This request is completed.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            if (state is SafeKeeperRequestDetailError) {
              return const Center(
                child: Text(
                  "Could not load details. Please try again.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            // ✅ only cast when loaded
            final loaded = state as SafeKeeperRequestDetailLoaded;
            final req = loaded.request;

            final screenWidth = MediaQuery.of(context).size.width;
            final isPhone = screenWidth < 600;

            final titleLine = RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: req.ssoName,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '   '),
                  TextSpan(
                    text: req.timeSince,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
            );

            final selectedStockCodes =
                _selected.map((i) => req.stockList[i].stockCode).toList();

            Widget buttonsRow({required bool compact}) {
              if (compact) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MJPrimaryButton(
                            text: "CAN'T FIND",
                            height: 40,
                            onPressed: () => _updateStatus(
                              safeRequestId: req.safeRequestId,
                              stockCodes: selectedStockCodes,
                              status: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MJPrimaryButton(
                            text: "DISPATCHED",
                            height: 40,
                            onPressed: () => _updateStatus(
                              safeRequestId: req.safeRequestId,
                              stockCodes: selectedStockCodes,
                              status: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// Hide DISCARD button as per new requirements
                    // const SizedBox(height: 8),
                    // MJPrimaryButton(
                    //   text: "DISCARD",
                    //   height: 40,
                    //   onPressed: () => _updateStatus(
                    //     safeRequestId: req.safeRequestId,
                    //     stockCodes: selectedStockCodes,
                    //     status: 3,
                    //   ),
                    // ),

                    const SizedBox(height: 8),
                    MJPrimaryButton(
                      text: "GO BACK",
                      height: 40,
                      onPressed: () => _refreshListAndPop()
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: MJPrimaryButton(
                      text: "CAN'T FIND",
                      onPressed: () => _updateStatus(
                        safeRequestId: req.safeRequestId,
                        stockCodes: selectedStockCodes,
                        status: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MJPrimaryButton(
                      text: "DISPATCHED",
                      onPressed: () => _updateStatus(
                        safeRequestId: req.safeRequestId,
                        stockCodes: selectedStockCodes,
                        status: 1,
                      ),
                    ),
                  ),
                   const SizedBox(width: 10),
                    Expanded(
                    child: MJPrimaryButton(
                      text: "GO BACK",
                      onPressed: () => _refreshListAndPop()
                    ),
                  ),
                  /// Hide DISCARD button as per new requirements
                  // const SizedBox(width: 10),
                  // Expanded(
                  //   child: MJPrimaryButton(
                  //     text: "DISCARD",
                  //     onPressed: () => _updateStatus(
                  //       safeRequestId: req.safeRequestId,
                  //       stockCodes: selectedStockCodes,
                  //       status: 3,
                  //     ),
                  //   ),
                  // ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + buttons (same logic as old, but single request)
                if (isPhone) ...[
                  titleLine,
                  const SizedBox(height: 8),
                  buttonsRow(compact: true),
                ] else ...[
                  Row(
                    children: [
                      Expanded(child: titleLine),
                      const SizedBox(width: 10),
                      SizedBox(width: 460, child: buttonsRow(compact: false)),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    itemCount: req.stockList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isPhone ? 3 : 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isPhone ? 0.8 : 0.9,
                    ),
                    itemBuilder: (context, i) {
                      final item = req.stockList[i];
                      final selected = _selected.contains(i);

                      return _productTile(
                        id: i,
                        imageUrl: item.productImage,
                        stockCode: item.stockCode,
                        selected: selected,
                        onToggle: () {
                          setState(() {
                            if (selected) {
                              _selected.remove(i);
                            } else {
                              _selected.add(i);
                            }
                          });
                        },
                        onOpen: () => _openImageViewer(
                          id: i,
                          imageUrl: item.productImage,
                          stockCode : item.stockCode,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _productTile({
    required int id,
    required String imageUrl,
    required String stockCode,
    required bool selected,
    required VoidCallback onToggle,
    required VoidCallback onOpen,
  }) {
    const blue = Color(0xFF1E5AA8);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: 'sk_detail_$id',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onOpen,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: Colors.black54,
                child: Text(
                  stockCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? blue : Colors.white,
                    borderRadius: BorderRadius.zero, // square checkbox
                    border: Border.all(color: blue, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer({
    required int id,
    required String imageUrl,
    required String stockCode,
  }) {
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
                      tag: 'sk_detail_$id',
                      child: Image.network(
                        imageUrl,
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
                      stockCode,
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

  // void _openImageViewer({required int id, required String imageUrl, required String stockCode}) {
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
  //                     tag: 'sk_detail_$id',
  //                     child: Image.network(
  //                       imageUrl,
  //                       fit: BoxFit.contain,
  //                       errorBuilder: (_, __, ___) => const Icon(
  //                         Icons.broken_image,
  //                         color: Colors.white54,
  //                       ),
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
