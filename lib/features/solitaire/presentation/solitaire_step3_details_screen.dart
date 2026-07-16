import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';

import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_state.dart';
import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_event.dart';

import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_event.dart';
import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_state.dart';

import 'package:manubhaimlt/features/solitaire/bloc/save_order_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/save_order_event.dart';
import 'package:manubhaimlt/features/solitaire/bloc/save_order_state.dart';

import 'package:manubhaimlt/features/solitaire/data/models/step3_models.dart';
import 'package:manubhaimlt/features/solitaire/data/models/step3_order_summary_models.dart';

import 'widgets/step3_customer_details_banner.dart';
import 'widgets/step3_your_ring_card.dart';
import 'widgets/step3_solitaire_comparison_card.dart';
import 'widgets/step3_pricing_cards_row.dart';
import 'widgets/step3_bottom_actions.dart';
import 'widgets/step3_section_card.dart';
import 'widgets/step3_karat_selection_section.dart';

class SolitaireStep3DetailsScreen extends StatefulWidget {
   SolitaireStep3DetailsScreen({
    super.key,
    this.cseId = '1',
    this.viewMode = false,
    this.viewOrderId,
    this.viewOrderUniqueId,
  });

  String cseId;
  final bool viewMode;
  final String? viewOrderId;
  final String? viewOrderUniqueId;

  @override
  State<SolitaireStep3DetailsScreen> createState() =>
      _SolitaireStep3DetailsScreenState();
}

class _SolitaireStep3DetailsScreenState
    extends State<SolitaireStep3DetailsScreen> {
  bool _requested = false;
  bool _routeExtrasParsed = false;

  String _routeLob = '';
  String? _selectedKarat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_routeExtrasParsed) {
      final extra = GoRouterState.of(context).extra;
      final map =
          (extra is Map<String, dynamic>) ? extra : const <String, dynamic>{};

      _routeLob = (map['lob'] ?? '').toString();
      widget.cseId = map['cseId'] ?? '';
      _routeExtrasParsed = true;
    }

    if (!widget.viewMode) return;
    if (_requested) return;

    final oid = (widget.viewOrderId ?? '').trim();
    if (oid.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<Step3OrderSummaryBloc>().add(
            FetchStep3OrderSummaryByOrderId(
              cseId: widget.cseId,
              orderId: oid,
            ),
          );
    });

    _requested = true;
  }

  String _fmtMoney(String raw) {
    final t = raw.toString().trim();
    if (t.isEmpty) return '₹0.00';

    if (t.startsWith('₹')) return t;

    final cleaned = t.replaceAll(',', '');
    final n = double.tryParse(cleaned);
    if (n == null) return '₹$t';

    final fixed = n.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final dec = parts[1];

    final withCommas = whole.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return '₹$withCommas.$dec';
  }

  String _fmtSignedMoney(String sign, String raw) {
    final amt = _fmtMoney(raw).replaceAll('₹', '');
    final s = sign.trim();
    if (s == '+' || s == '-') return '$s ₹$amt';
    return '₹$amt';
  }

  String _fmtWeight(String raw, {String unit = 'ct'}) {
    final t = raw.toString().trim();
    if (t.isEmpty) return '0 $unit';
    return '$t $unit';
  }

  String _fmtGoldRatePerGram(String raw) {
    final t = raw.toString().trim();
    if (t.isEmpty || t == '0' || t == '0.0' || t == '0.00') return '';
    return '${_fmtMoney(t)}/gm';
  }

  double _toDoubleSafe(String raw) {
    final cleaned =
        raw.toString().replaceAll('₹', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _moneyFromDouble(double value) {
    return _fmtMoney(value.toStringAsFixed(2));
  }

  bool get _isLgFlow => _routeLob.trim().toUpperCase() == 'LG';

  KaratOptionVm? _findSelectedKaratOption(
    List<KaratOptionVm> options,
    String? karat,
  ) {
    if (karat == null || karat.trim().isEmpty) return null;

    for (final item in options) {
      if (item.karat.toLowerCase() == karat.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  Map<String, dynamic> _buildOriginalProductMap(OriginalProductVm op) {
    return {
      'stock_code': op.stockCode,
      'stock_image': op.stockImage,
      'gross_wt': op.grossWt,
      'net_wt': op.netWt,
      'labour_amount': op.labourAmount,
      'metal_amount': op.metalAmount,
      'diamond_wt': op.diamondWt,
      'diamond_amount': op.diamondAmount,
      'solitaire_wt': op.solitaireWt,
      'solitaire_amount': op.solitaireAmount,
      'total_amount': op.totalAmount,
    };
  }

  Map<String, dynamic> _buildPriceCalculationMap(
    PriceCalculationVm calc, {
    KaratOptionVm? selectedKaratOption,
  }) {
    return {
      'original_solitaire_wt': calc.originalSolitaireWt,
      'original_solitaire_amount': calc.originalSolitaireAmount,
      'original_total_amount': calc.originalTotalAmount,
      'selected_diamond_wt': calc.selectedDiamondWt,
      'selected_diamond_price': calc.selectedDiamondPrice,
      'weight_difference': calc.weightDifference,
      'price_difference': calc.priceDifference,
      'price_difference_sign': calc.priceDifferenceSign,
      'final_total_amount':
          selectedKaratOption?.finalPrice ??
              (calc.finalPriceWithKarat.isNotEmpty
                  ? calc.finalPriceWithKarat
                  : calc.finalTotalAmount),
      'selected_karat': selectedKaratOption?.karat ??
          (calc.selectedKarat.isNotEmpty ? calc.selectedKarat : calc.currentKarat),
      'net_weight': selectedKaratOption?.netWeight ?? calc.netWeight,
      'labour_amount': selectedKaratOption?.labour ?? calc.labourAmount,
      'diamond_amount':
          selectedKaratOption?.smallDiamonds ?? calc.diamondAmount,
      'gold_rate': selectedKaratOption?.goldRate ?? calc.goldRatePerGram,
      'gold_cost': selectedKaratOption?.goldCost ?? calc.goldCost,
      'small_diamonds': selectedKaratOption?.smallDiamonds ?? '',
      'per_carat_price': selectedKaratOption?.perCaratPrice ?? '',
      'solitaire_weight':
          selectedKaratOption?.solitaireWeight ?? calc.selectedDiamondWt,
      'solitaire_cost':
          selectedKaratOption?.solitaireCost ?? calc.selectedDiamondPrice,
    };
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 900;
    final isWide = w >= 1200;

    return MultiBlocListener(
      listeners: [
        BlocListener<ConfirmOrderBloc, ConfirmOrderState>(
          listener: (context, confirmState) {
            if (confirmState is ConfirmOrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(confirmState.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<SaveOrderBloc, SaveOrderState>(
          listener: (context, saveState) {
            if (saveState is SaveOrderSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(saveState.response.message),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/saved-orders?refresh=1');
            }

            if (saveState is SaveOrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(saveState.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<SaveOrderBloc, SaveOrderState>(
        builder: (context, saveState) {
          final saving = saveState is SaveOrderLoading;

          return Stack(
            children: [
              BlocBuilder<Step3OrderSummaryBloc, Step3OrderSummaryState>(
                builder: (context, state) {
                  if (state is Step3OrderSummaryLoading) {
                    return const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  if (state is Step3OrderSummaryError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is! Step3OrderSummaryLoaded) {
                    return const Center(
                      child: Text(
                        'No order summary loaded.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    );
                  }

                  final Step3OrderSummaryVm s = state.summary;
                  final CustomerDetailsVm c = s.customerDetails;
                  final OriginalProductVm op = s.originalProduct;
                  final SelectedDiamondVm d = s.selectedDiamond;
                  final PriceCalculationVm calc = s.priceCalculation;
                  final SolitaireComparisonVm comp = s.solitaireComparison;

                  final showKaratSection =
                      !widget.viewMode && calc.karatOptions.isNotEmpty;

                  final savedOrderSelectedKarat = calc.selectedKarat.trim();
                  final savedOrderGoldRate = calc.goldRatePerGram.trim();
                  final savedOrderGoldCost = calc.goldCost.trim();

                  final effectiveSelectedKarat = widget.viewMode
                      ? (savedOrderSelectedKarat.isNotEmpty
                          ? savedOrderSelectedKarat
                          : null)
                      : (_selectedKarat ??
                          (calc.currentKarat.trim().isNotEmpty
                              ? calc.currentKarat
                              : (showKaratSection
                                  ? calc.karatOptions.first.karat
                                  : null)));

                  final selectedKaratOption = _findSelectedKaratOption(
                    calc.karatOptions,
                    effectiveSelectedKarat,
                  );

                  final selectedFinalTotalValue = widget.viewMode
                      ? _toDoubleSafe(
                          calc.finalPriceWithKarat.isNotEmpty
                              ? calc.finalPriceWithKarat
                              : calc.finalTotalAmount,
                        )
                      : _toDoubleSafe(
                          selectedKaratOption?.finalPrice ??
                              (calc.finalPriceWithKarat.isNotEmpty
                                  ? calc.finalPriceWithKarat
                                  : calc.finalTotalAmount),
                        );

                  final originalTotalValue =
                      _toDoubleSafe(calc.originalTotalAmount);
                  // final derivedDifference =
                  //     selectedFinalTotalValue - originalTotalValue;
                  final derivedDifference  = calc.priceDifference;
                  final derivedDifferenceSign = calc.priceDifferenceSign;
                  
                  // final derivedDifferenceSign =
                  //     derivedDifference >= 0 ? '+' : '-';

                  final originalVm = ComparisonVm(
                    title: 'Original Solitaire',
                    weight: '${comp.before.weight} ct',
                    amount: _fmtMoney(comp.before.amount),
                  );

                  final selectedVm = ComparisonVm(
                    title: 'Selected Solitaire',
                    lotNumber: comp.after.lotNumber,
                    weight: '${comp.after.weight} ct',
                    amount: _fmtMoney(comp.after.amount),
                    shape: d.shape,
                    color: comp.after.color,
                    clarity: comp.after.clarity,
                    cut: comp.after.cut,
                    cert: comp.after.cert,
                    certNo: d.certNo,
                  );

                  final originalRows = <PricingRowVm>[
                    PricingRowVm(
                      label: 'Labour Amount:',
                      value: _fmtMoney(op.labourAmount),
                    ),
                    PricingRowVm(
                      label: 'Metal Amount:',
                      value: _fmtMoney(op.metalAmount),
                    ),
                    PricingRowVm(
                      label: 'Diamond Amount:',
                      value: _fmtMoney(op.diamondAmount),
                    ),
                    PricingRowVm(
                      label: 'Original Solitaire:',
                      value: _fmtMoney(op.solitaireAmount),
                    ),
                  ];

                  final finalRows = <PricingRowVm>[
                    PricingRowVm(
                      label: 'Original Total:',
                      value: _fmtMoney(calc.originalTotalAmount),
                    ),
                    PricingRowVm(
                      label: 'Original Solitaire:',
                      value: _fmtSignedMoney('-', calc.originalSolitaireAmount),
                    ),
                    PricingRowVm(
                      label: 'New Solitaire:',
                      value: _fmtSignedMoney(
                        '+',
                        widget.viewMode
                            ? calc.selectedDiamondPrice
                            : (selectedKaratOption?.solitaireCost ??
                                calc.selectedDiamondPrice),
                      ),
                    ),
                    PricingRowVm(
                      label: 'Price Difference:',
                      value: _fmtSignedMoney(
                        derivedDifferenceSign,
                        derivedDifference,
                        // derivedDifference.abs().toStringAsFixed(2),
                      ),
                    ),
                  ];

                  final selectedKaratForSummary = widget.viewMode
                      ? savedOrderSelectedKarat
                      : effectiveSelectedKarat;

                  final selectedGoldRateForSummary = widget.viewMode
                      ? _fmtGoldRatePerGram(savedOrderGoldRate)
                      : ((selectedKaratOption?.goldRate ?? '').trim().isEmpty
                          ? ''
                          : '${_fmtMoney(selectedKaratOption!.goldRate)}/gm');

                  final selectedGoldCostForSummary = widget.viewMode
                      ? _fmtMoney(savedOrderGoldCost)
                      : _fmtMoney(selectedKaratOption?.goldCost ?? '');

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWide ? 1280 : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Step3CustomerDetailsBanner(
                              name: c.name,
                              phone: c.phone,
                            ),
                            const SizedBox(height: 16),

                            if (isTablet)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Step3YourRingCard(
                                      stockCode: op.stockCode,
                                      image: op.stockImage,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    flex: 7,
                                    child: _isLgFlow
                                        ? _LgSolitaireComparisonCard(
                                            originalWeight:
                                                _fmtWeight(comp.before.weight),
                                            selectedLotNumber:
                                                comp.after.lotNumber,
                                            selectedWeight:
                                                _fmtWeight(comp.after.weight),
                                            selectedAmount:
                                                _fmtMoney(comp.after.amount),
                                            shape: d.shape,
                                            color: comp.after.color,
                                            clarity: comp.after.clarity,
                                            cut: comp.after.cut,
                                            cert: comp.after.cert,
                                            certNo: d.certNo,
                                          )
                                        : Step3SolitaireComparisonCard(
                                            original: originalVm,
                                            selected: selectedVm,
                                          ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  Step3YourRingCard(
                                    stockCode: op.stockCode,
                                    image: op.stockImage,
                                  ),
                                  const SizedBox(height: 14),
                                  _isLgFlow
                                      ? _LgSolitaireComparisonCard(
                                          originalWeight:
                                              _fmtWeight(comp.before.weight),
                                          selectedLotNumber:
                                              comp.after.lotNumber,
                                          selectedWeight:
                                              _fmtWeight(comp.after.weight),
                                          selectedAmount:
                                              _fmtMoney(comp.after.amount),
                                          shape: d.shape,
                                          color: comp.after.color,
                                          clarity: comp.after.clarity,
                                          cut: comp.after.cut,
                                          cert: comp.after.cert,
                                          certNo: d.certNo,
                                        )
                                      : Step3SolitaireComparisonCard(
                                          original: originalVm,
                                          selected: selectedVm,
                                        ),
                                ],
                              ),

                            const SizedBox(height: 14),

                            if (!_isLgFlow)
                             Step3PricingCardsRow(
                                originalRows: originalRows,
                                originalTotal:
                                    _fmtMoney(calc.originalTotalAmount),
                                finalRows: finalRows,
                                finalTotal:
                                    _moneyFromDouble(selectedFinalTotalValue),
                                showSavedOrderKaratSummary: widget.viewMode,
                                selectedKarat: selectedKaratForSummary,
                                selectedGoldRate: selectedGoldRateForSummary,
                                selectedGoldCost: selectedGoldCostForSummary,
                              ),

                            if (!_isLgFlow) const SizedBox(height: 14),

                            if (showKaratSection)
                              Step3KaratSelectionSection(
                                options: calc.karatOptions,
                                selectedKarat: effectiveSelectedKarat,
                                onSelect: (karat) {
                                  setState(() {
                                    _selectedKarat = karat;
                                  });
                                },
                              ),

                            const SizedBox(height: 18),

                            Step3BottomActions(
                              viewMode: widget.viewMode,
                              viewingText: widget.viewMode
                                  ? 'Viewing Saved Order - Order ID: ${widget.viewOrderUniqueId ?? s.orderInfo?.orderUniqueId ?? (widget.viewOrderId ?? '')}'
                                  : null,
                              confirmText: 'Save Order',
                              onBack: () {
                                if (widget.viewMode) {
                                  context.pop();
                                  return;
                                }
                                final authState =
                                    context.read<AuthBloc>().state;
                                if (authState is! AuthAuthenticated) return;
                                final cseId = authState.user.id;

                                context.go(
                                  '/solitaire/step2',
                                  extra: {
                                    'cseId': cseId,
                                    'stockCode': op.stockCode,
                                    'solitaireWt': op.solitaireWt,
                                    'solitaireAmount': op.solitaireAmount,
                                    'grossWt': op.grossWt,
                                    'totalAmount': op.totalAmount,
                                    'lob': _routeLob,
                                  },
                                );
                              },
                              onConfirm: widget.viewMode
                                  ? () {}
                                  : (saving
                                      ? () {}
                                      : () {
                                          final resolvedSelectedKarat =
                                              (effectiveSelectedKarat ?? '')
                                                  .trim();

                                          if (showKaratSection &&
                                              resolvedSelectedKarat.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please select your preferred gold karat.',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          final originalProductMap =
                                              _buildOriginalProductMap(op);

                                          final priceCalculationMap =
                                              _buildPriceCalculationMap(
                                            calc,
                                            selectedKaratOption:
                                                selectedKaratOption,
                                          );

                                          context.read<SaveOrderBloc>().add(
                                                SubmitSaveOrder(
                                                  cseId: widget.cseId,
                                                  stockCode: op.stockCode,
                                                  diamondId: d.id,
                                                  customerName: c.name,
                                                  customerPhone: c.phone,
                                                  customerEmail: c.email,
                                                  selectedKarat:
                                                      resolvedSelectedKarat,
                                                  originalProduct:
                                                      originalProductMap,
                                                  priceCalculation:
                                                      priceCalculationMap,
                                                ),
                                              );
                                        }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (saving && !widget.viewMode)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.6),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LgSolitaireComparisonCard extends StatelessWidget {
  final String originalWeight;
  final String selectedLotNumber;
  final String selectedWeight;
  final String selectedAmount;
  final String shape;
  final String color;
  final String clarity;
  final String cut;
  final String cert;
  final String certNo;

  const _LgSolitaireComparisonCard({
    required this.originalWeight,
    required this.selectedLotNumber,
    required this.selectedWeight,
    required this.selectedAmount,
    required this.shape,
    required this.color,
    required this.clarity,
    required this.cut,
    required this.cert,
    required this.certNo,
  });

  @override
  Widget build(BuildContext context) {
    return Step3SectionCard(
      icon: Icons.diamond_outlined,
      title: 'Solitaire Comparison',
      child: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 520;

          if (isNarrow) {
            return Column(
              children: [
                _originalBox(),
                const SizedBox(height: 12),
                const Icon(
                  Icons.arrow_downward,
                  color: Color(0xFF4D6DFF),
                  size: 28,
                ),
                const SizedBox(height: 12),
                _selectedBox(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _originalBox()),
              const SizedBox(width: 16),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFF4D6DFF),
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(child: _selectedBox()),
            ],
          );
        },
      ),
    );
  }

  Widget _originalBox() {
    return _boxed(
      border: const Color(0xFFE0B300),
      title: 'Original Solitaire',
      titleIcon: Icons.warning_amber_rounded,
      titleColor: const Color(0xFF7A5C00),
      rows: [
        _kv('Weight', originalWeight),
      ],
    );
  }

  Widget _selectedBox() {
    return _boxed(
      border: const Color(0xFF2EAD4A),
      title: 'Selected Solitaire',
      titleIcon: Icons.check_circle,
      titleColor: const Color(0xFF1E6E31),
      rows: [
        _kv('Lot Number', selectedLotNumber),
        _kv('Weight', selectedWeight),
        _kv('Amount', selectedAmount),
        const SizedBox(height: 6),
        _twoCol(
          leftLabel: 'Shape',
          leftValue: shape,
          rightLabel: 'Color',
          rightValue: color,
        ),
        _twoCol(
          leftLabel: 'Clarity',
          leftValue: clarity,
          rightLabel: 'Cut',
          rightValue: cut,
        ),
        _twoCol(
          leftLabel: 'Cert',
          leftValue: cert,
          rightLabel: 'Cert No',
          rightValue: certNo,
        ),
      ],
    );
  }

  Widget _boxed({
    required Color border,
    required String title,
    required IconData titleIcon,
    required Color titleColor,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.6),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(titleIcon, size: 18, color: titleColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                k,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF616161),
                ),
              ),
            ),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _twoCol({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '$leftLabel: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF616161),
                  ),
                ),
                Expanded(
                  child: Text(
                    leftValue,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  '$rightLabel: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF616161),
                  ),
                ),
                Expanded(
                  child: Text(
                    rightValue,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//===========================================//
//===========================================//
//===========================================//


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';

// import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_bloc.dart';
// import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_state.dart';
// import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_event.dart';

// import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_bloc.dart';
// import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_event.dart';
// import 'package:manubhaimlt/features/solitaire/bloc/confirm_order_state.dart';

// import 'package:manubhaimlt/features/solitaire/bloc/save_order_bloc.dart';
// import 'package:manubhaimlt/features/solitaire/bloc/save_order_event.dart';
// import 'package:manubhaimlt/features/solitaire/bloc/save_order_state.dart';

// import 'package:manubhaimlt/features/solitaire/data/models/step3_models.dart';
// import 'package:manubhaimlt/features/solitaire/data/models/step3_order_summary_models.dart';

// import 'widgets/step3_customer_details_banner.dart';
// import 'widgets/step3_your_ring_card.dart';
// import 'widgets/step3_solitaire_comparison_card.dart';
// import 'widgets/step3_pricing_cards_row.dart';
// import 'widgets/step3_bottom_actions.dart';
// import 'widgets/step3_section_card.dart';
// import 'widgets/step3_karat_selection_section.dart';

// class SolitaireStep3DetailsScreen extends StatefulWidget {
//   const SolitaireStep3DetailsScreen({
//     super.key,
//     this.viewMode = false,
//     this.viewOrderId,
//     this.viewOrderUniqueId,
//   });

//   final bool viewMode;
//   final String? viewOrderId;
//   final String? viewOrderUniqueId;

//   @override
//   State<SolitaireStep3DetailsScreen> createState() =>
//       _SolitaireStep3DetailsScreenState();
// }

// class _SolitaireStep3DetailsScreenState
//     extends State<SolitaireStep3DetailsScreen> {
//   bool _requested = false;
//   bool _routeExtrasParsed = false;

//   String _routeLob = '';
//   String? _selectedKarat;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     if (!_routeExtrasParsed) {
//       final extra = GoRouterState.of(context).extra;
//       final map =
//           (extra is Map<String, dynamic>) ? extra : const <String, dynamic>{};

//       _routeLob = (map['lob'] ?? '').toString();
//       _routeExtrasParsed = true;
//     }

//     if (!widget.viewMode) return;
//     if (_requested) return;

//     final authState = context.read<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) return;

//     final cseId = authState.user.id;
//     final oid = (widget.viewOrderId ?? '').trim();
//     if (oid.isEmpty) return;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       context.read<Step3OrderSummaryBloc>().add(
//             FetchStep3OrderSummaryByOrderId(
//               cseId: cseId,
//               orderId: oid,
//             ),
//           );
//     });

//     _requested = true;
//   }

//   String _fmtMoney(String raw) {
//     final t = raw.toString().trim();
//     if (t.isEmpty) return '₹0.00';

//     if (t.startsWith('₹')) return t;

//     final cleaned = t.replaceAll(',', '');
//     final n = double.tryParse(cleaned);
//     if (n == null) return '₹$t';

//     final fixed = n.toStringAsFixed(2);
//     final parts = fixed.split('.');
//     final whole = parts[0];
//     final dec = parts[1];

//     final withCommas = whole.replaceAllMapped(
//       RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
//       (m) => '${m[1]},',
//     );

//     return '₹$withCommas.$dec';
//   }

//   String _fmtSignedMoney(String sign, String raw) {
//     final amt = _fmtMoney(raw).replaceAll('₹', '');
//     final s = sign.trim();
//     if (s == '+' || s == '-') return '$s ₹$amt';
//     return '₹$amt';
//   }

//   String _fmtWeight(String raw, {String unit = 'ct'}) {
//     final t = raw.toString().trim();
//     if (t.isEmpty) return '0 $unit';
//     return '$t $unit';
//   }

//   String _fmtGoldRatePerGram(String raw) {
//     final t = raw.toString().trim();
//     if (t.isEmpty || t == '0' || t == '0.0' || t == '0.00') return '';
//     return '${_fmtMoney(t)}/gm';
//   }

//   double _toDoubleSafe(String raw) {
//     final cleaned =
//         raw.toString().replaceAll('₹', '').replaceAll(',', '').trim();
//     return double.tryParse(cleaned) ?? 0.0;
//   }

//   String _moneyFromDouble(double value) {
//     return _fmtMoney(value.toStringAsFixed(2));
//   }

//   bool get _isLgFlow => _routeLob.trim().toUpperCase() == 'LG';

//   KaratOptionVm? _findSelectedKaratOption(
//     List<KaratOptionVm> options,
//     String? karat,
//   ) {
//     if (karat == null || karat.trim().isEmpty) return null;

//     for (final item in options) {
//       if (item.karat.toLowerCase() == karat.toLowerCase()) {
//         return item;
//       }
//     }
//     return null;
//   }

//   Map<String, dynamic> _buildOriginalProductMap(OriginalProductVm op) {
//     return {
//       'stock_code': op.stockCode,
//       'stock_image': op.stockImage,
//       'gross_wt': op.grossWt,
//       'net_wt': op.netWt,
//       'labour_amount': op.labourAmount,
//       'metal_amount': op.metalAmount,
//       'diamond_wt': op.diamondWt,
//       'diamond_amount': op.diamondAmount,
//       'solitaire_wt': op.solitaireWt,
//       'solitaire_amount': op.solitaireAmount,
//       'total_amount': op.totalAmount,
//     };
//   }

//   Map<String, dynamic> _buildPriceCalculationMap(
//     PriceCalculationVm calc, {
//     KaratOptionVm? selectedKaratOption,
//   }) {
//     return {
//       'original_solitaire_wt': calc.originalSolitaireWt,
//       'original_solitaire_amount': calc.originalSolitaireAmount,
//       'original_total_amount': calc.originalTotalAmount,
//       'selected_diamond_wt': calc.selectedDiamondWt,
//       'selected_diamond_price': calc.selectedDiamondPrice,
//       'weight_difference': calc.weightDifference,
//       'price_difference': calc.priceDifference,
//       'price_difference_sign': calc.priceDifferenceSign,
//       'final_total_amount': selectedKaratOption?.finalPrice ??
//           (calc.finalPriceWithKarat.isNotEmpty
//               ? calc.finalPriceWithKarat
//               : calc.finalTotalAmount),
//       'selected_karat': selectedKaratOption?.karat ??
//           (calc.selectedKarat.isNotEmpty
//               ? calc.selectedKarat
//               : calc.currentKarat),
//       'net_weight': selectedKaratOption?.netWeight ?? calc.netWeight,
//       'labour_amount': selectedKaratOption?.labour ?? calc.labourAmount,
//       'diamond_amount': selectedKaratOption?.smallDiamonds ?? calc.diamondAmount,
//       'gold_rate': selectedKaratOption?.goldRate ?? calc.goldRatePerGram,
//       'gold_cost': selectedKaratOption?.goldCost ?? calc.goldCost,
//       'small_diamonds': selectedKaratOption?.smallDiamonds ?? '',
//       'per_carat_price': selectedKaratOption?.perCaratPrice ?? '',
//       'solitaire_weight':
//           selectedKaratOption?.solitaireWeight ?? calc.selectedDiamondWt,
//       'solitaire_cost':
//           selectedKaratOption?.solitaireCost ?? calc.selectedDiamondPrice,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = context.watch<AuthBloc>().state;

//     if (authState is! AuthAuthenticated) {
//       return const Center(
//         child: Text(
//           'User not authenticated.',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//       );
//     }

//     final cseId = authState.user.id;

//     final w = MediaQuery.of(context).size.width;
//     final isTablet = w >= 900;
//     final isWide = w >= 1200;

//     return MultiBlocListener(
//       listeners: [
//         BlocListener<ConfirmOrderBloc, ConfirmOrderState>(
//           listener: (context, confirmState) {
//             if (confirmState is ConfirmOrderError) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(confirmState.message),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//         ),
//         BlocListener<SaveOrderBloc, SaveOrderState>(
//           listener: (context, saveState) {
//             if (saveState is SaveOrderSuccess) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(saveState.response.message),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//               context.go('/saved-orders?refresh=1');
//             }

//             if (saveState is SaveOrderError) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(saveState.message),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//         ),
//       ],
//       child: BlocBuilder<SaveOrderBloc, SaveOrderState>(
//         builder: (context, saveState) {
//           final saving = saveState is SaveOrderLoading;

//           return Stack(
//             children: [
//               BlocBuilder<Step3OrderSummaryBloc, Step3OrderSummaryState>(
//                 builder: (context, state) {
//                   if (state is Step3OrderSummaryLoading) {
//                     return const Center(
//                       child: SizedBox(
//                         width: 30,
//                         height: 30,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                     );
//                   }

//                   if (state is Step3OrderSummaryError) {
//                     return Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(18),
//                         child: Text(
//                           state.message,
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                     );
//                   }

//                   if (state is! Step3OrderSummaryLoaded) {
//                     return const Center(
//                       child: Text(
//                         'No order summary loaded.',
//                         style: TextStyle(fontWeight: FontWeight.w700),
//                       ),
//                     );
//                   }

//                   final Step3OrderSummaryVm s = state.summary;
//                   final CustomerDetailsVm c = s.customerDetails;
//                   final OriginalProductVm op = s.originalProduct;
//                   final SelectedDiamondVm d = s.selectedDiamond;
//                   final PriceCalculationVm calc = s.priceCalculation;
//                   final SolitaireComparisonVm comp = s.solitaireComparison;

//                   final showKaratSection =
//                       !widget.viewMode && calc.karatOptions.isNotEmpty;

//                   final savedOrderSelectedKarat = calc.selectedKarat.trim();
//                   final savedOrderGoldRate = calc.goldRatePerGram.trim();
//                   final savedOrderGoldCost = calc.goldCost.trim();

//                   final effectiveSelectedKarat = widget.viewMode
//                       ? (savedOrderSelectedKarat.isNotEmpty
//                           ? savedOrderSelectedKarat
//                           : null)
//                       : _selectedKarat;

//                   final isSaveEnabled = widget.viewMode ||
//                       !showKaratSection ||
//                       (effectiveSelectedKarat?.trim().isNotEmpty == true);

//                   final selectedKaratOption = _findSelectedKaratOption(
//                     calc.karatOptions,
//                     effectiveSelectedKarat,
//                   );

//                   final selectedFinalTotalValue = widget.viewMode
//                       ? _toDoubleSafe(
//                           calc.finalPriceWithKarat.isNotEmpty
//                               ? calc.finalPriceWithKarat
//                               : calc.finalTotalAmount,
//                         )
//                       : _toDoubleSafe(
//                           selectedKaratOption?.finalPrice ??
//                               (calc.finalPriceWithKarat.isNotEmpty
//                                   ? calc.finalPriceWithKarat
//                                   : calc.finalTotalAmount),
//                         );

//                   final derivedDifference = calc.priceDifference;
//                   final derivedDifferenceSign = calc.priceDifferenceSign;

//                   final originalVm = ComparisonVm(
//                     title: 'Original Solitaire',
//                     weight: '${comp.before.weight} ct',
//                     amount: _fmtMoney(comp.before.amount),
//                   );

//                   final selectedVm = ComparisonVm(
//                     title: 'Selected Solitaire',
//                     lotNumber: comp.after.lotNumber,
//                     weight: '${comp.after.weight} ct',
//                     amount: _fmtMoney(comp.after.amount),
//                     shape: d.shape,
//                     color: comp.after.color,
//                     clarity: comp.after.clarity,
//                     cut: comp.after.cut,
//                     cert: comp.after.cert,
//                     certNo: d.certNo,
//                   );

//                   final originalRows = <PricingRowVm>[
//                     PricingRowVm(
//                       label: 'Labour Amount:',
//                       value: _fmtMoney(op.labourAmount),
//                     ),
//                     PricingRowVm(
//                       label: 'Metal Amount:',
//                       value: _fmtMoney(op.metalAmount),
//                     ),
//                     PricingRowVm(
//                       label: 'Diamond Amount:',
//                       value: _fmtMoney(op.diamondAmount),
//                     ),
//                     PricingRowVm(
//                       label: 'Original Solitaire:',
//                       value: _fmtMoney(op.solitaireAmount),
//                     ),
//                   ];

//                   final finalRows = <PricingRowVm>[
//                     PricingRowVm(
//                       label: 'Original Total:',
//                       value: _fmtMoney(calc.originalTotalAmount),
//                     ),
//                     PricingRowVm(
//                       label: 'Original Solitaire:',
//                       value: _fmtSignedMoney('-', calc.originalSolitaireAmount),
//                     ),
//                     PricingRowVm(
//                       label: 'New Solitaire:',
//                       value: _fmtSignedMoney(
//                         '+',
//                         widget.viewMode
//                             ? calc.selectedDiamondPrice
//                             : (selectedKaratOption?.solitaireCost ??
//                                 calc.selectedDiamondPrice),
//                       ),
//                     ),
//                     PricingRowVm(
//                       label: 'Price Difference:',
//                       value: _fmtSignedMoney(
//                         derivedDifferenceSign,
//                         derivedDifference,
//                       ),
//                     ),
//                   ];

//                   final selectedKaratForSummary = widget.viewMode
//                       ? savedOrderSelectedKarat
//                       : effectiveSelectedKarat;

//                   final selectedGoldRateForSummary = widget.viewMode
//                       ? _fmtGoldRatePerGram(savedOrderGoldRate)
//                       : ((selectedKaratOption?.goldRate ?? '').trim().isEmpty
//                           ? ''
//                           : '${_fmtMoney(selectedKaratOption!.goldRate)}/gm');

//                   final selectedGoldCostForSummary = widget.viewMode
//                       ? _fmtMoney(savedOrderGoldCost)
//                       : _fmtMoney(selectedKaratOption?.goldCost ?? '');

//                   return SingleChildScrollView(
//                     padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
//                     child: Center(
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           maxWidth: isWide ? 1280 : double.infinity,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             Step3CustomerDetailsBanner(
//                               name: c.name,
//                               phone: c.phone,
//                             ),
//                             const SizedBox(height: 16),
//                             if (isTablet)
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     flex: 5,
//                                     child: Step3YourRingCard(
//                                       stockCode: op.stockCode,
//                                       image: op.stockImage,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 14),
//                                   Expanded(
//                                     flex: 7,
//                                     child: _isLgFlow
//                                         ? _LgSolitaireComparisonCard(
//                                             originalWeight:
//                                                 _fmtWeight(comp.before.weight),
//                                             selectedLotNumber:
//                                                 comp.after.lotNumber,
//                                             selectedWeight:
//                                                 _fmtWeight(comp.after.weight),
//                                             selectedAmount:
//                                                 _fmtMoney(comp.after.amount),
//                                             shape: d.shape,
//                                             color: comp.after.color,
//                                             clarity: comp.after.clarity,
//                                             cut: comp.after.cut,
//                                             cert: comp.after.cert,
//                                             certNo: d.certNo,
//                                           )
//                                         : Step3SolitaireComparisonCard(
//                                             original: originalVm,
//                                             selected: selectedVm,
//                                           ),
//                                   ),
//                                 ],
//                               )
//                             else
//                               Column(
//                                 children: [
//                                   Step3YourRingCard(
//                                     stockCode: op.stockCode,
//                                     image: op.stockImage,
//                                   ),
//                                   const SizedBox(height: 14),
//                                   _isLgFlow
//                                       ? _LgSolitaireComparisonCard(
//                                           originalWeight:
//                                               _fmtWeight(comp.before.weight),
//                                           selectedLotNumber:
//                                               comp.after.lotNumber,
//                                           selectedWeight:
//                                               _fmtWeight(comp.after.weight),
//                                           selectedAmount:
//                                               _fmtMoney(comp.after.amount),
//                                           shape: d.shape,
//                                           color: comp.after.color,
//                                           clarity: comp.after.clarity,
//                                           cut: comp.after.cut,
//                                           cert: comp.after.cert,
//                                           certNo: d.certNo,
//                                         )
//                                       : Step3SolitaireComparisonCard(
//                                           original: originalVm,
//                                           selected: selectedVm,
//                                         ),
//                                 ],
//                               ),
//                             const SizedBox(height: 14),
//                             if (!_isLgFlow)
//                               Step3PricingCardsRow(
//                                 originalRows: originalRows,
//                                 originalTotal:
//                                     _fmtMoney(calc.originalTotalAmount),
//                                 finalRows: finalRows,
//                                 finalTotal:
//                                     _moneyFromDouble(selectedFinalTotalValue),
//                                 showSavedOrderKaratSummary: widget.viewMode,
//                                 selectedKarat: selectedKaratForSummary,
//                                 selectedGoldRate: selectedGoldRateForSummary,
//                                 selectedGoldCost: selectedGoldCostForSummary,
//                               ),
//                             if (!_isLgFlow) const SizedBox(height: 14),
//                             if (showKaratSection)
//                               Step3KaratSelectionSection(
//                                 options: calc.karatOptions,
//                                 selectedKarat: effectiveSelectedKarat,
//                                 onSelect: (karat) {
//                                   setState(() {
//                                     _selectedKarat = karat;
//                                   });
//                                 },
//                               ),
//                             const SizedBox(height: 18),
//                             Step3BottomActions(
//                               viewMode: widget.viewMode,
//                               viewingText: widget.viewMode
//                                   ? 'Viewing Saved Order - Order ID: ${widget.viewOrderUniqueId ?? s.orderInfo?.orderUniqueId ?? (widget.viewOrderId ?? '')}'
//                                   : null,
//                               confirmText: 'Save Order',
//                               onBack: () {
//                                 if (widget.viewMode) {
//                                   context.pop();
//                                   return;
//                                 }

//                                 context.go(
//                                   '/solitaire/step2',
//                                   extra: {
//                                     'stockCode': op.stockCode,
//                                     'solitaireWt': op.solitaireWt,
//                                     'solitaireAmount': op.solitaireAmount,
//                                     'grossWt': op.grossWt,
//                                     'totalAmount': op.totalAmount,
//                                     'lob': _routeLob,
//                                   },
//                                 );
//                               },
//                               onConfirm: widget.viewMode
//                                   ? () {}
//                                   : (saving
//                                       ? () {}
//                                       : () {
//                                           final resolvedSelectedKarat =
//                                               (effectiveSelectedKarat ?? '')
//                                                   .trim();

//                                           if (showKaratSection &&
//                                               resolvedSelectedKarat.isEmpty) {
//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(
//                                               const SnackBar(
//                                                 content: Text(
//                                                   'Please select your preferred gold karat.',
//                                                 ),
//                                                 backgroundColor: Colors.red,
//                                               ),
//                                             );
//                                             return;
//                                           }

//                                           final originalProductMap =
//                                               _buildOriginalProductMap(op);

//                                           final priceCalculationMap =
//                                               _buildPriceCalculationMap(
//                                             calc,
//                                             selectedKaratOption:
//                                                 selectedKaratOption,
//                                           );

//                                           context.read<SaveOrderBloc>().add(
//                                                 SubmitSaveOrder(
//                                                   cseId: cseId,
//                                                   stockCode: op.stockCode,
//                                                   diamondId: d.id,
//                                                   customerName: c.name,
//                                                   customerPhone: c.phone,
//                                                   customerEmail: c.email,
//                                                   selectedKarat:
//                                                       resolvedSelectedKarat,
//                                                   originalProduct:
//                                                       originalProductMap,
//                                                   priceCalculation:
//                                                       priceCalculationMap,
//                                                 ),
//                                               );
//                                         }),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               if (saving && !widget.viewMode)
//                 Positioned.fill(
//                   child: Container(
//                     color: Colors.white.withOpacity(0.6),
//                     alignment: Alignment.center,
//                     child: const SizedBox(
//                       width: 34,
//                       height: 34,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _LgSolitaireComparisonCard extends StatelessWidget {
//   final String originalWeight;
//   final String selectedLotNumber;
//   final String selectedWeight;
//   final String selectedAmount;
//   final String shape;
//   final String color;
//   final String clarity;
//   final String cut;
//   final String cert;
//   final String certNo;

//   const _LgSolitaireComparisonCard({
//     required this.originalWeight,
//     required this.selectedLotNumber,
//     required this.selectedWeight,
//     required this.selectedAmount,
//     required this.shape,
//     required this.color,
//     required this.clarity,
//     required this.cut,
//     required this.cert,
//     required this.certNo,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Step3SectionCard(
//       icon: Icons.diamond_outlined,
//       title: 'Solitaire Comparison',
//       child: LayoutBuilder(
//         builder: (context, c) {
//           final isNarrow = c.maxWidth < 520;

//           if (isNarrow) {
//             return Column(
//               children: [
//                 _originalBox(),
//                 const SizedBox(height: 12),
//                 const Icon(
//                   Icons.arrow_downward,
//                   color: Color(0xFF4D6DFF),
//                   size: 28,
//                 ),
//                 const SizedBox(height: 12),
//                 _selectedBox(),
//               ],
//             );
//           }

//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(child: _originalBox()),
//               const SizedBox(width: 16),
//               const Icon(
//                 Icons.arrow_forward,
//                 color: Color(0xFF4D6DFF),
//                 size: 28,
//               ),
//               const SizedBox(width: 16),
//               Expanded(child: _selectedBox()),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _originalBox() {
//     return _boxed(
//       border: const Color(0xFFE0B300),
//       title: 'Original Solitaire',
//       titleIcon: Icons.warning_amber_rounded,
//       titleColor: const Color(0xFF7A5C00),
//       rows: [
//         _kv('Weight', originalWeight),
//       ],
//     );
//   }

//   Widget _selectedBox() {
//     return _boxed(
//       border: const Color(0xFF2EAD4A),
//       title: 'Selected Solitaire',
//       titleIcon: Icons.check_circle,
//       titleColor: const Color(0xFF1E6E31),
//       rows: [
//         _kv('Lot Number', selectedLotNumber),
//         _kv('Weight', selectedWeight),
//         _kv('Amount', selectedAmount),
//         const SizedBox(height: 6),
//         _twoCol(
//           leftLabel: 'Shape',
//           leftValue: shape,
//           rightLabel: 'Color',
//           rightValue: color,
//         ),
//         _twoCol(
//           leftLabel: 'Clarity',
//           leftValue: clarity,
//           rightLabel: 'Cut',
//           rightValue: cut,
//         ),
//         _twoCol(
//           leftLabel: 'Cert',
//           leftValue: cert,
//           rightLabel: 'Cert No',
//           rightValue: certNo,
//         ),
//       ],
//     );
//   }

//   Widget _boxed({
//     required Color border,
//     required String title,
//     required IconData titleIcon,
//     required Color titleColor,
//     required List<Widget> rows,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: border, width: 1.6),
//         color: Colors.white,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(titleIcon, size: 18, color: titleColor),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   color: titleColor,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           ...rows,
//         ],
//       ),
//     );
//   }

//   Widget _kv(String k, String v) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 k,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF616161),
//                 ),
//               ),
//             ),
//             Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
//           ],
//         ),
//         const SizedBox(height: 8),
//         const Divider(height: 1),
//         const SizedBox(height: 8),
//       ],
//     );
//   }

//   Widget _twoCol({
//     required String leftLabel,
//     required String leftValue,
//     required String rightLabel,
//     required String rightValue,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Expanded(
//             child: Row(
//               children: [
//                 Text(
//                   '$leftLabel: ',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF616161),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     leftValue,
//                     style: const TextStyle(fontWeight: FontWeight.w900),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Row(
//               children: [
//                 Text(
//                   '$rightLabel: ',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF616161),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     rightValue,
//                     textAlign: TextAlign.right,
//                     style: const TextStyle(fontWeight: FontWeight.w900),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }