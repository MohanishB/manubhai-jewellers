import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../products/bloc/CSE/receivedSafe/received_safe_bloc.dart';
import '../../products/bloc/CSE/receivedSafe/received_safe_event.dart';
import '../../products/bloc/CSE/receivedSafe/received_safe_state.dart';
import '../../products/bloc/CSE/receivedSafeUpdate/received_safe_update_bloc.dart';
import '../../products/bloc/CSE/receivedSafeUpdate/received_safe_update_event.dart';
import '../../products/bloc/CSE/receivedSafeUpdate/received_safe_update_state.dart';
import '../../products/data/models/CSE_models/received_safe_model.dart';

class ReceivedSafeScreen extends StatefulWidget {
  const ReceivedSafeScreen({super.key});

  @override
  State<ReceivedSafeScreen> createState() => _ReceivedSafeScreenState();
}

class _ReceivedSafeScreenState extends State<ReceivedSafeScreen> {
  final Map<String, Set<int>> _selectedByRequest = {};

  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ReceivedSafeBloc>().add(FetchReceivedSafeList(authState.user.id));
    }
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600; // ✅ Responsive threshold

    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final auth = authState;

    return MJScaffold(
      username: auth.user.firstName,
      onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
      showBack: true,
      onBackPressed: () => context.pop(),
      showHome: false,
      requestSafeCount: 0,
      receivedSafeCount: 0,
      onRequestSafe: () {},
      // onRequestedList: () => {},
      // onReceivedSafe: () {},
      // onCustomerExperience: () {},
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

      body: BlocConsumer<ReceivedSafeBloc, ReceivedSafeState>(
        listener: (context, state) {
          if (state is ReceivedSafeError) {
            showMJAlertDialog(
              context,
              title: 'Error',
              message: state.message,
              primaryButtonText: 'OK',
            );
          }
        },
        builder: (context, state) {
          if (state is ReceivedSafeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReceivedSafeLoaded) {
            final requests = state.response.productList;
            if (requests.isEmpty) {
              return const Center(
                child: Text(
                  'No received products found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final r = requests[index];
                final selectedSet = _selectedByRequest.putIfAbsent(r.safeRequestId, () => {});

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Title + Buttons Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return isPhone
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Received from Safe (${r.stockList.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MJPrimaryButton(
                                          text: "Not Received",
                                          onPressed: () => _updateStatus(context, r, selectedSet, 2),
                                          height: 40,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: MJPrimaryButton(
                                          text: "Received",
                                          onPressed: () => _updateStatus(context, r, selectedSet, 1),
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Received from Safe (${r.stockList.length})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      MJPrimaryButton(
                                        text: "Not Received",
                                        onPressed: () => _updateStatus(context, r, selectedSet, 2),
                                      ),
                                      const SizedBox(width: 10),
                                      MJPrimaryButton(
                                        text: "Received",
                                        onPressed: () => _updateStatus(context, r, selectedSet, 1),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                      },
                    ),

                    const SizedBox(height: 12),

                    // ✅ Responsive Grid Layout
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: r.stockList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isPhone ? 3 : 5, // ✅ fewer columns on phone
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: isPhone ? 0.8 : 0.9,
                      ),
                      itemBuilder: (context, i) {
                        final p = r.stockList[i];
                        final selected = selectedSet.contains(i);

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
                                    imageUrl: p.productImage,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        const Center(child: Icon(Icons.broken_image)),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => _openImageViewer(p),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(Icons.zoom_in,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 6,
                                  bottom: 6,
                                  child: Container(
                                    color: Colors.black54,
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      p.stockCode,
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
                                    onTap: () {
                                      setState(() {
                                        if (selected) {
                                          selectedSet.remove(i);
                                        } else {
                                          selectedSet.add(i);
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFF1E5AA8)
                                            : Colors.white,
                                        border:
                                            Border.all(color: const Color(0xFF1E5AA8)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: selected
                                          ? const Icon(Icons.check,
                                              size: 14, color: Colors.white)
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _updateStatus(
      BuildContext context, dynamic request, Set<int> selectedSet, int status) {
    if (selectedSet.isEmpty) {
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

    final cseId = authState.user.id;
    final stockCodes =
        selectedSet.map<String>((i) => request.stockList[i].stockCode).toList();

    final parentContext = context;

    context.read<ReceivedSafeUpdateBloc>().add(
          UpdateReceivedSafeStatus(
            cseId: cseId,
            safeRequestId: request.safeRequestId,
            stockList: stockCodes,
            status: status,
          ),
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocConsumer<ReceivedSafeUpdateBloc, ReceivedSafeUpdateState>(
        listener: (dialogContext, state) {
          if (state is ReceivedSafeUpdateSuccess) {
            Navigator.pop(dialogContext);
            showMJAlertDialog(
              parentContext,
              title: "Success",
              message: "Status updated successfully!",
              primaryButtonText: "OK",
              onPrimaryPressed: () {
                parentContext
                    .read<ReceivedSafeBloc>()
                    .add(FetchReceivedSafeList(cseId));
                setState(() => selectedSet.clear());
              },
            );
          } else if (state is ReceivedSafeUpdateError) {
            Navigator.pop(dialogContext);
            showMJAlertDialog(
              parentContext,
              title: "Error",
              message: state.message,
              primaryButtonText: "OK",
            );
          }
        },
        builder: (context, state) {
          if (state is ReceivedSafeUpdateLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openImageViewer(ReceivedSafeProduct product) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Center(
                  child: Hero(
                    tag: product.stockCode,
                    child: CachedNetworkImage(
                      imageUrl: product.productImage,
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          const CircularProgressIndicator(),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.white),
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
      ),
    );
  }
}
