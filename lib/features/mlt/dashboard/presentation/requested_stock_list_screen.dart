import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestedList/cse_requested_stock_list_state.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/cse_requested_stock_list_model.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';



class RequestedStockListScreen extends StatefulWidget {
  const RequestedStockListScreen({super.key});

  @override
  State<RequestedStockListScreen> createState() =>
      _RequestedStockListScreenState();
}

class _RequestedStockListScreenState extends State<RequestedStockListScreen> {
  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();

    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context
          .read<CseRequestedStockListBloc>()
          .add(FetchCseRequestedStockList(auth.user.id));
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

    return MJScaffold(
      username: auth.user.firstName,
      onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
      requestSafeCount: 0,
      receivedSafeCount: 0,
      onRequestSafe: () {},
      // onRequestedList: () => {},
      // onReceivedSafe: () => context.push('/a/received-safe'),
      showHome: true,
      showBack: true,
      // onCustomerExperience: () => context.push('/a/customer-review'),
      onRequestedList: () {
     if (GoRouterState.of(context).uri.toString() ==
            '/a/requested-stock-list') return;
        context.pushReplacement('/a/requested-stock-list');
      },

      onReceivedSafe: () {
        if (GoRouterState.of(context).uri.toString() == '/a/received-safe')
          return;
        context.pushReplacement('/a/received-safe');
      },

      onCustomerExperience: () {
        if (GoRouterState.of(context).uri.toString() == '/a/customer-review')
          return;
        context.pushReplacement('/a/customer-review');
      },

      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: BlocConsumer<CseRequestedStockListBloc, CseRequestedStockListState>(
          listener: (context, state) {
            if (state is CseRequestedStockListError) {
              showMJAlertDialog(
                context,
                title: "Error",
                message: state.message,
                primaryButtonText: "OK",
              );
            }
          },
          builder: (context, state) {
            if (state is CseRequestedStockListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CseRequestedStockListError) {
              return const Center(
                child: Text(
                  "Could not load requested stock list.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              );
            }

            if (state is CseRequestedStockListLoaded) {
              if (state.groups.isEmpty) {
                return const Center(
                  child: Text(
                    "No requested stocks found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   '${state.totalProduct} Total Products',
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w800,
                  //   ),
                  // ),
                   Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${state.totalProduct} Total Products',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      MJPrimaryButton(
                        text: 'Go Back',
                        height: 36, // tweak if you want
                        width: 120, // tweak if you want
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.groups.length,
                      separatorBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      itemBuilder: (context, i) {
                        return _groupSection(context, state.groups[i]);
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text(
                "Loading...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _groupSection(BuildContext context, CseRequestedStockGroup g) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                'Request #${g.safeRequestId}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              g.timeSince,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: g.stockList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isPhone ? 3 : 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isPhone ? 0.78 : 0.88,
          ),
          itemBuilder: (context, i) {
            final item = g.stockList[i];
            return _stockTile(item);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _stockTile(CseRequestedStockItem item) {
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
              child: CachedNetworkImage(
                imageUrl: item.productImage,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (_, __, ___) =>
                    const Center(child: Icon(Icons.broken_image)),
              ),
            ),

            // Zoom icon
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _openImageViewer(item.productImage),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                ),
              ),
            ),

            // Bottom info (stock + statuses)
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.all(6),
                color: Colors.black54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.stockCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SK: ${item.safeKeeperStockStatus}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    //Comment CSE status display as per new design
                    // Text(
                    //   'CSE: ${item.cseStockStatus}',
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: const TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 9,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
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
}
