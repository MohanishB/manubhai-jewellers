import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/core/widgets/mj_dropdown_field.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_state.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../products/bloc/CSE/viewSimilarProducts/similar_products_bloc.dart';
import '../../products/bloc/CSE/viewSimilarProducts/similar_products_event.dart';
import '../../products/bloc/CSE/viewSimilarProducts/similar_products_state.dart';

class SimilarProductsScreen extends StatefulWidget {
  final String selectedStockCode;
  final Map<String, dynamic> initialFilters;

  const SimilarProductsScreen({
    super.key,
    required this.selectedStockCode,
    this.initialFilters = const {},
  });

  @override
  State<SimilarProductsScreen> createState() => _SimilarProductsScreenState();
}

class _SimilarProductsScreenState extends State<SimilarProductsScreen> {
  static const _mjPrimaryBlue = Color(0xFF1E5AA8);

  final Set<String> _selectedIds = {};
  final ScrollController _gridScrollCtrl = ScrollController();

  int _gridChoice = 3;
  bool _isAtGridBottom = true;
  int? _pendingScrollToFirstNewIndex;
  int _lastLoadedCount = 0;
  double _gridWidth = 0;

  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    _gridScrollCtrl.addListener(_onGridScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<SimilarProductsBloc>().add(
              LoadSimilarProducts(
                cseId: authState.user.id,
                stockCode: widget.selectedStockCode,
                filters: widget.initialFilters,
              ),
            );
      }
    });
  }

  @override
  void dispose() {
    _gridScrollCtrl.removeListener(_onGridScroll);
    _gridScrollCtrl.dispose();
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  void _onGridScroll() {
    if (!_gridScrollCtrl.hasClients) return;

    final pos = _gridScrollCtrl.position;
    final atBottom =
        (pos.maxScrollExtent <= 0) || (pos.pixels >= (pos.maxScrollExtent - 12));

    if (atBottom != _isAtGridBottom && mounted) {
      setState(() => _isAtGridBottom = atBottom);
    }
  }

  void _reloadSimilarProducts() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<SimilarProductsBloc>().add(
          LoadSimilarProducts(
            cseId: authState.user.id,
            stockCode: widget.selectedStockCode,
            filters: widget.initialFilters,
          ),
        );
  }

  void _handleRequestSafe() {
    if (_selectedIds.isEmpty) {
      showMJAlertDialog(
        context,
        title: "No Products Selected",
        message: "Please select at least one product to request from safe.",
        primaryButtonText: "OK",
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final requestBloc = context.read<RequestSafeBloc>();

    requestBloc.add(
      SubmitRequestSafe(
        cseId: authState.user.id,
        stockList: _selectedIds.toList(),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocConsumer<RequestSafeBloc, RequestSafeState>(
        listener: (context, state) {
          if (state is RequestSafeSuccess) {
            Navigator.pop(context);

            setState(() => _selectedIds.clear());
            _reloadSimilarProducts();

            showMJAlertDialog(
              context,
              title: "Success",
              message: "Stock requested successfully! Product list refreshed.",
              primaryButtonText: "OK",
            );
          } else if (state is RequestSafeError) {
            Navigator.pop(context);
            showMJAlertDialog(
              context,
              title: "Error",
              message: state.message,
              primaryButtonText: "OK",
            );
          }
        },
        builder: (context, state) {
          if (state is RequestSafeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStockCodeChip() {
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF6),
        border: Border.all(color: _mjPrimaryBlue, width: 0.2),
      ),
      child: Text(
        'Selected Stock Code: ${widget.selectedStockCode}',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: _mjPrimaryBlue,
        ),
      ),
    );
  }

  Widget _gridDropdownInline() {
    return SizedBox(
      width: 80,
      child: MJDropdownField<int>(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        value: _gridChoice,
        hintText: 'Grid',
        items: const [
          DropdownMenuItem(value: 5, child: Text('5')),
          DropdownMenuItem(value: 3, child: Text('3')),
          DropdownMenuItem(value: 2, child: Text('2')),
        ],
        onChanged: (v) {
          if (v == null) return;
          setState(() => _gridChoice = v);
          WidgetsBinding.instance.addPostFrameCallback((_) => _onGridScroll());
        },
      ),
    );
  }

  Widget _topAreaTablet({required bool hasProducts}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context.pop(),
          child: const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.arrow_back, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Wrap(children: [_buildStockCodeChip()])),
        if (hasProducts) ...[
          const SizedBox(width: 12),
          _gridDropdownInline(),
        ],
      ],
    );
  }

  Widget _topAreaPhone({required bool hasProducts}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [_buildStockCodeChip()]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (hasProducts)
          Row(
            children: [
              const Spacer(),
              _gridDropdownInline(),
            ],
          ),
      ],
    );
  }

  Widget _productTile(
    ProductModel product,
    bool selected, {
    required VoidCallback onToggle,
  }) {
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
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openImageViewer(product),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _openImageViewer(product),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: Colors.black54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.stockCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      product.displayPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                    color: selected ? _mjPrimaryBlue : Colors.white,
                    border: Border.all(color: _mjPrimaryBlue),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(ProductModel product) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(28),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                    maxHeight: 620,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 5.0,
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.contain,
                              placeholder: (context, url) =>
                                  const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, color: Colors.white.withOpacity(0.15)),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.all(18),
                          color: Colors.black.withOpacity(0.88),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.stockCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product.displayPrice,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Expanded(
                                child: product.imagePopupData.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No details available',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        itemCount: product.imagePopupData.length,
                                        separatorBuilder: (_, __) => Divider(
                                          color: Colors.white.withOpacity(0.12),
                                          height: 18,
                                        ),
                                        itemBuilder: (context, index) {
                                          final item = product.imagePopupData[index];
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  item.label,
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  item.value,
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthUnauthenticated,
      listener: (context, state) {
        context.read<SimilarProductsBloc>().add(const ResetSimilarProducts());
      },
      child: Builder(
        builder: (context) {
          final authState = context.watch<AuthBloc>().state;
          if (authState is! AuthAuthenticated) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final auth = authState;

          return BlocConsumer<SimilarProductsBloc, SimilarProductsState>(
            listener: (context, state) {
              if (state is SimilarProductsError) {
                showMJAlertDialog(
                  context,
                  title: "Error",
                  message: state.message,
                  primaryButtonText: 'OK',
                );
              }

              if (state is SimilarProductsLoaded &&
                  _pendingScrollToFirstNewIndex != null &&
                  state.products.length > _lastLoadedCount) {
                final firstNewIndex = _pendingScrollToFirstNewIndex!;
                _pendingScrollToFirstNewIndex = null;

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!mounted) return;
                  if (!_gridScrollCtrl.hasClients) return;

                  final pos = _gridScrollCtrl.position;
                  final crossAxisCount = _gridChoice;
                  final gridW = _gridWidth > 0 ? _gridWidth : pos.viewportDimension;

                  const crossAxisSpacing = 14.0;
                  const mainAxisSpacing = 14.0;
                  const childAspectRatio = 0.9;

                  final itemW =
                      (gridW - (crossAxisCount - 1) * crossAxisSpacing) /
                          crossAxisCount;
                  final itemH = itemW / childAspectRatio;
                  final rowExtent = itemH + mainAxisSpacing;

                  final rowIndex = firstNewIndex ~/ crossAxisCount;
                  final target =
                      (rowIndex * rowExtent).clamp(0.0, pos.maxScrollExtent);

                  await _gridScrollCtrl.animateTo(
                    target,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                  );
                });
              }

              if (state is SimilarProductsLoaded) {
                _lastLoadedCount = state.products.length;
                WidgetsBinding.instance.addPostFrameCallback((_) => _onGridScroll());
              }
            },
            builder: (context, state) {
              final hasProducts =
                  state is SimilarProductsLoaded && state.products.isNotEmpty;

              return MJScaffold(
                username: auth.user.firstName,
                onLogout: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                requestSafeCount: _selectedIds.length,
                receivedSafeCount: 0,
                onRequestSafe: _handleRequestSafe,
                onRequestedList: () {
                  if (GoRouterState.of(context).uri.toString() ==
                      '/a/requested-stock-list') return;
                  // context.pushReplacement('/a/requested-stock-list');
                  context.push('/a/requested-stock-list');
                },
                onReceivedSafe: () {
                  if (GoRouterState.of(context).uri.toString() ==
                      '/a/received-safe') return;
                  // context.pushReplacement('/a/received-safe');
                   context.push('/a/received-safe');
                },
                onCustomerExperience: () {
                  if (GoRouterState.of(context).uri.toString() ==
                      '/a/customer-review') return;
                  // context.pushReplacement('/a/customer-review');
                   context.push('/a/customer-review');
                },                body: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isTablet)
                        _topAreaTablet(hasProducts: hasProducts)
                      else
                        _topAreaPhone(hasProducts: hasProducts),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (state is SimilarProductsInitial) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is SimilarProductsLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is SimilarProductsError) {
                              return const Center(
                                child: Text(
                                  "Unable to load similar products",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            } else if (state is SimilarProductsLoaded) {
                              if (state.products.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No similar products found",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }

                              final canLoadMore =
                                  state.products.length < state.totalFound;

                              return Column(
                                children: [
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, c) {
                                        if (_gridWidth != c.maxWidth) {
                                          _gridWidth = c.maxWidth;
                                        }

                                        return GridView.builder(
                                          controller: _gridScrollCtrl,
                                          key: const PageStorageKey(
                                            'similarProductGrid',
                                          ),
                                          cacheExtent: 800,
                                          itemCount: state.products.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: _gridChoice,
                                            mainAxisSpacing: 14,
                                            crossAxisSpacing: 14,
                                            childAspectRatio: 0.9,
                                          ),
                                          itemBuilder: (context, index) {
                                            final p = state.products[index];
                                            final selected = _selectedIds
                                                .contains(p.stockCode);

                                            return KeyedSubtree(
                                              key: ValueKey(p.stockId),
                                              child: _productTile(
                                                p,
                                                selected,
                                                onToggle: () {
                                                  if (selected) {
                                                    setState(() => _selectedIds
                                                        .remove(p.stockCode));
                                                    return;
                                                  }

                                                  if (_selectedIds.length >=
                                                      state.maxSafeCount) {
                                                    showMJAlertDialog(
                                                      context,
                                                      title:
                                                          "Selection Limit Reached",
                                                      message:
                                                          "You can select maximum ${state.maxSafeCount} products.",
                                                      primaryButtonText: "OK",
                                                    );
                                                    return;
                                                  }

                                                  setState(() => _selectedIds
                                                      .add(p.stockCode));
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  if (canLoadMore)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: SizedBox(
                                        height: 48,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: IgnorePointer(
                                            ignoring: !_isAtGridBottom,
                                            child: AnimatedOpacity(
                                              opacity: _isAtGridBottom ? 1 : 0,
                                              duration:
                                                  const Duration(milliseconds: 140),
                                              child: SizedBox(
                                                width: 280,
                                                child: MJPrimaryButton(
                                                  text:
                                                      "Load More (${state.products.length}/${state.totalFound})",
                                                  onPressed: () {
                                                    final loadedCount =
                                                        state.products.length;

                                                    _pendingScrollToFirstNewIndex =
                                                        loadedCount;
                                                    _lastLoadedCount = loadedCount;

                                                    final nextCount =
                                                        (loadedCount +
                                                                state.loadCount)
                                                            .clamp(
                                                              0,
                                                              state.totalFound,
                                                            );

                                                    final newProducts = state
                                                        .allProducts
                                                        .take(nextCount)
                                                        .toList();

                                                    context
                                                        .read<SimilarProductsBloc>()
                                                        .add(
                                                          UpdateLoadedSimilarProducts(
                                                            newProducts,
                                                          ),
                                                        );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
        },
      ),
    );
  }
}
