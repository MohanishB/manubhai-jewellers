import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/theme/app_colors.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/core/widgets/mj_dropdown_field.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/core/widgets/mj_text_field.dart';
import 'package:manubhaimlt/core/widgets/mj_image_zoom_control.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/bucketSimilarProducts/bucket_similar_products_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/bucketSimilarProducts/bucket_similar_products_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/bucketSimilarProducts/bucket_similar_products_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/requestSafe/request_safe_state.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_search_model.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/similar_bucket_models.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:photo_view/photo_view.dart';

class BucketSimilarProductsScreen extends StatefulWidget {
  final String selectedStockCode;

  const BucketSimilarProductsScreen({
    super.key,
    required this.selectedStockCode,
  });

  @override
  State<BucketSimilarProductsScreen> createState() =>
      _BucketSimilarProductsScreenState();
}

class _BucketSimilarProductsScreenState
    extends State<BucketSimilarProductsScreen> {
  static const _mjPrimaryBlue = Color(0xFF1E5AA8);

  final Set<String> _selectedIds = {};
  final ScrollController _gridScrollCtrl = ScrollController();

  int _gridChoice = 3;
  bool _isAtGridBottom = true;
  int? _pendingScrollToFirstNewIndex;
  int _lastLoadedCount = 0;
  double _gridWidth = 0;
  int? _selectedBucketId;
  String? _lookupPopupShownForStockCode;
  late final TextEditingController _stockSearchCtrl;
  late String _activeStockCode;

  // Manual image zoom mode. When disabled, the existing API-driven
  // zoom_image / zoom_level behaviour remains unchanged.
  bool _applyZoomToAll = false;
  MJImageZoomOrigin _zoomOrigin = MJImageZoomOrigin.center;
  final Set<String> _manualZoomDisabledIds = <String>{};

  @override
  void initState() {
    super.initState();
    _activeStockCode = widget.selectedStockCode;
    _stockSearchCtrl = TextEditingController(text: widget.selectedStockCode);
    ScreenProtector.preventScreenshotOn();
    _gridScrollCtrl.addListener(_onGridScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BucketSimilarProductsBloc>().add(
            LookupBucketSimilarProducts(
              stockCode: _activeStockCode,
              cseId: _cseId(),
              cseMltBranch: _cseMltBranch(),
              cseMltLocation: _cseMltLocation(),
            ),
          );
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

  String _cseId() {
    final filterState = context.read<ProductFilterBloc>().state;
    if (filterState is ProductFilterLoaded) {
      return filterState.cseId.trim();
    }
    return '';
  }

  String _cseMltBranch() {
    final filterState = context.read<ProductFilterBloc>().state;
    if (filterState is ProductFilterLoaded) {
      return filterState.cseMltBranch.trim();
    }
    return '';
  }

  List<String> _cseMltLocation() {
    final filterState = context.read<ProductFilterBloc>().state;
    if (filterState is ProductFilterLoaded) {
      return List<String>.from(filterState.cseMltLocation);
    }
    return const [];
  }

  String _preferredCseBranch() => _cseMltBranch();

  void _loadBucket(int bucketId) {
    setState(() {
      _selectedBucketId = bucketId;
      _selectedIds.clear();
      _pendingScrollToFirstNewIndex = null;
      _lastLoadedCount = 0;
    });
    context.read<BucketSimilarProductsBloc>().add(
          LoadBucketSimilarProducts(
            stockCode: _activeStockCode,
            bucketId: bucketId,
            preferredBranch: _preferredCseBranch(),
            cseId: _cseId(),
            cseMltBranch: _cseMltBranch(),
            cseMltLocation: _cseMltLocation(),
          ),
        );
  }

  Future<void> _showLookupBucketPopup(SimilarLookupResponse lookup) async {
    if (!mounted || lookup.buckets.isEmpty) return;

    final selectedBucket = await showDialog<SimilarBucket>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Select Bucket',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _mjPrimaryBlue,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          content: SizedBox(
            width: 420,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: lookup.buckets.length,
              itemBuilder: (_, index) {
                final bucket = lookup.buckets[index];

                return InkWell(
                  onTap: () => Navigator.pop(dialogContext, bucket),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: _mjPrimaryBlue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            bucket.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _mjPrimaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: _mjPrimaryBlue,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted || selectedBucket == null) return;
    _loadBucket(selectedBucket.id);
  }


  void _handleRequestSafe() {
    if (_selectedIds.isEmpty) {
      showMJAlertDialog(
        context,
        title: 'No Products Selected',
        message: 'Please select at least one product to request from safe.',
        primaryButtonText: 'OK',
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<RequestSafeBloc>().add(
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
            showMJAlertDialog(
              context,
              title: 'Success',
              message: 'Stock requested successfully!',
              primaryButtonText: 'OK',
            );
          } else if (state is RequestSafeError) {
            Navigator.pop(context);
            showMJAlertDialog(
              context,
              title: 'Info',
              message: state.message,
              primaryButtonText: 'OK',
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

  void _openFilterDrawer(BucketSimilarProductsLoaded state) async {
    final result = await showModalBottomSheet<Map<String, Set<String>>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BucketFilterSheet(
        options: state.filterOptions,
        selected: state.appliedFilters,
      ),
    );

    if (result == null) return;

    _pendingScrollToFirstNewIndex = null;
    _lastLoadedCount = 0;
    context.read<BucketSimilarProductsBloc>().add(
          ApplyBucketSimilarFilters(result),
        );
  }

  void _runStockSearch() {
    final stockCode = _stockSearchCtrl.text.trim().toUpperCase();
    if (stockCode.isEmpty) {
      showMJAlertDialog(
        context,
        title: 'Stock Code Required',
        message: 'Please enter a stock code to search.',
        primaryButtonText: 'OK',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _activeStockCode = stockCode;
      _stockSearchCtrl.text = stockCode;
      _selectedBucketId = null;
      _selectedIds.clear();
      _pendingScrollToFirstNewIndex = null;
      _lastLoadedCount = 0;
      _lookupPopupShownForStockCode = null;
      _manualZoomDisabledIds.clear();
    });

    context.read<BucketSimilarProductsBloc>().add(
          LookupBucketSimilarProducts(
            stockCode: stockCode,
            cseId: _cseId(),
            cseMltBranch: _cseMltBranch(),
            cseMltLocation: _cseMltLocation(),
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

      // Manual mode ignores zoom_image. Use the API zoom_level when it is
      // greater than 1; otherwise fall back to a visible 2x zoom.
      final apiZoomLevel = product.zoomLevel;
      return apiZoomLevel > 1.0 ? apiZoomLevel : 2.0;
    }

    // Existing/default API-driven behaviour remains unchanged.
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

  Widget _stockSearchBar({bool compact = false}) {
    final textField = MJTextField(
      controller: _stockSearchCtrl,
      hintText: 'Stock Code',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (_) => _runStockSearch(),
    );

    return Row(
      mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (compact)
          Expanded(child: textField)
        else
          SizedBox(width: 145, child: textField),
        const SizedBox(width: 8),
        SizedBox(
          height: 38,
          width: 96,
          child: MJPrimaryButton(
            text: 'SEARCH',
            onPressed: _runStockSearch,
          ),
        ),
      ],
    );
  }

  Widget _bucketSelector(
    List<SimilarBucket> buckets, {
    BucketSimilarProductsLoaded? loaded,
  }) {
    final selectedKey = loaded?.selectedBucketKey ??
        (_selectedBucketId == null ? null : 'bucket_$_selectedBucketId');

    return SizedBox(
      width: 320,
      child: MJDropdownField<String>(
        value: selectedKey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        hintText: 'Select Bucket',
        items: buckets
            .map(
              (b) => DropdownMenuItem<String>(
                value: b.optionKey,
                child: Text(b.displayName, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;

          SimilarBucket? selected;
          for (final bucket in buckets) {
            if (bucket.optionKey == value) {
              selected = bucket;
              break;
            }
          }

          if (selected == null) return;

          _selectedIds.clear();
          _pendingScrollToFirstNewIndex = null;
          _lastLoadedCount = 0;

          final selectedBucket = selected;
          if (selectedBucket.isOther) {
            setState(() => _selectedBucketId = selectedBucket.id);
            context.read<BucketSimilarProductsBloc>().add(
                  SelectSeeAlsoBucketSimilarProducts(
                    bucketKey: selectedBucket.optionKey,
                  ),
                );
          } else {
            _loadBucket(selectedBucket.id);
          }
        },
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

  Widget _topArea({
  required bool isTablet,
  required List<SimilarBucket> buckets,
  required bool hasProducts,
  BucketSimilarProductsLoaded? loaded,
}) {
  final filterButton = loaded == null
      ? const SizedBox.shrink()
      : SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            tooltip: 'Filter',
            padding: EdgeInsets.zero,
            splashRadius: 20,
            alignment: Alignment.center,
            onPressed: () => _openFilterDrawer(loaded),
            icon: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.filter_alt_outlined,
                  size: 22,
                ),
                if (loaded.appliedFilters.values.any((e) => e.isNotEmpty))
                  const Positioned(
                    right: -1,
                    top: -1,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        );

  if (isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, size: 24),
        ),
        const SizedBox(width: 10),
        _zoomPreferenceButton(),
        const SizedBox(width: 12),
        _stockSearchBar(),
        const Spacer(),
        SizedBox(
          width: 320,
          child: _bucketSelector(buckets, loaded: loaded),
        ),
        const SizedBox(width: 12),
        if (hasProducts) _gridDropdownInline(),
        const SizedBox(width: 12),
        filterButton,
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, size: 24),
          ),
          const SizedBox(width: 10),
          _zoomPreferenceButton(),
          const SizedBox(width: 12),
          Expanded(child: _stockSearchBar(compact: true)),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _bucketSelector(buckets, loaded: loaded)),
          const SizedBox(width: 8),
          if (hasProducts) _gridDropdownInline(),
          const SizedBox(width: 8),
          filterButton,
        ],
      ),
    ],
  );
}

  // Widget _topArea({
  //   required bool isTablet,
  //   required List<SimilarBucket> buckets,
  //   required bool hasProducts,
  //   BucketSimilarProductsLoaded? loaded,
  // }) {
  //   final filterButton = loaded == null
  //       ? const SizedBox.shrink()
  //       : IconButton(
  //           tooltip: 'Filter',
  //           padding: EdgeInsets.zero,
  //           constraints: const BoxConstraints(
  //             minWidth: 40,
  //             minHeight: 40,
  //           ),
  //           onPressed: () => _openFilterDrawer(loaded),
  //           icon: Stack(
  //             clipBehavior: Clip.none,
  //             children: [
  //               const Icon(Icons.filter_alt_outlined),
  //               if (loaded.appliedFilters.values.any((e) => e.isNotEmpty))
  //                 const Positioned(
  //                   right: -1,
  //                   top: -1,
  //                   child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
  //                 ),
  //             ],
  //           ),
  //         );

  //   if (isTablet) {
  //     return Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         InkWell(
  //           onTap: () => context.pop(),
  //           child: const Icon(Icons.arrow_back, size: 24),
  //         ),
  //         const SizedBox(width: 12),
  //         _stockSearchBar(),
  //         const Spacer(),
  //         SizedBox(
  //           width: 320,
  //           child: _bucketSelector(buckets, loaded: loaded),
  //         ),
  //         const SizedBox(width: 12),
  //         if (hasProducts) _gridDropdownInline(),
  //         const SizedBox(width: 16),
  //         filterButton,
  //       ],
  //     );
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           InkWell(
  //             onTap: () => context.pop(),
  //             child: const Icon(Icons.arrow_back, size: 24),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(child: _stockSearchBar(compact: true)),
  //         ],
  //       ),
  //       const SizedBox(height: 10),
  //       Row(
  //         children: [
  //           Expanded(child: _bucketSelector(buckets, loaded: loaded)),
  //           const SizedBox(width: 8),
  //           if (hasProducts) _gridDropdownInline(),
  //           const SizedBox(width: 8),
  //           filterButton,
  //         ],
  //       ),
  //     ],
  //   );
  // }

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

  Widget _pieceInfoRow(String label, String value) {
    final text = value.trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 220;

        if (compact) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _piecePopupCard(ProductPiecePopupData piece, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.clamp(0.0, 1120.0);

        final image = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(piece.imageUrl),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4,
              heroAttributes: PhotoViewHeroAttributes(
                tag: '${piece.imageUrl}_$index',
              ),
            )
          // child: InteractiveViewer(
          //   minScale: 1.0,
          //   maxScale: 5.0,
          //   child: CachedNetworkImage(
          //     imageUrl: piece.imageUrl,
          //     width: double.infinity,
          //     height: double.infinity,
          //     fit: BoxFit.contain,
          //     placeholder: (context, url) =>
          //         const Center(child: CircularProgressIndicator()),
          //     errorWidget: (context, url, error) => const Center(
          //       child: Icon(
          //         Icons.broken_image,
          //         color: Colors.white54,
          //         size: 42,
          //       ),
          //     ),
          //   ),
          // ),
        );

        final isPhone = MediaQuery.sizeOf(context).width < 600;

        final details = Container(
          padding: EdgeInsets.fromLTRB(
            isPhone ? 8 : 14,
            10,
            isPhone ? 8 : 14,
            10,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.20),
            border: const Border(
              left: BorderSide(color: Colors.white12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                piece.stockCode.isNotEmpty
                    ? piece.stockCode
                    : 'Piece ${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPhone ? 13 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (piece.stockCode.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Piece ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: piece.displayRows
                        .map((row) => _pieceInfoRow(row.label, row.value))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );

        return Container(
          width: cardWidth,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Builder(
              builder: (context) {
                final isPhone = MediaQuery.sizeOf(context).width < 600;

                return Row(
                  children: [
                    Expanded(flex: isPhone ? 11 : 3, child: image),
                    Expanded(flex: isPhone ? 9 : 2, child: details),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _openImageViewer(ProductModel product) {
    final pieces = product.piecePopupData;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: pieces.isEmpty
                  ? PhotoView(
                      imageProvider: CachedNetworkImageProvider(product.image),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 4,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: product.stockCode,
                      ),
                    )
                  // ? InteractiveViewer(
                  //     minScale: 1.0,
                  //     maxScale: 5.0,
                  //     child: Center(
                  //       child: CachedNetworkImage(
                  //         imageUrl: product.image,
                  //         fit: BoxFit.contain,
                  //         placeholder: (context, url) =>
                  //             const Center(child: CircularProgressIndicator()),
                  //         errorWidget: (context, url, error) => const Icon(
                  //           Icons.broken_image,
                  //           color: Colors.white54,
                  //           size: 48,
                  //         ),
                  //       ),
                  //     ),
                  //   )
                  : SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          MediaQuery.sizeOf(context).width < 600 ? 6 : 18,
                          70,
                          MediaQuery.sizeOf(context).width < 600 ? 6 : 18,
                          MediaQuery.sizeOf(context).width < 600 ? 12 : 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   product.stockCode,
                            //   style: const TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.w800,
                            //   ),
                            // ),
                            // const SizedBox(height: 14),
                            Expanded(
                              child: _PieceImageViewer(
                                pieces: pieces,
                                cardBuilder: (piece, index) =>
                                    _piecePopupCard(piece, index),
                              ),
                            ),
                          ],
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
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
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

  Widget _buildLoadedGrid(BucketSimilarProductsLoaded state) {
    if (state.products.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final canLoadMore = state.products.length < state.totalFound;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              if (_gridWidth != c.maxWidth) _gridWidth = c.maxWidth;

              return GridView.builder(
                controller: _gridScrollCtrl,
                key: const PageStorageKey('bucketSimilarProductGrid'),
                cacheExtent: 800,
                itemCount: state.products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridChoice,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final p = state.products[index];
                  final selected = _selectedIds.contains(p.stockCode);

                  return KeyedSubtree(
                    key: ValueKey(p.stockId),
                    child: _productTile(
                      p,
                      selected,
                      onToggle: () {
                        if (selected) {
                          setState(() => _selectedIds.remove(p.stockCode));
                          return;
                        }

                        if (_selectedIds.length >= state.maxSafeCount) {
                          showMJAlertDialog(
                            context,
                            title: 'Selection Limit Reached',
                            message:
                                'You can select maximum ${state.maxSafeCount} products.',
                            primaryButtonText: 'OK',
                          );
                          return;
                        }

                        setState(() => _selectedIds.add(p.stockCode));
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
                    duration: const Duration(milliseconds: 140),
                    child: SizedBox(
                      width: 280,
                      child: MJPrimaryButton(
                        text:
                            'Load More (${state.products.length}/${state.totalFound})',
                        onPressed: () {
                          final loadedCount = state.products.length;
                          _pendingScrollToFirstNewIndex = loadedCount;
                          _lastLoadedCount = loadedCount;

                          final nextCount =
                              (loadedCount + state.loadCount).clamp(
                            0,
                            state.totalFound,
                          );

                          context.read<BucketSimilarProductsBloc>().add(
                                UpdateLoadedBucketSimilarProducts(
                                  state.allProducts.take(nextCount).toList(),
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthUnauthenticated,
      listener: (context, state) {
        context
            .read<BucketSimilarProductsBloc>()
            .add(const ResetBucketSimilarProducts());
      },
      child: Builder(
        builder: (context) {
          final authState = context.watch<AuthBloc>().state;
          if (authState is! AuthAuthenticated) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final auth = authState;

          return BlocConsumer<BucketSimilarProductsBloc,
              BucketSimilarProductsState>(
            listener: (context, state) {
              if (state is BucketSimilarProductsError) {
                showMJAlertDialog(
                  context,
                  title: 'Info',
                  message: state.message,
                  primaryButtonText: 'OK',
                );
              }

              if (state is BucketSimilarProductsLookupLoaded &&
                  _lookupPopupShownForStockCode != state.lookup.stockCode) {
                _lookupPopupShownForStockCode = state.lookup.stockCode;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showLookupBucketPopup(state.lookup);
                });
              }

              if (state is BucketSimilarProductsLoaded &&
                  _pendingScrollToFirstNewIndex != null &&
                  state.products.length > _lastLoadedCount) {
                final firstNewIndex = _pendingScrollToFirstNewIndex!;
                _pendingScrollToFirstNewIndex = null;

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!_gridScrollCtrl.hasClients) return;

                  final pos = _gridScrollCtrl.position;
                  final gridW = _gridWidth > 0 ? _gridWidth : pos.viewportDimension;
                  const crossAxisSpacing = 14.0;
                  const mainAxisSpacing = 14.0;
                  const childAspectRatio = 0.9;
                  final itemW =
                      (gridW - (_gridChoice - 1) * crossAxisSpacing) / _gridChoice;
                  final itemH = itemW / childAspectRatio;
                  final rowExtent = itemH + mainAxisSpacing;
                  final rowIndex = firstNewIndex ~/ _gridChoice;
                  final target =
                      (rowIndex * rowExtent).clamp(0.0, pos.maxScrollExtent);

                  await _gridScrollCtrl.animateTo(
                    target,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                  );
                });
              }

              if (state is BucketSimilarProductsLoaded) {
                _lastLoadedCount = state.products.length;
                WidgetsBinding.instance.addPostFrameCallback((_) => _onGridScroll());
              }
            },
            builder: (context, state) {
              final lookup = state is BucketSimilarProductsLookupLoaded
                  ? state.lookup
                  : state is BucketSimilarProductsLoaded
                      ? state.lookup
                      : null;
              final loaded =
                  state is BucketSimilarProductsLoaded ? state : null;
              final hasProducts = loaded != null && loaded.products.isNotEmpty;

              return MJScaffold(
                username: auth.user.firstName,
                onLogout: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                requestSafeCount: _selectedIds.length,
                receivedSafeCount: 0,
                onRequestSafe: _handleRequestSafe,
                onRequestedList: () => context.push('/a/requested-stock-list'),
                onReceivedSafe: () => context.push('/a/received-safe'),
                onCustomerExperience: () => context.push('/a/customer-review'),
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lookup != null)
                        _topArea(
                          isTablet: isTablet,
                          buckets: loaded?.dropdownBuckets ?? lookup.buckets,
                          hasProducts: hasProducts,
                          loaded: loaded,
                        )
                      else
                        Row(
                          children: [
                            InkWell(
                              onTap: () => context.pop(),
                              child: const Icon(Icons.arrow_back, size: 24),
                            ),
                            const SizedBox(width: 10),
                            _zoomPreferenceButton(),
                            const SizedBox(width: 12),
                            Expanded(child: _stockSearchBar(compact: true)),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (state is BucketSimilarProductsInitial ||
                                state is BucketSimilarProductsLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state is BucketSimilarProductsLookupLoaded) {
                              if (state.lookup.buckets.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No buckets found for selected stock code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }
                              return const Center(
                                child: Text(
                                  'Please select a bucket to view products',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }

                            if (state is BucketSimilarProductsLoaded) {
                              return _buildLoadedGrid(state);
                            }

                            if (state is BucketSimilarProductsError) {
                              return const Center(
                                child: Text(
                                  'Unable to load products',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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


class _PieceImageViewer extends StatefulWidget {
  final List<ProductPiecePopupData> pieces;
  final Widget Function(ProductPiecePopupData piece, int index) cardBuilder;

  const _PieceImageViewer({
    required this.pieces,
    required this.cardBuilder,
  });

  @override
  State<_PieceImageViewer> createState() => _PieceImageViewerState();
}

class _PieceImageViewerState extends State<_PieceImageViewer> {
  int _currentIndex = 0;

  void _showPrevious() {
    if (_currentIndex <= 0) return;
    setState(() => _currentIndex--);
  }

  void _showNext() {
    if (_currentIndex >= widget.pieces.length - 1) return;
    setState(() => _currentIndex++);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pieces.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasMultiple = widget.pieces.length > 1;
    final piece = widget.pieces[_currentIndex];

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Center(
            child: KeyedSubtree(
              key: ValueKey('${piece.imageUrl}_$_currentIndex'),
              child: widget.cardBuilder(piece, _currentIndex),
            ),
          ),
        ),
        if (hasMultiple && _currentIndex > 0)
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: SafeArea(
                child: Tooltip(
                  message: 'Previous image',
                  child: InkWell(
                    onTap: _showPrevious,
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // color: Colors.black.withOpacity(0.72),
                        color: AppColors.brand.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.brand,
                          width: 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 50,
                        weight: 800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (hasMultiple && _currentIndex < widget.pieces.length - 1)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: SafeArea(
                child: Tooltip(
                  message: 'Next image',
                  child: InkWell(
                    onTap: _showNext,
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brand.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.brand,
                          width: 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 50,
                        weight: 800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (hasMultiple)
          Positioned(
            bottom: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white70,
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.pieces.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (widget.pieces.isEmpty) {
  //     return const SizedBox.shrink();
  //   }

  //   final hasMultiple = widget.pieces.length > 1;
  //   final piece = widget.pieces[_currentIndex];

  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       Positioned.fill(
  //         child: Center(
  //           child: KeyedSubtree(
  //             key: ValueKey('${piece.imageUrl}_$_currentIndex'),
  //             child: widget.cardBuilder(piece, _currentIndex),
  //           ),
  //         ),
  //       ),
  //       if (hasMultiple && _currentIndex > 0)
  //         Positioned(
  //           left: 8,
  //           child: SafeArea(
  //             child: Material(
  //               color: Colors.black54,
  //               shape: const CircleBorder(),
  //               child: IconButton(
  //                 tooltip: 'Previous image',
  //                 onPressed: _showPrevious,
  //                 icon: const Icon(
  //                   Icons.chevron_left,
  //                   color: Colors.white,
  //                   size: 30,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       if (hasMultiple && _currentIndex < widget.pieces.length - 1)
  //         Positioned(
  //           right: 8,
  //           child: SafeArea(
  //             child: Material(
  //               color: Colors.black54,
  //               shape: const CircleBorder(),
  //               child: IconButton(
  //                 tooltip: 'Next image',
  //                 onPressed: _showNext,
  //                 icon: const Icon(
  //                   Icons.chevron_right,
  //                   color: Colors.white,
  //                   size: 30,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       if (hasMultiple)
  //         Positioned(
  //           bottom: 8,
  //           child: IgnorePointer(
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 10,
  //                 vertical: 6,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: Colors.black54,
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               child: Text(
  //                 '${_currentIndex + 1} / ${widget.pieces.length}',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }
}

class _BucketFilterSheet extends StatefulWidget {
  final List<SimilarFilterOption> options;
  final Map<String, Set<String>> selected;

  const _BucketFilterSheet({
    required this.options,
    required this.selected,
  });

  @override
  State<_BucketFilterSheet> createState() => _BucketFilterSheetState();
}

class _BucketFilterSheetState extends State<_BucketFilterSheet> {
  late Map<String, Set<String>> _selected;
  final Map<String, TextEditingController> _minControllers = {};
  final Map<String, TextEditingController> _maxControllers = {};

  @override
  void initState() {
    super.initState();
    _selected = {
      for (final e in widget.selected.entries) e.key: {...e.value},
    };

    for (final option in widget.options.where((e) => e.isNumeric)) {
      final minKey = _minKey(option.column);
      final maxKey = _maxKey(option.column);

      _minControllers[option.column] = TextEditingController(
        text: _selected[minKey]?.isNotEmpty == true
            ? _selected[minKey]!.first
            : option.minValue,
      );
      _maxControllers[option.column] = TextEditingController(
        text: _selected[maxKey]?.isNotEmpty == true
            ? _selected[maxKey]!.first
            : option.maxValue,
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _minControllers.values) {
      controller.dispose();
    }
    for (final controller in _maxControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _minKey(String column) => '${column}__min';
  String _maxKey(String column) => '${column}__max';

  int _selectedCount(SimilarFilterOption option) {
    if (option.isNumeric) {
      var count = 0;
      if ((_selected[_minKey(option.column)]?.isNotEmpty ?? false)) count++;
      if ((_selected[_maxKey(option.column)]?.isNotEmpty ?? false)) count++;
      return count;
    }
    return _selected[option.column]?.length ?? 0;
  }

  void _toggleValue(String column, String value, bool checked) {
    setState(() {
      final values = _selected.putIfAbsent(column, () => <String>{});
      if (checked) {
        values.add(value);
      } else {
        values.remove(value);
      }
      if (values.isEmpty) _selected.remove(column);
    });
  }

  void _syncNumericSelection(SimilarFilterOption option) {
    final minText = _minControllers[option.column]?.text.trim() ?? '';
    final maxText = _maxControllers[option.column]?.text.trim() ?? '';

    if (minText.isEmpty) {
      _selected.remove(_minKey(option.column));
    } else {
      _selected[_minKey(option.column)] = {minText};
    }

    if (maxText.isEmpty) {
      _selected.remove(_maxKey(option.column));
    } else {
      _selected[_maxKey(option.column)] = {maxText};
    }
  }

  Map<String, Set<String>> _buildAppliedFilters() {
    final result = <String, Set<String>>{
      for (final entry in _selected.entries) entry.key: {...entry.value},
    };

    for (final option in widget.options.where((e) => e.isNumeric)) {
      final minText = _minControllers[option.column]?.text.trim() ?? '';
      final maxText = _maxControllers[option.column]?.text.trim() ?? '';

      if (minText.isEmpty) {
        result.remove(_minKey(option.column));
      } else {
        result[_minKey(option.column)] = {minText};
      }

      if (maxText.isEmpty) {
        result.remove(_maxKey(option.column));
      } else {
        result[_maxKey(option.column)] = {maxText};
      }
    }

    result.removeWhere((_, value) => value.isEmpty);
    return result;
  }

  void _clearFilters() {
    setState(() {
      _selected.clear();
      for (final controller in _minControllers.values) {
        controller.clear();
      }
      for (final controller in _maxControllers.values) {
        controller.clear();
      }
    });
  }

  Widget _numericField({
    required String label,
    required TextEditingController controller,
    required SimilarFilterOption option,
  }) {
    return MJTextField(
      controller: controller,
      hintText: label.toUpperCase(),
      keyboardType: TextInputType.number,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      onChanged: (_) {
        setState(() => _syncNumericSelection(option));
      },
    );
  }

  Widget _buildNumericChildren(SimilarFilterOption option) {
    final minController = _minControllers.putIfAbsent(
      option.column,
      () => TextEditingController(text: option.minValue),
    );
    final maxController = _maxControllers.putIfAbsent(
      option.column,
      () => TextEditingController(text: option.maxValue),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 2),
      child: Row(
        children: [
          Expanded(
            child: _numericField(
              label: 'From',
              controller: minController,
              option: option,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _numericField(
              label: 'To',
              controller: maxController,
              option: option,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiscreteChildren(SimilarFilterOption option) {
    return option.values.map((value) {
      final checked = _selected[option.column]?.contains(value) ?? false;

      return CheckboxListTile(
        value: checked,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.brand,
        title: Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        onChanged: (newValue) => _toggleValue(
          option.column,
          value,
          newValue ?? false,
        ),
      );
    }).toList();
  }

  Widget _buildBranchDropdown(SimilarFilterOption option) {
    final selectedValues = _selected[option.column];
    final selectedValue =
        selectedValues != null && selectedValues.isNotEmpty
            ? selectedValues.first
            : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MJDropdownField<String>(
        value: selectedValue,
        hintText: 'Select Branch',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        items: [
          const DropdownMenuItem<String>(
            value: '',
            child: Text('All Branches'),
          ),
          ...option.values.map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            final branch = value?.trim() ?? '';
            if (branch.isEmpty) {
              _selected.remove(option.column);
            } else {
              _selected[option.column] = {branch};
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.86;

    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: MediaQuery.of(context).size.width >= 700
              ? MediaQuery.of(context).size.width * 0.50
              : MediaQuery.of(context).size.width,
          height: maxHeight,
          child: Material(
            color: const Color(0xFFFCF8FF),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brand,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: widget.options.isEmpty
                      ? const Center(
                          child: Text(
                            'No filters available',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          itemCount: widget.options.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final option = widget.options[index];
                            final selectedCount = _selectedCount(option);

                            if (option.column.trim().toLowerCase() ==
                                'branch_org') {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Branch',
                                      style: TextStyle(
                                        color: AppColors.brand,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildBranchDropdown(option),
                                  ],
                                ),
                              );
                            }

                            return Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                checkboxTheme: CheckboxThemeData(
                                  fillColor: MaterialStateProperty.resolveWith(
                                    (states) => states.contains(MaterialState.selected)
                                        ? AppColors.brand
                                        : Colors.transparent,
                                  ),
                                  checkColor: MaterialStateProperty.all(Colors.white),
                                  side: const BorderSide(color: AppColors.brand),
                                ),
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: selectedCount > 0 || index == 0,
                                tilePadding: EdgeInsets.zero,
                                childrenPadding: const EdgeInsets.only(bottom: 10),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option.label,
                                        style: const TextStyle(
                                          color: AppColors.brand,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    if (selectedCount > 0)
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: AppColors.brand,
                                        child: Text(
                                          '$selectedCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                children: option.isNumeric
                                    ? [_buildNumericChildren(option)]
                                    : _buildDiscreteChildren(option),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: MJPrimaryButton(
                      text: 'APPLY FILTERS',
                      onPressed: () =>
                          Navigator.pop(context, _buildAppliedFilters()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
