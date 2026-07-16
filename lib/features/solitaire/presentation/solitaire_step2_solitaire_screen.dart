// lib/features/solitaire/presentation/solitaire_step2_solitaire_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';

import 'package:manubhaimlt/features/solitaire/bloc/filter_options_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/filter_options_event.dart';
import 'package:manubhaimlt/features/solitaire/bloc/filter_options_state.dart';

import 'package:manubhaimlt/features/solitaire/bloc/filter_diamonds_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/filter_diamonds_event.dart';
import 'package:manubhaimlt/features/solitaire/bloc/filter_diamonds_state.dart';

import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_event.dart';

import 'package:manubhaimlt/features/solitaire/data/models/step2_models.dart';
import 'package:manubhaimlt/features/solitaire/data/models/solitaire_diamond_models.dart';

import 'widgets/step2_customer_details_dialog.dart';
import 'widgets/step2_filters_card.dart';
import 'widgets/step2_original_product_banner.dart';
import 'widgets/step2_result_mobile_card.dart';
import 'widgets/step2_results_table.dart';
import 'widgets/step2_sticky_select_button.dart';
import 'widgets/step2_search_within_results_card.dart';

class SolitaireStep2SolitaireScreen extends StatefulWidget {
  const SolitaireStep2SolitaireScreen({super.key});

  @override
  State<SolitaireStep2SolitaireScreen> createState() =>
      _SolitaireStep2SolitaireScreenState();
}

class _SolitaireStep2SolitaireScreenState
    extends State<SolitaireStep2SolitaireScreen> {
  // ---------------- ROUTE ARGS (from Step1 via extra) ----------------
  bool _routeInitDone = false;
  String _cseId = '1'; // fallback if you don't pass it
  String _stockCode = '';

  // banner fields
  String _bannerStockCode = '';
  String _bannerSolitaireWt = '';
  String _bannerSolitaireAmount = '';
  String _bannerGrossWt = '';
  String _bannerTotalAmount = '';
  String _bannerLob = '';

  // ---------------- FILTER INPUTS (TOP CARD) ----------------
  final _priceFromCtrl = TextEditingController();
  final _priceToCtrl = TextEditingController();
  final _caratFromCtrl = TextEditingController();
  final _caratToCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _shape = 'Round';
  List<String> _shapeOptions = const [];

  // Multi select values (empty = All)
  List<String> _colors = [];
  List<String> _clarities = [];
  List<String> _cuts = [];
  List<String> _certificates = [];

  final List<String> _chips = [];
  int? _selectedIndex;

  // Options from API
  List<String> _colorOptions = const ['All Colors'];
  List<String> _clarityOptions = const ['All Clarity'];
  List<String> _cutOptions = const ['All Cuts'];
  List<String> _certificateOptions = const ['All Certificates'];

  // Screen state
  bool _filtersApplied = false;

  // ---------------- SEARCH WITHIN RESULTS (LOCAL) ----------------
  final _lotSearchCtrl = TextEditingController();
  final _certSearchCtrl = TextEditingController();
  final _caratSearchMinCtrl = TextEditingController();
  final _caratSearchMaxCtrl = TextEditingController();
  final _priceSearchMinCtrl = TextEditingController();
  final _priceSearchMaxCtrl = TextEditingController();

  List<SolitaireDiamondVm> _allDiamonds = [];
  List<SolitaireDiamondVm> _visibleDiamonds = [];

  // ---------------- LOCAL SORT STATE ----------------
  Step2SortColumn _sortColumn = Step2SortColumn.carat;
  Step2SortDir _sortDir = Step2SortDir.none;

  // clarity rank: lower index = better
  static const List<String> _clarityOrder = [
    'FL',
    'IF',
    'VVS1',
    'VVS2',
    'VS1',
    'VS2',
    'SI1',
    'SI2',
    'I1',
    'LC',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ DO NOT call FetchFilterOptions here because we need route args (extra).
    // We'll do it safely in didChangeDependencies().
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeInitDone) return;

    final extra = GoRouterState.of(context).extra;
    final map =
        (extra is Map<String, dynamic>) ? extra : const <String, dynamic>{};

    // cseId & stockCode used for API calls
   
    _cseId = (map['cseId'] ?? _cseId).toString();
    _stockCode = (map['stockCode'] ?? '').toString().trim();

    // banner values
    _bannerStockCode = _stockCode;
    _bannerSolitaireWt = (map['solitaireWt'] ?? '').toString();
    _bannerSolitaireAmount = (map['solitaireAmount'] ?? '').toString();
    _bannerGrossWt = (map['grossWt'] ?? '').toString();
    _bannerTotalAmount = (map['totalAmount'] ?? '').toString();
    _bannerLob = (map['lob'] ?? '').toString();

    _routeInitDone = true;

    // ✅ fetch filter options once we have stockCode
    if (_stockCode.isNotEmpty) {
      context.read<FilterOptionsBloc>().add(
            FetchFilterShapes(
              cseId: _cseId,
              stockCode: _stockCode,
            ),
          );
    } else {
      // If step2 opened without passing stockCode, show a small hint
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missing stockCode. Please search/select ring in Step 1.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }

    // ensure UI rebuild with route args
    setState(() {});
  }

  @override
  void dispose() {
    _priceFromCtrl.dispose();
    _priceToCtrl.dispose();
    _caratFromCtrl.dispose();
    _caratToCtrl.dispose();
    _searchCtrl.dispose();

    _lotSearchCtrl.dispose();
    _certSearchCtrl.dispose();
    _caratSearchMinCtrl.dispose();
    _caratSearchMaxCtrl.dispose();
    _priceSearchMinCtrl.dispose();
    _priceSearchMaxCtrl.dispose();

    super.dispose();
  }

  // ---------------- OPTIONS API -> UI ----------------

  void _onShapeChanged(String shape) {
    if (_stockCode.isEmpty) return;

    setState(() {
      _shape = shape;
      _priceFromCtrl.clear();
      _priceToCtrl.clear();
      _caratFromCtrl.clear();
      _caratToCtrl.clear();
      _searchCtrl.clear();

      _colors = [];
      _clarities = [];
      _cuts = [];
      _certificates = [];

      _colorOptions = const ['All Colors'];
      _clarityOptions = const ['All Clarity'];
      _cutOptions = const ['All Cuts'];
      _certificateOptions = const ['All Certificates'];

      _chips.clear();
      _selectedIndex = null;
      _filtersApplied = false;
      _allDiamonds = [];
      _visibleDiamonds = [];
      _sortDir = Step2SortDir.none;
      _sortColumn = Step2SortColumn.carat;
      _clearLocalSearchFieldsOnly();
    });

    context.read<FilterDiamondsBloc>().add(const ClearFilterDiamonds());
    context.read<FilterOptionsBloc>().add(
          FetchFilterOptionsByShape(
            cseId: _cseId,
            stockCode: _stockCode,
            shape: shape,
          ),
        );
  }

  void _applyApiShapesToUi(FilterShapesLoaded state) {
    final shapes = state.shapes.where((e) => e.trim().isNotEmpty).toList();
    if (shapes.isEmpty) return;

    final firstShape = shapes.first;

    setState(() {
      _shapeOptions = shapes;
      _shape = firstShape;
    });

    context.read<FilterOptionsBloc>().add(
          FetchFilterOptionsByShape(
            cseId: _cseId,
            stockCode: _stockCode,
            shape: firstShape,
          ),
        );
  }

  void _applyApiOptionsToUi(FilterOptionsLoaded state) {
    final opt = state.options;

    final colors = ['All Colors', ...opt.colors];
    final clarities = ['All Clarity', ...opt.clarity];
    final cuts = ['All Cuts', ...opt.cuts];
    final certs = ['All Certificates', ...opt.certificates];

    // remove stale selections if API changes
    _colors = _colors.where(opt.colors.contains).toList();
    _clarities = _clarities.where(opt.clarity.contains).toList();
    _cuts = _cuts.where(opt.cuts.contains).toList();
    _certificates = _certificates.where(opt.certificates.contains).toList();

    final apiShape = opt.shape.trim();
    final matchedShape = _shapeOptions.firstWhere(
      (s) => s.toLowerCase() == apiShape.toLowerCase(),
      orElse: () => apiShape.isEmpty ? _shape : apiShape,
    );

    setState(() {
      _shape = matchedShape;
      _colorOptions = colors;
      _clarityOptions = clarities;
      _cutOptions = cuts;
      _certificateOptions = certs;
    });
  }

  // ---------------- MAPPING ----------------
  List<StockRowVm> _mapDiamondsToRows(List<SolitaireDiamondVm> diamonds) {
    return diamonds.map((d) {
      return StockRowVm(
        lotNumber: d.lotNumber,
        shape: d.shape,
        carat: d.carat,
        color: d.color,
        clarity: d.clarity,
        cut: d.cut,
        priceInr: d.valueInr,
        certification: d.cert,
        certNo: d.certNo,
      );
    }).toList();
  }

  // ---------------- LOCAL SEARCH ----------------
  double? _toDoubleOrNull(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  double _parsePriceInr(String s) {
    final cleaned = s.replaceAll('₹', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _applyLocalSearch() {
    FocusManager.instance.primaryFocus?.unfocus();

    final lotQ = _lotSearchCtrl.text.trim().toLowerCase();
    final certQ = _certSearchCtrl.text.trim().toLowerCase();

    final caratMin =
        _toDoubleOrNull(_caratSearchMinCtrl.text) ?? double.negativeInfinity;
    final caratMax =
        _toDoubleOrNull(_caratSearchMaxCtrl.text) ?? double.infinity;

    final priceMin =
        _toDoubleOrNull(_priceSearchMinCtrl.text) ?? double.negativeInfinity;
    final priceMax =
        _toDoubleOrNull(_priceSearchMaxCtrl.text) ?? double.infinity;

    final filtered = _allDiamonds.where((d) {
      final lotOk = lotQ.isEmpty || d.lotNumber.toLowerCase().contains(lotQ);

      final certOk = certQ.isEmpty ||
          d.certNo.toLowerCase().contains(certQ) ||
          d.cert.toLowerCase().contains(certQ);

      final carat = double.tryParse(d.carat) ?? 0.0;
      final price = _parsePriceInr(d.priceInr);

      final caratOk = carat >= caratMin && carat <= caratMax;
      final priceOk = price >= priceMin && price <= priceMax;

      return lotOk && certOk && caratOk && priceOk;
    }).toList();

    setState(() {
      _visibleDiamonds = filtered;
      _selectedIndex = null;
    });
  }

  void _clearLocalSearchFieldsOnly() {
    FocusManager.instance.primaryFocus?.unfocus();
    _lotSearchCtrl.clear();
    _certSearchCtrl.clear();
    _caratSearchMinCtrl.clear();
    _caratSearchMaxCtrl.clear();
    _priceSearchMinCtrl.clear();
    _priceSearchMaxCtrl.clear();
  }

  void _clearLocalSearch() {
    setState(() {
      _clearLocalSearchFieldsOnly();
      _visibleDiamonds = List<SolitaireDiamondVm>.from(_allDiamonds);
      _selectedIndex = null;
    });
  }

  void _setNewApiResults(List<SolitaireDiamondVm> list) {
    setState(() {
      _allDiamonds = list;
      _visibleDiamonds = List<SolitaireDiamondVm>.from(list);
      _selectedIndex = null;

      _clearLocalSearchFieldsOnly();
    });
  }

  // ---------------- LOCAL SORT ----------------
  int _clarityRank(String v) {
    final idx = _clarityOrder.indexOf(v.trim().toUpperCase());
    return idx == -1 ? 999 : idx;
  }

  double _toDoubleSafe(String s) {
    final t = s.replaceAll('₹', '').replaceAll(',', '').trim();
    return double.tryParse(t) ?? 0.0;
  }

  Step2SortDir _toggleDir(Step2SortDir d) {
    switch (d) {
      case Step2SortDir.none:
        return Step2SortDir.asc;
      case Step2SortDir.asc:
        return Step2SortDir.desc;
      case Step2SortDir.desc:
        return Step2SortDir.none;
    }
  }

  void _onLocalSortTap(Step2SortColumn col) {
    setState(() {
      if (_sortColumn != col) {
        _sortColumn = col;
        _sortDir = Step2SortDir.asc;
      } else {
        _sortDir = _toggleDir(_sortDir);
      }
      _selectedIndex = null;
    });
  }

  List<StockRowVm> _applyLocalSort(List<StockRowVm> input) {
    if (_sortDir == Step2SortDir.none) return input;

    final list = List<StockRowVm>.from(input);
    final mul = _sortDir == Step2SortDir.asc ? 1 : -1;

    int cmpNum(double a, double b) => a.compareTo(b) * mul;
    int cmpStr(String a, String b) =>
        a.toUpperCase().compareTo(b.toUpperCase()) * mul;

    list.sort((a, b) {
      switch (_sortColumn) {
        case Step2SortColumn.carat:
          return cmpNum(_toDoubleSafe(a.carat), _toDoubleSafe(b.carat));
        case Step2SortColumn.color:
          return cmpStr(a.color, b.color);
        case Step2SortColumn.clarity:
          return (_clarityRank(a.clarity)).compareTo(_clarityRank(b.clarity)) *
              mul;
        case Step2SortColumn.cut:
          return cmpStr(a.cut, b.cut);
        case Step2SortColumn.priceInr:
          return cmpNum(_toDoubleSafe(a.priceInr), _toDoubleSafe(b.priceInr));
        case Step2SortColumn.certification:
          return cmpStr(a.certification, b.certification);
        case Step2SortColumn.lotNumber:
          return cmpStr(a.lotNumber ?? '', b.lotNumber ?? '');
      }
    });

    return list;
  }

  // ---------------- APPLY FILTERS (API) ----------------
  void _applyFiltersAndFetchDiamonds() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_stockCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing stockCode. Go back to Step 1 and search ring.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final chips = <String>[];

    if (_priceFromCtrl.text.trim().isNotEmpty) {
      chips.add('PRICE FROM: ${_priceFromCtrl.text.trim()}');
    }
    if (_priceToCtrl.text.trim().isNotEmpty) {
      chips.add('PRICE TO: ${_priceToCtrl.text.trim()}');
    }
    if (_caratFromCtrl.text.trim().isNotEmpty) {
      chips.add('CARAT FROM: ${_caratFromCtrl.text.trim()}');
    }
    if (_caratToCtrl.text.trim().isNotEmpty) {
      chips.add('CARAT TO: ${_caratToCtrl.text.trim()}');
    }

    if (_shape.trim().isNotEmpty) chips.add('SHAPE: ${_shape.trim()}');

    if (_colors.isNotEmpty) chips.add('COLOR: ${_colors.join(", ")}');
    if (_clarities.isNotEmpty) chips.add('CLARITY: ${_clarities.join(", ")}');
    if (_cuts.isNotEmpty) chips.add('CUT: ${_cuts.join(", ")}');
    if (_certificates.isNotEmpty) chips.add('CERT: ${_certificates.join(", ")}');

    setState(() {
      _filtersApplied = true;
      _selectedIndex = null;
      _chips
        ..clear()
        ..addAll(chips);
    });

    context.read<FilterDiamondsBloc>().add(
          FetchFilterDiamonds(
            cseId: _cseId,
            stockCode: _stockCode,
            shape: _shape,
            priceMin: _priceFromCtrl.text.trim().isEmpty
                ? null
                : _priceFromCtrl.text.trim(),
            priceMax: _priceToCtrl.text.trim().isEmpty
                ? null
                : _priceToCtrl.text.trim(),
            caratMin: _caratFromCtrl.text.trim().isEmpty
                ? null
                : _caratFromCtrl.text.trim(),
            caratMax: _caratToCtrl.text.trim().isEmpty
                ? null
                : _caratToCtrl.text.trim(),
            colors: _colors,
            clarities: _clarities,
            cuts: _cuts,
            certificates: _certificates,
          ),
        );
  }

  void _clearFilters() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _priceFromCtrl.clear();
      _priceToCtrl.clear();
      _caratFromCtrl.clear();
      _caratToCtrl.clear();
      _searchCtrl.clear();

      _colors = [];
      _clarities = [];
      _cuts = [];
      _certificates = [];

      _chips.clear();
      _selectedIndex = null;
      _filtersApplied = false;

      _allDiamonds = [];
      _visibleDiamonds = [];

      _sortDir = Step2SortDir.none;
      _sortColumn = Step2SortColumn.carat;

      _clearLocalSearchFieldsOnly();
    });

    context.read<FilterDiamondsBloc>().add(const ClearFilterDiamonds());
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 900;
    final isWide = w >= 1200;

    return BlocListener<FilterOptionsBloc, FilterOptionsState>(
      listenWhen: (_, c) => c is FilterShapesLoaded || c is FilterOptionsLoaded,
      listener: (_, state) {
        if (state is FilterShapesLoaded) _applyApiShapesToUi(state);
        if (state is FilterOptionsLoaded) _applyApiOptionsToUi(state);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: isWide ? 1280 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Step2OriginalProductBanner(
                        isTablet: isTablet,
                        stockCode: _bannerStockCode,
                        solitaireWt: _bannerSolitaireWt,
                        solitaireAmount: _bannerSolitaireAmount,
                        grossWt: _bannerGrossWt,
                        totalAmount: _bannerTotalAmount,
                        lob: _bannerLob,
                      ),
                      const SizedBox(height: 16),

                      // ---------------- FILTER CARD ----------------
                      BlocBuilder<FilterOptionsBloc, FilterOptionsState>(
                        builder: (context, state) {
                          final loading = state is FilterOptionsLoading;

                          return Stack(
                            children: [
                              Step2FiltersCard(
                                isTablet: isTablet,
                                priceFromCtrl: _priceFromCtrl,
                                priceToCtrl: _priceToCtrl,
                                caratFromCtrl: _caratFromCtrl,
                                caratToCtrl: _caratToCtrl,
                                searchCtrl: _searchCtrl,
                                shape: _shape,
                                shapeOptions: _shapeOptions,
                                onShapeChanged: _onShapeChanged,
                                colors: _colors,
                                clarities: _clarities,
                                cuts: _cuts,
                                certificates: _certificates,
                                colorOptions: _colorOptions,
                                clarityOptions: _clarityOptions,
                                cutOptions: _cutOptions,
                                certificateOptions: _certificateOptions,
                                selectedFilters: _chips,
                                onColorsChanged: (v) =>
                                    setState(() => _colors = v),
                                onClaritiesChanged: (v) =>
                                    setState(() => _clarities = v),
                                onCutsChanged: (v) => setState(() => _cuts = v),
                                onCertificatesChanged: (v) =>
                                    setState(() => _certificates = v),
                                onApply: _applyFiltersAndFetchDiamonds,
                                onClear: _clearFilters,
                                onSearchChanged: (_) {},
                                onSearchClear: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                                onRemoveChip: (chip) {
                                  setState(() => _chips.remove(chip));
                                },
                              ),
                              if (loading)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.white.withOpacity(0.55),
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ---------------- RESULTS / PLACEHOLDER ----------------
                      if (!_filtersApplied) ...[
                        _emptyApplyFiltersPlaceholder(),
                        const SizedBox(height: 80),
                      ] else ...[
                        BlocConsumer<FilterDiamondsBloc, FilterDiamondsState>(
                          listener: (context, state) {
                            if (state is FilterDiamondsLoaded) {
                              _setNewApiResults(state.diamonds);
                            }
                          },
                          builder: (context, state) {
                            if (state is FilterDiamondsLoading) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 18),
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is FilterDiamondsError) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  state.message,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }

                            final rowsRaw = _mapDiamondsToRows(_visibleDiamonds);
                            final rows = _applyLocalSort(rowsRaw);

                            final total = (state is FilterDiamondsLoaded)
                                ? state.totalCount
                                : _visibleDiamonds.length;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.diamond_outlined,
                                      size: 20,
                                      color: Color(0xFF0B2E5E),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Available ${_shape.toUpperCase()} Solitaires ($total found)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                Step2SearchWithinResultsCard(
                                  isTablet: isTablet,
                                  lotCtrl: _lotSearchCtrl,
                                  certCtrl: _certSearchCtrl,
                                  caratMinCtrl: _caratSearchMinCtrl,
                                  caratMaxCtrl: _caratSearchMaxCtrl,
                                  priceMinCtrl: _priceSearchMinCtrl,
                                  priceMaxCtrl: _priceSearchMaxCtrl,
                                  onSearch: _applyLocalSearch,
                                  onClear: _clearLocalSearch,
                                ),

                                const SizedBox(height: 14),

                                if (isTablet)
                                  Step2ResultsTable(
                                    rows: rows,
                                    selectedIndex: _selectedIndex,
                                    onSelect: (i) =>
                                        setState(() => _selectedIndex = i),
                                    sortColumn: _sortColumn,
                                    sortDir: _sortDir,
                                    onSortTap: _onLocalSortTap,
                                  )
                                else
                                  ListView.separated(
                                    itemCount: rows.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (_, i) =>
                                        Step2ResultMobileCard(
                                      row: rows[i],
                                      selected: _selectedIndex == i,
                                      onTap: () =>
                                          setState(() => _selectedIndex = i),
                                    ),
                                  ),

                                const SizedBox(height: 80),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Sticky button only when results visible
            if (_filtersApplied)
              Positioned(
                right: 18,
                bottom: 18,
                child: Step2StickySelectButton(
                  enabled: _selectedIndex != null,
                  onPressed: _selectedIndex == null
                      ? null
                      : () async {
                          if (_stockCode.isEmpty) return;

                          final selectedDiamond =
                              _visibleDiamonds[_selectedIndex!];
                          final diamondId = selectedDiamond.id;

                          final details =
                              await Step2CustomerDetailsDialog.show(context);
                          if (details == null) return;

                          context.read<Step3OrderSummaryBloc>().add(
                                FetchStep3OrderSummary(
                                  cseId: _cseId,
                                  stockCode: _stockCode,
                                  diamondId: diamondId,
                                  customerName: details.name,
                                  customerPhone: details.phone,
                                  customerEmail: details.email.isEmpty
                                      ? null
                                      : details.email,
                                ),
                              );

                          // context.go('/solitaire/step3');
                          final authState = context.read<AuthBloc>().state;
                          if (authState is! AuthAuthenticated) return;
                          final cseId = authState.user.id;
                          context.go(
                            '/solitaire/step3',
                            extra: {
                              'cseId' : cseId,
                              'lob': _bannerLob,
                            },
                          );
                        },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyApplyFiltersPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: const [
          Icon(Icons.search, size: 34, color: Color(0xFF9E9E9E)),
          SizedBox(height: 12),
          Text(
            'Apply Filters to Search',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Color(0xFF9E9E9E),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Please select your criteria from the filters above and click "Apply Filters" to view available selected shape solitaires.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
