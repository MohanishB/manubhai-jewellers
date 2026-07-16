import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:manubhaimlt/core/widgets/mj_header.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';

import 'package:manubhaimlt/features/solitaire/bloc/saved_orders_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/saved_orders_event.dart';
import 'package:manubhaimlt/features/solitaire/bloc/saved_orders_state.dart';

import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/step3_order_summary_event.dart';
import 'package:manubhaimlt/features/solitaire/data/models/saved_orders_response_model.dart';

import 'widgets/saved_orders_header_banner.dart';
import 'widgets/saved_orders_filter_card.dart';
import 'widgets/saved_orders_count_row.dart';
import 'widgets/saved_orders_table.dart';
import 'widgets/saved_orders_mobile_card.dart';

class SavedOrderVm {
  final String orderPk;
  final String orderUniqueId;

  final DateTime date;
  final String customerName;
  final String phone;
  final String stockCode;
  final String diamondLot;
  final String finalAmount;
  final String? status;

  const SavedOrderVm({
    required this.orderPk,
    required this.orderUniqueId,
    required this.date,
    required this.customerName,
    required this.phone,
    required this.stockCode,
    required this.diamondLot,
    required this.finalAmount,
    this.status,
  });
}

class SavedOrdersScreen extends StatefulWidget {
  
  final bool forceRefresh;
  const SavedOrdersScreen({super.key, this.forceRefresh = false});

  @override
  State<SavedOrdersScreen> createState() => _SavedOrdersScreenState();
}

class _SavedOrdersScreenState extends State<SavedOrdersScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _didInit = false;
  bool _refreshedThisBuild = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _fromDate = DateTime(today.year, today.month, today.day);
    _toDate = DateTime(today.year, today.month, today.day);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _fmtApi(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? _fromDate : _toDate) ?? now;

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  String _resolveCseId(AuthState authState) {
    if (authState is AuthAuthenticated) {
      final cseID = authState.user.id;
      final v = cseID.toString().trim();
      return v.isNotEmpty ? v : '1';
    }
    return '1';
  }

  void _fetch(AuthState authState) {
    final cseId = _resolveCseId(authState);
    final from = _fromDate ?? DateTime.now();
    final to = _toDate ?? DateTime.now();

    context.read<SavedOrdersBloc>().add(
          FetchSavedOrders(
            cseId: cseId,
            fromDate: _fmtApi(from),
            toDate: _fmtApi(to),
            customerName: _nameCtrl.text.trim(),
            customerPhone: _phoneCtrl.text.trim(),
          ),
        );
  }

  // void _onApply(AuthState authState) => _fetch(authState);
  void _onApply(AuthState authState) {
    FocusManager.instance.primaryFocus?.unfocus(); // ✅ dismiss keyboard
    _fetch(authState);
  }

void _onClear(AuthState authState) {
    FocusManager.instance.primaryFocus?.unfocus(); // ✅ dismiss keyboard
    final today = DateTime.now();
    setState(() {
      _fromDate = DateTime(today.year, today.month, today.day);
      _toDate = DateTime(today.year, today.month, today.day);
      _nameCtrl.clear();
      _phoneCtrl.clear();
    });
    _fetch(authState);
  }

  // void _onClear(AuthState authState) {
  //   final today = DateTime.now();
  //   setState(() {
  //     _fromDate = DateTime(today.year, today.month, today.day);
  //     _toDate = DateTime(today.year, today.month, today.day);
  //     _nameCtrl.clear();
  //     _phoneCtrl.clear();
  //   });
  //   _fetch(authState);
  // }

  DateTime _parseOrderDate(String s) {
    try {
      return DateTime.parse(s.replaceFirst(' ', 'T'));
    } catch (_) {
      return DateTime.now();
    }
  }

  String _formatInr(String raw) {
    final v = double.tryParse(raw.trim()) ?? 0.0;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(v);
  }

  List<SavedOrderVm> _mapToVm(List<SavedOrderApiModel> orders) {
    return orders.map((o) {
      final status = o.orderStatus.trim().isEmpty
          ? null
          : o.orderStatus.trim().toUpperCase();

      return SavedOrderVm(
        orderPk: o.orderId,
        orderUniqueId: o.orderUniqueId,
        date: _parseOrderDate(o.orderDate),
        customerName: o.customerName,
        phone: o.customerPhone,
        stockCode: o.stockCode,
        diamondLot: o.selectedLotNumber,
        finalAmount: _formatInr(o.finalTotalAmount),
        status: status,
      );
    }).toList();
  }

  void _onViewOrder(SavedOrderVm order) {
    final authState = context.read<AuthBloc>().state;
    final cseId = _resolveCseId(authState);

    context.read<Step3OrderSummaryBloc>().add(const ClearStep3OrderSummary());

    // Use PUSH so SavedOrdersScreen stays in stack with state
    context.push(
      '/solitaire/step3-view/${order.orderPk}',
      extra: {
        'cseId': cseId,
        'orderUniqueId': order.orderUniqueId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    final String username = (authState is AuthAuthenticated)
        ? (authState.user.firstName.isNotEmpty
            ? authState.user.firstName
            : (authState.user.lastName ?? 'User'))
        : 'User';

    final w = MediaQuery.of(context).size.width;
    final isTablet = w >= 900;
    final isWide = w >= 1200;

    // ✅ initial fetch behavior
   if (!_didInit) {
      _didInit = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // If screen opened with refresh=1, reset filters + refetch
        if (widget.forceRefresh && !_refreshedThisBuild) {
          _refreshedThisBuild = true;

          final today = DateTime.now();
          setState(() {
            _fromDate = DateTime(today.year, today.month, today.day);
            _toDate = DateTime(today.year, today.month, today.day);
            _nameCtrl.clear();
            _phoneCtrl.clear();
          });

          _fetch(authState);
          return;
        }

        // Otherwise keep existing behavior: don’t refetch if bloc already has data
        final s = context.read<SavedOrdersBloc>().state;
        if (s is SavedOrdersLoaded) return;

        _fetch(authState);
      });
    }
    // if (!_didInit) {
    //   _didInit = true;
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;
    //     final s = context.read<SavedOrdersBloc>().state;
    //     if (s is SavedOrdersLoaded) return; // already has results -> keep them
    //     _fetch(authState);
    //   });
    // }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            MJHeader(
              username: username,
              onLogout: () =>
                  context.read<AuthBloc>().add(const AuthLogoutRequested()),
              showHome: true,
              onHomePressed: () => context.go('/project'),
              showBack: true,
              // onBackPressed: () => context.pop(),
              onBackPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/solitaire/step1'); // or '/project' (your choice)
                }
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 1280 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SavedOrdersHeaderBanner(),
                        const SizedBox(height: 18),
                        SavedOrdersFilterCard(
                          isTablet: isTablet,
                          fromDate: _fromDate,
                          toDate: _toDate,
                          nameCtrl: _nameCtrl,
                          phoneCtrl: _phoneCtrl,
                          onPickFromDate: () => _pickDate(isFrom: true),
                          onPickToDate: () => _pickDate(isFrom: false),
                          onApply: () => _onApply(authState),
                          onClear: () => _onClear(authState),
                        ),
                        const SizedBox(height: 18),
                        BlocBuilder<SavedOrdersBloc, SavedOrdersState>(
                          builder: (context, state) {
                            if (state is SavedOrdersLoading) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 14),
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              );
                            }

                            if (state is SavedOrdersError) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  state.message,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            }

                            final loaded =
                                state is SavedOrdersLoaded ? state : null;
                            final vms = loaded == null
                                ? <SavedOrderVm>[]
                                : _mapToVm(loaded.orders);
                            final count = loaded?.totalCount ?? vms.length;
                            final isEmpty =
                                loaded != null && loaded.orders.isEmpty;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SavedOrdersCountRow(count: count),
                                const SizedBox(height: 12),
                                if (isEmpty)
                                  _noOrdersPlaceholder(context)
                                else if (isTablet)
                                  SavedOrdersTable(
                                      rows: vms, onView: _onViewOrder)
                                else
                                  ListView.separated(
                                    itemCount: vms.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (_, i) =>
                                        SavedOrdersMobileCard(
                                      order: vms[i],
                                      onView: () => _onViewOrder(vms[i]),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noOrdersPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😔', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 10),
          const Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF616161),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No saved orders match your filter criteria.',
            textAlign: TextAlign.center,
            // style: TextStyle(
            //   fontWeight: FontWeight.w900,
            //   fontSize: 22,
            //   color: Color(0xFF9E9E9E),
            // ),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 19,
              color: Color(0xFF616161),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text(
                'Try adjusting the filters or ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                   fontSize: 18,
                  color: Color(0xFF616161),
                ),
              ),
              InkWell(
                onTap: () => context.go('/solitaire/step1'),
                child: const Text(
                  'create a new order.',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E5AA8),
                     fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
}
}