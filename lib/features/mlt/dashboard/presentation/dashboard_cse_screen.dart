import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/core/widgets/mj_dropdown_field.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/core/widgets/mj_search_field.dart';
import 'package:manubhaimlt/core/widgets/mj_image_zoom_control.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_state.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_sort_by_model.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_state.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../products/data/models/CSE_models/product_search_model.dart';

class DashboardCSEScreen extends StatefulWidget {
  const DashboardCSEScreen({super.key});

  @override
  State<DashboardCSEScreen> createState() => _DashboardCSEScreenState();
}

class _DashboardCSEScreenState extends State<DashboardCSEScreen> {
  static const _mjPrimaryBlue = Color(0xFF1E5AA8);

  final Set<String> _selectedIds = {};
  int _gridChoice = 3;

  String? _sortByValue;

  final ScrollController _gridScrollCtrl = ScrollController();
  final TextEditingController _stockSearchCtrl = TextEditingController();

  // ✅ Show Load More only when user reaches bottom
  bool _isAtGridBottom = true;

  // ✅ Scroll to first row of newly added items after Load More
  int? _pendingScrollToFirstNewIndex;
  int _lastLoadedCount = 0;
  double _gridWidth = 0; // measured via LayoutBuilder

  // ✅ remember appliedFilters signature so we can reset scroll on new filter results
  String _lastAppliedFiltersKey = '';

  bool _applyZoomToAll = false;
  MJImageZoomOrigin _zoomOrigin = MJImageZoomOrigin.center;
  final Set<String> _manualZoomDisabledIds = {};

  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    _gridScrollCtrl.addListener(_onGridScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncStockCodeFromState(context.read<ProductSearchBloc>().state);
    });
  }

  @override
  void dispose() {
    _gridScrollCtrl.removeListener(_onGridScroll);
    _gridScrollCtrl.dispose();
    _stockSearchCtrl.dispose();
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

  // ✅ stable encoding for map/list/set so we can compare filter changes reliably
  String _stableFiltersKey(Map<dynamic, dynamic> raw) {
    dynamic normalize(dynamic v) {
      if (v is Map) {
        final keys = v.keys.map((e) => e.toString()).toList()..sort();
        final out = SplayTreeMap<String, dynamic>();
        for (final k in keys) {
          out[k] = normalize(v[k]);
        }
        return out;
      }
      if (v is List) return v.map(normalize).toList();
      if (v is Set) {
        final list = v.map((e) => e.toString()).toList()..sort();
        return list;
      }
      return v?.toString();
    }

    final topKeys = raw.keys.map((e) => e.toString()).toList()..sort();
    final top = SplayTreeMap<String, dynamic>();
    for (final k in topKeys) {
      top[k] = normalize(raw[k]);
    }
    return jsonEncode(top);
  }

  void _resetLocalUiState() {
    if (!mounted) return;

    setState(() {
      _selectedIds.clear();
      _gridChoice = 3;
      _sortByValue = null;
      _pendingScrollToFirstNewIndex = null;
      _lastLoadedCount = 0;
      _isAtGridBottom = true;
      _gridWidth = 0;
      _lastAppliedFiltersKey = '';
      _stockSearchCtrl.clear();
      _applyZoomToAll = false;
      _zoomOrigin = MJImageZoomOrigin.center;
      _manualZoomDisabledIds.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_gridScrollCtrl.hasClients) _gridScrollCtrl.jumpTo(0);
    });
  }

  // =========================
  // ✅ CLEAR ALL (NON-MANDATORY)
  // =========================

  Set<String> _knownFilterKeysFromPf(ProductFilterLoaded pf) {
    final keys = <String>{};
    for (final f in pf.filters) {
      final post = f.postName;
      final p1 = post['para1']?.toString();
      final p2 = post['para2']?.toString();
      if (p1 != null && p1.isNotEmpty) keys.add(p1);
      if (p2 != null && p2.isNotEmpty) keys.add(p2);
    }
    return keys;
  }

  Set<String> _mandatoryKeysFromPf(ProductFilterLoaded pf) {
    final keys = <String>{};
    for (final f in pf.filters) {
      if (!f.mandatory) continue;
      final post = f.postName;
      final p1 = post['para1']?.toString();
      final p2 = post['para2']?.toString();
      if (p1 != null && p1.isNotEmpty) keys.add(p1);
      if (p2 != null && p2.isNotEmpty) keys.add(p2);
    }
    return keys;
  }

  bool _hasClearableNonMandatoryFilters(
    Map<String, dynamic> currentFilters,
    ProductFilterState pfState,
  ) {
    if (currentFilters.isEmpty) return false;

    // sort_by is always clearable
    if ((currentFilters['sort_by']?.toString() ?? '').trim().isNotEmpty) {
      return true;
    }

    if (pfState is! ProductFilterLoaded) return false;

    final known = _knownFilterKeysFromPf(pfState);
    final mandatory = _mandatoryKeysFromPf(pfState);

    for (final k in currentFilters.keys) {
      if (k.toLowerCase() == 'cse_id') continue;
      if (k == 'sort_by') continue;

      // clear only non-mandatory known filter keys
      if (known.contains(k) && !mandatory.contains(k)) {
        final v = currentFilters[k];
        final s = v?.toString().trim() ?? '';
        if (s.isNotEmpty) return true;
      }
    }
    return false;
  }

  void _clearAllNonMandatory(Map<String, dynamic> currentFilters) {
    final pfState = context.read<ProductFilterBloc>().state;

    // If we don't have filter metadata, safest is: just clear sort_by
    if (pfState is! ProductFilterLoaded) {
      final newFilters = Map<String, dynamic>.from(currentFilters)..remove('sort_by');
      setState(() => _sortByValue = null);
      _applyProductFilters(newFilters);
      return;
    }

    final known = _knownFilterKeysFromPf(pfState);
    final mandatory = _mandatoryKeysFromPf(pfState);

    final newFilters = <String, dynamic>{};

    // Preserve system keys + mandatory keys + unknown keys
    currentFilters.forEach((k, v) {
      if (k.toLowerCase() == 'cse_id') {
        newFilters[k] = v;
        return;
      }

      if (k == 'sort_by') {
        // always cleared
        return;
      }

      // If key is a known filter param: keep only if mandatory
      if (known.contains(k)) {
        if (mandatory.contains(k)) {
          newFilters[k] = v;
        }
        return;
      }

      // Unknown/system keys: keep
      newFilters[k] = v;
    });

    // reset sort dropdown immediately
    setState(() => _sortByValue = null);

    // hit API again for fresh results
    _applyProductFilters(newFilters);
  }

  Widget _clearAllChip(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _mjPrimaryBlue, width: 0.7),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Clear All',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: _mjPrimaryBlue,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.clear_all, size: 16, color: _mjPrimaryBlue),
          ],
        ),
      ),
    );
  }


  bool _hasAppliedDashboardFilters(Map<String, dynamic> filters) {
    for (final entry in filters.entries) {
      final key = entry.key.toString();
      if (key.toLowerCase() == 'cse_id' || key == '__single_stock_code') {
        continue;
      }

      final value = entry.value;
      if (value is List) {
        if (value.any((e) => e.toString().trim().isNotEmpty)) return true;
      } else if ((value?.toString().trim() ?? '').isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<String> _resolveCseId() async {
    final authState = context.read<AuthBloc>().state;
    final fromAuth = authState is AuthAuthenticated
        ? authState.user.id.trim()
        : '';

    if (fromAuth.isNotEmpty) return fromAuth;

    final fromBloc = context.read<ProductSearchBloc>().cseId.trim();
    if (fromBloc.isNotEmpty) return fromBloc;

    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('cse_id') ?? '').trim();
  }

  Future<void> _applyProductFilters(Map<String, dynamic> filters) async {
    final cseId = await _resolveCseId();
    if (!mounted) return;

    final nextFilters = Map<String, dynamic>.from(filters);
    if (cseId.isNotEmpty) {
      nextFilters['cse_id'] = cseId;
    }

    context.read<ProductSearchBloc>().add(
          ApplyFilters(nextFilters, cseId: cseId),
        );
  }


  void _syncStockCodeFromState(ProductSearchState state) {
    if (state is! ProductSearchLoaded) return;

    final stockCode =
        (state.appliedFilters['__single_stock_code'] ?? '').toString().trim();

    if (stockCode.isEmpty || _stockSearchCtrl.text == stockCode) return;

    _stockSearchCtrl.value = TextEditingValue(
      text: stockCode,
      selection: TextSelection.collapsed(offset: stockCode.length),
    );
  }

  void _startAgain() {
    FocusManager.instance.primaryFocus?.unfocus();

    _resetLocalUiState();
    context.read<ProductFilterBloc>().add(
          const SetSelectedFilters(<String, dynamic>{}),
        );
    context.read<ProductSearchBloc>().add(const ResetProductSearch());
  }

  Widget _startAgainButton({required bool isTablet}) {
    return SizedBox(
      width: isTablet ? 135 : 115,
      height: 42,
      child: MJPrimaryButton(
        text: 'Start Again',
        onPressed: _startAgain,
      ),
    );
  }

  String _productZoomKey(ProductModel product) {
    final stockId = product.stockId.trim();
    if (stockId.isNotEmpty) return stockId;
    return product.stockCode.trim();
  }

  bool _isManualZoomEnabledFor(ProductModel product) {
    return _applyZoomToAll &&
        !_manualZoomDisabledIds.contains(_productZoomKey(product));
  }

  double _gridImageScale(ProductModel product) {
    if (_applyZoomToAll) {
      if (!_isManualZoomEnabledFor(product)) {
        return 1.0;
      }

      // Manual "Apply zoom to all" mode intentionally ignores zoom_image.
      // Use the API zoom_level when it is useful; otherwise use 2x so the
      // manual zoom always has a visible effect.
      final apiZoomLevel = product.zoomLevel;
      return apiZoomLevel > 1.0 ? apiZoomLevel : 2.0;
    }

    // Default/API-driven behaviour remains unchanged.
    return product.zoomImage ? product.zoomLevel : 1.0;
  }

  Alignment _gridImageAlignment(ProductModel product) {
    if (_applyZoomToAll && _isManualZoomEnabledFor(product)) {
      return _zoomOrigin.alignment;
    }
    return Alignment.center;
  }

  Future<void> _openZoomPreference() async {
    final result = await showMJImageZoomPreferenceDialog(
      context,
      initialEnabled: _applyZoomToAll,
      initialOrigin: _zoomOrigin,
    );

    if (!mounted || result == null) return;

    setState(() {
      _applyZoomToAll = result.enabled;
      _zoomOrigin = result.origin;
      _manualZoomDisabledIds.clear();
    });
  }

  Widget _zoomPreferenceButton() {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        tooltip: _applyZoomToAll
            ? 'Image zoom: On (${_zoomOrigin.label})'
            : 'Image zoom settings',
        padding: EdgeInsets.zero,
        splashRadius: 18,
        onPressed: _openZoomPreference,
        icon: Icon(
          Icons.center_focus_strong,
          size: 22,
          color: _applyZoomToAll ? _mjPrimaryBlue : Colors.black87,
        ),
      ),
    );
  }

  Future<void> _handleSingleProductSearch() async {
     FocusManager.instance.primaryFocus?.unfocus();
    final stockCode = _stockSearchCtrl.text.trim();
    if (stockCode.isEmpty) {
      showMJAlertDialog(
        context,
        title: 'Stock Code Required',
        message: 'Please enter stock code.',
        primaryButtonText: 'OK',
      );
      return;
    }

    setState(() {
      _selectedIds.clear();
      _sortByValue = null;
      _pendingScrollToFirstNewIndex = null;
      _lastLoadedCount = 0;
    });

    final cseId = await _resolveCseId();
    if (!mounted) return;

    if (cseId.isEmpty) {
      showMJAlertDialog(
        context,
        title: 'CSE Required',
        message: 'CSE id not found. Please logout and login again.',
        primaryButtonText: 'OK',
      );
      return;
    }

    context.read<ProductSearchBloc>().add(
          SearchSingleProduct(
            stockCode,
            cseId: cseId,
          ),
        );
  }

  Widget _singleProductSearchSection({
  required bool isTablet,
  required bool showStartAgain,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 600;

      return Row(
        children: [
          if (isCompact)
            Expanded(
              child: MJSearchField(
                controller: _stockSearchCtrl,
                hintText: 'Enter stock code',
                variant: MJSearchFieldVariant.flat,
                height: 44,
                showPrefixIcon: true,
                debounceMs: 0,
                onChanged: (_) {},
                onClear: () {
                  _stockSearchCtrl.clear();
                  setState(() {});
                },
              ),
            )
          else
            SizedBox(
              width: 225,
              child: MJSearchField(
                controller: _stockSearchCtrl,
                hintText: 'Enter stock code',
                variant: MJSearchFieldVariant.flat,
                height: 44,
                showPrefixIcon: true,
                debounceMs: 0,
                onChanged: (_) {},
                onClear: () {
                  _stockSearchCtrl.clear();
                  setState(() {});
                },
              ),
            ),
          const SizedBox(width: 10),
          SizedBox(
            width: isCompact ? 88 : (isTablet ? 135 : 105),
            height: 42,
            child: MJPrimaryButton(
              text: 'Search',
              onPressed: _handleSingleProductSearch,
            ),
          ),
          if (showStartAgain) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: isCompact ? 100 : (isTablet ? 135 : 115),
              height: 42,
              child: MJPrimaryButton(
                text: 'Start Again',
                onPressed: _startAgain,
              ),
            ),
          ],
        ],
      );
    },
  );
}

  // Widget _singleProductSearchSection({required bool isTablet}) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: MJSearchField(
  //           controller: _stockSearchCtrl,
  //           hintText: 'Enter stock code',
  //           variant: MJSearchFieldVariant.flat,
  //           height: 44,
  //           showPrefixIcon: true,
  //           debounceMs: 0,
  //           onChanged: (_) {},
  //           onClear: () {
  //             _stockSearchCtrl.clear();
  //             setState(() {});
  //           },
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       SizedBox(
  //         width: isTablet ? 140 : 105,
  //         height: 44,
  //         child: MJPrimaryButton(
  //           text: 'Search',
  //           onPressed: _handleSingleProductSearch,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthUnauthenticated,
      listener: (context, state) {
        _resetLocalUiState();
        context.read<ProductSearchBloc>().add(const ResetProductSearch());
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

          return BlocConsumer<ProductSearchBloc, ProductSearchState>(
            listener: (context, state) {
              if (state is ProductSearchError) {
                showMJAlertDialog(
                  context,
                  title: "Error",
                  message: state.message,
                  primaryButtonText: 'OK',
                );
              }

              // ✅ keep dropdown in sync if appliedFilters has sort_by
              if (state is ProductSearchLoaded) {
                _syncStockCodeFromState(state);
                final appliedSort = state.appliedFilters['sort_by']?.toString();
                if ((appliedSort ?? '').isNotEmpty && appliedSort != _sortByValue) {
                  setState(() => _sortByValue = appliedSort);
                }
              }

              // ✅ If filters changed and API loaded successfully -> reset scroll to top
              if (state is ProductSearchLoaded) {
                final key = _stableFiltersKey(state.appliedFilters);
                if (key != _lastAppliedFiltersKey) {
                  if (_selectedIds.isNotEmpty && state.products.isNotEmpty) {
                    setState(() => _selectedIds.clear());
                  }

                  _lastAppliedFiltersKey = key;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    if (!_gridScrollCtrl.hasClients) return;
                    _gridScrollCtrl.jumpTo(0);
                    _onGridScroll();
                  });
                }
              }

              // ✅ After Load More -> scroll to first row of newly visible items
              if (state is ProductSearchLoaded &&
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

              if (state is ProductSearchLoaded) {
                _lastLoadedCount = state.products.length;
                WidgetsBinding.instance.addPostFrameCallback((_) => _onGridScroll());
              }
            },
            builder: (context, state) {
              final hasProducts =
                  state is ProductSearchLoaded && state.products.isNotEmpty;

              final pfState = context.watch<ProductFilterBloc>().state;
              final sortOptions = pfState is ProductFilterLoaded
                  ? pfState.sortBy
                  : const <ProductSortByModel>[];

              final appliedFilters = (state is ProductSearchLoaded)
                  ? Map<String, dynamic>.from(state.appliedFilters)
                  : <String, dynamic>{};
              final hasDashboardFilters = _hasAppliedDashboardFilters(appliedFilters);

              return MJScaffold(
                username: auth.user.firstName,
                onLogout: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                requestSafeCount: _selectedIds.length,
                receivedSafeCount: 0,
                onRequestSafe: _handleRequestSafe,
                showHome: true,
                onRequestedList: () {
                  if (GoRouterState.of(context).uri.toString() ==
                      '/a/requested-stock-list') return;
                  context.pushReplacement('/a/requested-stock-list');
                },
                onReceivedSafe: () {
                  if (GoRouterState.of(context).uri.toString() ==
                      '/a/received-safe') return;
                  context.pushReplacement('/a/received-safe');
                },
                onCustomerExperience: () {
                  if (GoRouterState.of(context).uri.toString() ==
                      '/a/customer-review') return;
                  context.pushReplacement('/a/customer-review');
                },
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isTablet)
                        _topAreaTablet(
                          hasProducts: hasProducts,
                          filters: appliedFilters,
                          sortOptions: sortOptions,
                          pfState: pfState,
                          showStartAgain:
                              hasDashboardFilters && state is ProductSearchLoaded,
                          isTablet: isTablet,
                        )
                      else
                        _topAreaPhone(
                          hasProducts: hasProducts,
                          filters: appliedFilters,
                          sortOptions: sortOptions,
                          pfState: pfState,
                          showStartAgain:
                              hasDashboardFilters && state is ProductSearchLoaded,
                          isTablet: isTablet,
                        ),

                      if (!hasDashboardFilters) ...[
                        const SizedBox(height: 10),
                        _singleProductSearchSection(
                          isTablet: isTablet,
                          showStartAgain: state is ProductSearchLoaded,
                        ),
                      ],

                      const SizedBox(height: 10),

                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (state is ProductSearchInitial ||
                                state is ProductSearchError) {
                              return const Center(
                                child: Text(
                                  "Apply filters or search stock code to view products",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            } else if (state is ProductSearchLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is ProductSearchLoaded) {
                              if (state.products.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "No products found",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _startAgainButton(isTablet: isTablet),
                                    ],
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
                                          key:
                                              const PageStorageKey('productGrid'),
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
                                                similarFilters: state.appliedFilters,
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
                                                            .clamp(0,
                                                                state.totalFound);

                                                    final newProducts = state
                                                        .allProducts
                                                        .take(nextCount)
                                                        .toList();

                                                    context
                                                        .read<ProductSearchBloc>()
                                                        .add(UpdateLoadedProducts(
                                                            newProducts));
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

  // =========================
  // TOP AREA (TABLET)
  // =========================
  Widget _topAreaTablet({
    required bool hasProducts,
    required Map<String, dynamic> filters,
    required List<ProductSortByModel> sortOptions,
    required ProductFilterState pfState,
    required bool showStartAgain,
    required bool isTablet,
  }) {
    final chipData = _buildChipData(filters: filters, sortOptions: sortOptions);

    final showClearAll = hasProducts && _hasClearableNonMandatoryFilters(filters, pfState);

    final dropdownRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _gridDropdownInline(),
        const SizedBox(width: 12),
        _sortDropdownInline(enabled: hasProducts, sortOptions: sortOptions),
        if (showStartAgain) ...[
          const SizedBox(width: 12),
          _startAgainButton(isTablet: isTablet),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        const menuW = 68.0;
        const gap1 = 12.0;
        const gap2 = 12.0;
        final dropdownW = 80.0 +
            12.0 +
            175.0 +
            (showStartAgain ? 12.0 + (isTablet ? 135.0 : 115.0) : 0.0);

        final chipAreaMaxW = hasProducts
            ? (c.maxWidth - menuW - gap1 - gap2 - dropdownW)
                .clamp(140.0, c.maxWidth)
            : (c.maxWidth - menuW - gap1).clamp(140.0, c.maxWidth);

        final chipWidgets = <Widget>[
          if (showClearAll) _clearAllChip(() => _clearAllNonMandatory(filters)),
          ...chipData.map(
            (d) => _chipBlue(
              d.label,
              () => _removeFilterKeys(filters, d.keys),
              maxWidth: chipAreaMaxW,
            ),
          ),
        ];

        if (hasProducts) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Icon(Icons.menu, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _zoomPreferenceButton(),
                  ],
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: chipWidgets,
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [dropdownRow],
                ),
              ],
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            _zoomPreferenceButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: chipWidgets,
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // TOP AREA (PHONE)
  // =========================
  Widget _topAreaPhone({
    required bool hasProducts,
    required Map<String, dynamic> filters,
    required List<ProductSortByModel> sortOptions,
    required ProductFilterState pfState,
    required bool showStartAgain,
    required bool isTablet,
  }) {
    final chipData = _buildChipData(filters: filters, sortOptions: sortOptions);
    final showClearAll = hasProducts && _hasClearableNonMandatoryFilters(filters, pfState);

    final chipWidgets = <Widget>[
      if (showClearAll) _clearAllChip(() => _clearAllNonMandatory(filters)),
      ...chipData.map((d) => _chipBlue(d.label, () => _removeFilterKeys(filters, d.keys))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            _zoomPreferenceButton(),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: chipWidgets),
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
              const SizedBox(width: 12),
              _sortDropdownInline(enabled: true, sortOptions: sortOptions),
              if (showStartAgain) ...[
                const SizedBox(width: 10),
                _startAgainButton(isTablet: isTablet),
              ],
            ],
          ),
      ],
    );
  }

  // =========================
  // REMOVE FILTER(S)
  // =========================
  void _removeFilterKeys(Map<String, dynamic> currentFilters, List<String> keys) {
    final newFilters = Map<String, dynamic>.from(currentFilters);
    for (final k in keys) {
      newFilters.remove(k);
    }

    if (keys.contains('sort_by')) {
      setState(() => _sortByValue = null);
    }

    _applyProductFilters(newFilters);
  }

  // =========================
  // CHIP DATA (combine FROM/TO into single chip)
  // =========================
  List<_ChipData> _buildChipData({
    required Map<String, dynamic> filters,
    required List<ProductSortByModel> sortOptions,
  }) {
    if (filters.isEmpty) return const [];

    final visible = Map<String, dynamic>.from(filters)
      ..removeWhere((key, _) => key.toLowerCase() == 'cse_id' || key == '__single_stock_code');

    if (visible.isEmpty) return const [];

    String formatKey(String key) {
      return key
          .split('_')
          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' ');
    }

    String formatValue(String key, dynamic value) {
      if (key == 'sort_by') {
        final v = value?.toString() ?? '';
        final match = sortOptions.firstWhere(
          (s) => s.value == v,
          orElse: () => ProductSortByModel(
            labelDisplay: v,
            postName: 'sort_by',
            value: v,
          ),
        );
        return match.labelDisplay;
      }
      if (value is List) return value.join(', ');
      return value.toString();
    }

    final processed = <String>{};
    final out = <_ChipData>[];

    final keys = visible.keys.toList()..sort();

    bool hasNonEmpty(String k) {
      final v = visible[k];
      if (v == null) return false;
      final s = v.toString().trim();
      return s.isNotEmpty;
    }

    for (final k in keys) {
      if (processed.contains(k)) continue;

      if (k.endsWith('_from')) {
        final base = k.substring(0, k.length - 5);
        final toKey = '${base}_to';
        if (visible.containsKey(toKey) && hasNonEmpty(k) && hasNonEmpty(toKey)) {
          processed.add(k);
          processed.add(toKey);

          final labelKey = formatKey(base);
          final fromVal = visible[k]!.toString().trim();
          final toVal = visible[toKey]!.toString().trim();

          out.add(_ChipData(
            keys: [k, toKey],
            label: '$labelKey: $fromVal - $toVal',
          ));
          continue;
        }
      }

      if (k.startsWith('from_')) {
        final base = k.substring(5);
        final toKey = 'to_$base';
        if (visible.containsKey(toKey) && hasNonEmpty(k) && hasNonEmpty(toKey)) {
          processed.add(k);
          processed.add(toKey);

          final labelKey = formatKey(base);
          final fromVal = visible[k]!.toString().trim();
          final toVal = visible[toKey]!.toString().trim();

          out.add(_ChipData(
            keys: [k, toKey],
            label: '$labelKey: $fromVal - $toVal',
          ));
          continue;
        }
      }

      if (k.endsWith('_to')) {
        final base = k.substring(0, k.length - 3);
        final fromKey = '${base}_from';
        if (visible.containsKey(fromKey)) continue;
      }
      if (k.startsWith('to_')) {
        final base = k.substring(3);
        final fromKey = 'from_$base';
        if (visible.containsKey(fromKey)) continue;
      }

      final v = visible[k];
      final vStr = v?.toString().trim() ?? '';
      if (vStr.isEmpty) continue;

      out.add(_ChipData(
        keys: [k],
        label: '${formatKey(k)}: ${formatValue(k, v)}',
      ));
    }

    return out;
  }

  // =========================
  // API FUNCTIONS
  // =========================
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
    final productBloc = context.read<ProductSearchBloc>();

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
             final authState = context.read<AuthBloc>().state;
            if (authState is! AuthAuthenticated) return;

            final currentState = productBloc.state;
            if (currentState is ProductSearchLoaded) {
              productBloc.add(
                ApplyFilters(
                  currentState.appliedFilters,
                  cseId: authState.user.id,
                ),
              );
            }

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

  // =========================
  // UI HELPERS
  // =========================
  Widget _chipBlue(String label, VoidCallback onDelete, {double? maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        margin: const EdgeInsets.only(right: 10, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEF6),
          border: Border.all(color: _mjPrimaryBlue, width: 0.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                label,
                softWrap: true,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _mjPrimaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onDelete,
              child: const Icon(Icons.close, size: 16, color: _mjPrimaryBlue),
            ),
          ],
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

  Widget _sortDropdownInline({
    required bool enabled,
    required List<ProductSortByModel> sortOptions,
  }) {
    return SizedBox(
      width: 175,
      child: MJDropdownField<String>(
        value: _sortByValue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        hintText: 'Select',
        items: sortOptions
            .map((s) => DropdownMenuItem<String>(
                  value: s.value,
                  child: Text(s.labelDisplay),
                ))
            .toList(),
        onChanged: (v) {
          if (!enabled) return;

          setState(() => _sortByValue = v);

          final ps = context.read<ProductSearchBloc>().state;
          if (ps is! ProductSearchLoaded) return;

          final newFilters = Map<String, dynamic>.from(ps.appliedFilters);

          if (v == null || v.trim().isEmpty) {
            newFilters.remove('sort_by');
          } else {
            newFilters['sort_by'] = v;
          }

          _applyProductFilters(newFilters);
        },
      ),
    );
  }

  Map<String, dynamic> _buildSimilarProductFilters(
    Map<String, dynamic> currentFilters,
  ) {
    const allowedKeys = <String>{
      'selling_price_from',
      'selling_price_to',
      'metal_weight_from',
      'metal_weight_to',
      'diamond_wt_from',
      'diamond_wt_to',
      'size_weight_from',
      'size_weight_to',
      'sort_by',
    };

    final out = <String, dynamic>{};

    currentFilters.forEach((key, value) {
      if (!allowedKeys.contains(key)) return;
      if (value == null) return;

      if (value is List) {
        final items = value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (items.isNotEmpty) {
          out[key] = items;
        }
        return;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        out[key] = text;
      }
    });

    return out;
  }

  void _openSimilarProducts(
    ProductModel product,
    Map<String, dynamic> currentFilters,
  ) {
    context.push(
      '/a/similar-products',
      extra: {
        'selectedStockCode': product.stockCode,
        'initialFilters': _buildSimilarProductFilters(currentFilters),
      },
    );
  }


 //============================== Zoom icon and only full image view ==============================//
  // Widget _productTile(
  //   ProductModel product,
  //   bool selected, {
  //   required Map<String, dynamic> similarFilters,
  //   required VoidCallback onToggle,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(6),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 3,
  //           offset: const Offset(0, 1),
  //         ),
  //       ],
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(6),
  //       child: Stack(
  //         children: [
  //           Positioned.fill(
  //             child: CachedNetworkImage(
  //               imageUrl: product.image,
  //               fit: BoxFit.cover,
  //               placeholder: (context, url) => const Center(
  //                 child: CircularProgressIndicator(strokeWidth: 2),
  //               ),
  //               errorWidget: (context, url, error) =>
  //                   const Center(child: Icon(Icons.broken_image)),
  //             ),
  //           ),
  //           Positioned(
  //             top: 6,
  //             left: 6,
  //             child: GestureDetector(
  //               onTap: () => _openSimilarProducts(product, similarFilters),
  //               child: Container(
  //                 padding: const EdgeInsets.all(6),
  //                 decoration: BoxDecoration(
  //                   color: Colors.black45,
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: const Icon(
  //                   Icons.auto_awesome_mosaic,
  //                   color: Colors.white,
  //                   size: 20,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             top: 6,
  //             right: 6,
  //             child: GestureDetector(
  //               onTap: () => _openImageViewer(product),
  //               child: Container(
  //                 padding: const EdgeInsets.all(6),
  //                 decoration: BoxDecoration(
  //                   color: Colors.black45,
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: const Icon(
  //                   Icons.zoom_in,
  //                   color: Colors.white,
  //                   size: 18,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             left: 6,
  //             bottom: 6,
  //             child: Container(
  //               padding: const EdgeInsets.all(4),
  //               color: Colors.black54,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     product.stockCode,
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                   Text(
  //                     product.displayPrice,
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             right: 6,
  //             bottom: 6,
  //             child: GestureDetector(
  //               onTap: onToggle,
  //               child: Container(
  //                 width: 22,
  //                 height: 22,
  //                 decoration: BoxDecoration(
  //                   color: selected ? _mjPrimaryBlue : Colors.white,
  //                   border: Border.all(color: _mjPrimaryBlue),
  //                   borderRadius: BorderRadius.zero,
  //                 ),
  //                 child: selected
  //                     ? const Icon(Icons.check, size: 14, color: Colors.white)
  //                     : null,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _openImageViewer(ProductModel product) {
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
  //                   child: CachedNetworkImage(
  //                     imageUrl: product.image,
  //                     fit: BoxFit.contain,
  //                     placeholder: (context, url) =>
  //                         const Center(child: CircularProgressIndicator()),
  //                     errorWidget: (context, url, error) => const Icon(
  //                       Icons.broken_image,
  //                       color: Colors.white54,
  //                       size: 48,
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

 //============================== Zoom icon and only full image view ==============================//

  Widget _productTile(
    ProductModel product,
    bool selected, {
    required Map<String, dynamic> similarFilters,
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
                child: ClipRect(
                  child: Transform.scale(
                    scale: _gridImageScale(product),
                    alignment: _gridImageAlignment(product),
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
              ),
            ),

            /// Similar products icon - untouched
            Positioned(
              top: 6,
              left: 6,
              child: GestureDetector(
                onTap: () => _openSimilarProducts(product, similarFilters),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_mosaic,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            /// Removed zoom icon from top-right

            Positioned(
              left: 6,
              bottom: 6,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openImageViewer(product),
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
            ),

            if (_applyZoomToAll)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.48),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Transform.scale(
                    scale: 0.72,
                    child: Switch(
                      value: _isManualZoomEnabledFor(product),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (enabled) {
                        final key = _productZoomKey(product);
                        setState(() {
                          if (enabled) {
                            _manualZoomDisabledIds.remove(key);
                          } else {
                            _manualZoomDisabledIds.add(key);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),

            /// Checkbox - untouched
            Positioned(
              right: 6,
              bottom: 6,
              child: GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? _mjPrimaryBlue : Colors.white,
                    border: Border.all(color: _mjPrimaryBlue),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
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
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.white.withOpacity(0.15),
                      ),
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
                                        itemCount:
                                            product.imagePopupData.length,
                                        separatorBuilder: (_, __) => Divider(
                                          color: Colors.white.withOpacity(0.12),
                                          height: 18,
                                        ),
                                        itemBuilder: (context, index) {
                                          final item =
                                              product.imagePopupData[index];

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
}

class _ChipData {
  final List<String> keys;
  final String label;
  const _ChipData({required this.keys, required this.label});
}

