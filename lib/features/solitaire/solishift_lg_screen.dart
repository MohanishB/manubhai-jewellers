import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:manubhaimlt/core/theme/app_colors.dart';
import 'package:manubhaimlt/core/theme/app_spacing.dart';
import 'package:manubhaimlt/core/widgets/mj_dropdown_field.dart';
import 'package:manubhaimlt/core/widgets/mj_header.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_search_field.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';
import 'package:manubhaimlt/features/solishift_lg/bloc/solishift_bloc.dart';
import 'package:manubhaimlt/features/solishift_lg/bloc/solishift_event.dart';
import 'package:manubhaimlt/features/solishift_lg/bloc/solishift_state.dart';
import 'package:manubhaimlt/features/solishift_lg/data/models/solishift_stock_model.dart';

class SoliShiftLgScreen extends StatefulWidget {
  const SoliShiftLgScreen({super.key});

  @override
  State<SoliShiftLgScreen> createState() => _SoliShiftLgScreenState();
}

class _SoliShiftLgScreenState extends State<SoliShiftLgScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _solitaireCaratController = TextEditingController();
  final TextEditingController _diamondCaratController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  final GlobalKey _customizeSectionKey = GlobalKey();
  

  @override
  void dispose() {
    _searchController.dispose();
    _solitaireCaratController.dispose();
    _diamondCaratController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _scrollToCustomizeSection() async {
  // Wait for the customize section to be built
  await Future.delayed(const Duration(milliseconds: 150));

  final context = _customizeSectionKey.currentContext;
  if (context == null) return;

  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    alignment: 0.0,
  );
}

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }


  
  void _search() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    FocusScope.of(context).unfocus();

    context.read<SoliShiftLgBloc>().add(
          SoliShiftLgSearchRequested(
            cseId: authState.user.id,
            stockCode: _searchController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            MJHeader(
              username: authState.user.firstName,
              showHome: true,
              onHomePressed: () => context.go('/project'),
              onLogout: () => context.read<AuthBloc>().add(
                    const AuthLogoutRequested(),
                  ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocConsumer<SoliShiftLgBloc, SoliShiftLgState>(
                listenWhen: (previous, current) => previous.data != current.data,
                listener: (context, state) {
                  final stockInfo = state.data?.stockInfo;
                  if (stockInfo == null) return;

                  if (!state.showCustomize) {
                    _solitaireCaratController.text = stockInfo.solitaireWt;
                    _diamondCaratController.text = stockInfo.diamondWt;
                    _budgetController.clear();
                  }
                },
                builder: (context, state) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth >= 800;

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 26 : 14,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SearchRow(
                              controller: _searchController,
                              isTablet: isTablet,
                              loading: state.loading,
                              onSearch: _search,
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            const Center(
                              child: Text(
                                'SOLISWITCH',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 22),

                            if (state.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _ErrorBanner(message: state.error!),
                              ),

                            if (state.loading)
                              const Padding(
                                padding: EdgeInsets.only(top: 80),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (state.data == null)
                              const _InitialMessage()
                            else ...[
                              _ProductSummarySection(
                                isTablet: isTablet,
                                data: state.data!,
                                onCustomize: () async {
                                  context.read<SoliShiftLgBloc>().add(
                                        const SoliShiftLgCustomizeClicked(),
                                      );

                                  await _scrollToCustomizeSection();
                                },
                                // onCustomize: () {
                                //   context.read<SoliShiftLgBloc>().add(
                                //         const SoliShiftLgCustomizeClicked(),
                                //       );
                                // },
                              ),
                              if (state.showCustomize) ...[
                                const SizedBox(height: 28),
                                Container(
                                  key: _customizeSectionKey,
                                  child: _CustomizeSection(
                                    data: state.data!,
                                    mode: state.mode,
                                    shape: state.shape,
                                    colour: state.colour,
                                    clarity: state.clarity,
                                    solitaireCaratController:
                                        _solitaireCaratController,
                                    diamondCaratController:
                                        _diamondCaratController,
                                    budgetController: _budgetController,
                                    updating: state.pricingUpdating,
                                    onModeChanged: (mode) {
                                      context.read<SoliShiftLgBloc>().add(
                                            SoliShiftLgModeChanged(mode),
                                          );
                                    },
                                    onFilterChanged: ({
                                      required shape,
                                      required colour,
                                      required clarity,
                                    }) {
                                      context.read<SoliShiftLgBloc>().add(
                                            SoliShiftLgFilterChanged(
                                              shape: shape,
                                              colour: colour,
                                              clarity: clarity,
                                            ),
                                          );
                                    },
                                    onReset: () {
                                      context.read<SoliShiftLgBloc>().add(
                                            const SoliShiftLgFiltersReset(),
                                          );
                                    },
                                    onUpdatePricing: () {
                                      _dismissKeyboard();

                                      context.read<SoliShiftLgBloc>().add(
                                            SoliShiftLgCaratUpdateRequested(
                                              newSolitaireCt:
                                                  _solitaireCaratController.text
                                                      .trim(),
                                              newDiamondCt:
                                                  _diamondCaratController.text
                                                      .trim(),
                                            ),
                                          );
                                    },
                                    onFindDiamond: () {
                                      _dismissKeyboard();

                                      context.read<SoliShiftLgBloc>().add(
                                            SoliShiftLgBudgetUpdateRequested(
                                              budget:
                                                  _budgetController.text.trim(),
                                            ),
                                          );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (state.filteredTables.isEmpty)
                                  const _InitialMessage(
                                    text: 'No pricing tables found for selected filters.',
                                  )
                                else
                                  ...state.filteredTables.map(
                                    (table) => Padding(
                                      padding: const EdgeInsets.only(bottom: 18),
                                      child: _ComparisonTable(
                                        table: table,
                                        hideLastColumn: state.mode == 'budget',
                                      ),
                                    ),
                                  ),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ],
                        ),
                      );
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
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isTablet;
  final bool loading;
  final VoidCallback onSearch;

  const _SearchRow({
    required this.controller,
    required this.isTablet,
    required this.loading,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final field = MJSearchField(
      controller: controller,
      variant: MJSearchFieldVariant.flat,
      hintText: 'Search Stock Code',
      onClear: () => controller.clear(),
    );

    final button = MJPrimaryButton(
      text: 'SEARCH',
      height: 44,
      width: isTablet ? 86 : null,
      loading: loading,
      onPressed: onSearch,
    );

    if (!isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          field,
          const SizedBox(height: AppSpacing.sm),
          SizedBox(height: 44, child: button),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 260, child: field),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(height: 44, width: 86, child: button),
        const Spacer(),
      ],
    );
  }
}

class _InitialMessage extends StatelessWidget {
  final String text;

  const _InitialMessage({
    this.text = 'Search stock code to view Soliswitch details.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProductSummarySection extends StatelessWidget {
  final bool isTablet;
  final SoliShiftLgData data;
  final VoidCallback onCustomize;

  const _ProductSummarySection({
    required this.isTablet,
    required this.data,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    final stockInfo = data.stockInfo;

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: Colors.black,
        height: isTablet ? 440 : 280,
        width: double.infinity,
        child: Image.network(
          stockInfo.stockImage,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.image_not_supported, color: Colors.white54),
          ),
        ),
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoTable(
          rows: [
            _InfoRow('Gross Weight', stockInfo.grossWt),
            _InfoRow('Net Weight', stockInfo.netWt),
            _InfoRow('Solitaire Weight', '${stockInfo.solitaireWt} ct'),
            _InfoRow('Diamonds Weight', '${stockInfo.diamondWt} ct'),
          ],
        ),
        const SizedBox(height: 20),
        MJPrimaryButton(
          text: 'Customize Lab Grown Ring',
          height: 50,
          onPressed: onCustomize,
        ),
      ],
    );

    if (!isTablet) {
      return Column(
        children: [
          image,
          const SizedBox(height: 16),
          details,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 46, child: image),
        const SizedBox(width: 26),
        Expanded(flex: 54, child: details),
      ],
    );
  }
}

class _InfoTable extends StatelessWidget {
  final List<_InfoRow> rows;

  const _InfoTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows.map((row) {
          final isLast = rows.last == row;
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLast ? Colors.transparent : AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 48, color: AppColors.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      row.value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}


class _CustomizeSection extends StatelessWidget {
  final SoliShiftLgData data;
  final String mode;
  final String shape;
  final String colour;
  final String clarity;
  final TextEditingController solitaireCaratController;
  final TextEditingController diamondCaratController;
  final TextEditingController budgetController;
  final bool updating;
  final ValueChanged<String> onModeChanged;
  final void Function({
    required String shape,
    required String colour,
    required String clarity,
  }) onFilterChanged;
  final VoidCallback onReset;
  final VoidCallback onUpdatePricing;
  final VoidCallback onFindDiamond;

  const _CustomizeSection({
    required this.data,
    required this.mode,
    required this.shape,
    required this.colour,
    required this.clarity,
    required this.solitaireCaratController,
    required this.diamondCaratController,
    required this.budgetController,
    required this.updating,
    required this.onModeChanged,
    required this.onFilterChanged,
    required this.onReset,
    required this.onUpdatePricing,
    required this.onFindDiamond,
  });

  @override
  Widget build(BuildContext context) {
    final filters = data.filters;
    final isCarat = mode == 'carat';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Customize Lab Grown Ring',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        _ModeSelector(
          mode: mode,
          onChanged: onModeChanged,
        ),
        const SizedBox(height: 18),
        if (isCarat)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: solitaireCaratController,
            builder: (context, solitaireValue, _) {
              final solitaireCarat =
                  double.tryParse(solitaireValue.text.trim()) ?? 0;
              final diamondReadOnly = solitaireCarat > 0;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _TextInput(
                    label: 'Solitaire Carat',
                    controller: solitaireCaratController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  _TextInput(
                    label: 'Diamond Carat',
                    controller: diamondCaratController,
                    readOnly: diamondReadOnly,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(
                    width: 190,
                    height: 48,
                    child: MJPrimaryButton(
                      text: 'Update Pricing',
                      loading: updating,
                      onPressed: onUpdatePricing,
                    ),
                  ),
                ],
              );
            },
          )
        else
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _TextInput(
                label: 'Your Budget (INR)',
                controller: budgetController,
                hintText: 'e.g. 200000',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
              ),
              SizedBox(
                width: 190,
                height: 48,
                child: MJPrimaryButton(
                  text: 'Find Diamond',
                  loading: updating,
                  onPressed: onFindDiamond,
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _DropdownBox(
                label: 'Shape',
                width: 420,
                value: filters.shapeDropdown.contains(shape) ? shape : 'All',
                items: filters.shapeDropdown,
                onChanged: (value) => onFilterChanged(
                  shape: value ?? 'All',
                  colour: colour,
                  clarity: clarity,
                ),
              ),
              _DropdownBox(
                label: 'Colour',
                width: 120,
                value: filters.colourDropdown.contains(colour) ? colour : 'All',
                items: filters.colourDropdown,
                onChanged: (value) => onFilterChanged(
                  shape: shape,
                  colour: value ?? 'All',
                  clarity: clarity,
                ),
              ),
              _DropdownBox(
                label: 'Clarity',
                width: 120,
                value: filters.clarityDropdown.contains(clarity)
                    ? clarity
                    : 'All',
                items: filters.clarityDropdown,
                onChanged: (value) => onFilterChanged(
                  shape: shape,
                  colour: colour,
                  clarity: value ?? 'All',
                ),
              ),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: onReset,
                  child: const Text('Reset Filters'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onChanged;

  const _ModeSelector({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget item({
      required String value,
      required String label,
    }) {
      final selected = mode == value;

      return Expanded(
        child: InkWell(
          onTap: () => onChanged(value),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF173E78) : Colors.white,
              border: Border.all(color: const Color(0xFF173E78)),
              borderRadius: BorderRadius.horizontal(
                left: value == 'carat'
                    ? const Radius.circular(8)
                    : Radius.zero,
                right: value == 'budget'
                    ? const Radius.circular(8)
                    : Radius.zero,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF173E78),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 292,
      child: Row(
        children: [
          item(value: 'carat', label: 'Carat Based'),
          item(value: 'budget', label: 'Budget Based'),
        ],
      ),
    );
  }
}


class _TextInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final String? hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _TextInput({
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.hintText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: _inputDecoration().copyWith(
              hintText: hintText,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String label;
  final double width;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownBox({
    required this.label,
    required this.width,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.clamp(120, MediaQuery.of(context).size.width - 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label),
          const SizedBox(height: 8),
          MJDropdownField<String>(
            value: value,
            hintText: label,
            height: 48,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.border),
    ),
  );
}


class _ComparisonTable extends StatelessWidget {
  final PricingTable table;
  final bool hideLastColumn;

  const _ComparisonTable({
    required this.table,
    required this.hideLastColumn,
  });

  @override
  Widget build(BuildContext context) {
    final header = table.header;
    final showLastColumn = !hideLastColumn &&
        header.showCol4 &&
        header.col4.trim().isNotEmpty;

    final columnWidths = showLastColumn
        ? const <int, TableColumnWidth>{
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.6),
          }
        : const <int, TableColumnWidth>{
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0B2E5E), width: 1.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFF0B2E5E),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                header.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = showLastColumn && constraints.maxWidth < 760
                    ? 760.0
                    : constraints.maxWidth;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      border: TableBorder.all(color: AppColors.border),
                      columnWidths: columnWidths,
                      children: [
                    TableRow(
                      children: [
                        _TableCell(header.colDetail, bold: true),
                        _TableCell(header.colLg, bold: true, center: true),
                        _TableCell(header.colNat, bold: true, center: true),
                        if (showLastColumn)
                          _TableCell(
                            header.col4,
                            bold: true,
                            center: true,
                          ),
                      ],
                    ),
                    ...table.rows.map(
                      (row) => TableRow(
                        children: [
                          _TableCell(
                            row.subLabel.isEmpty
                                ? row.label
                                : '${row.label}\n${row.subLabel}',
                            bold: row.type == 'total',
                          ),
                          _TableCell(
                            hideLastColumn ? row.lgBudgetCell : row.lgCell,
                            center: true,
                            bold: row.type == 'total',
                            boldAmount: row.type == 'solitaire' ||
                                row.type == 'diamond',
                          ),
                          _TableCell(
                            hideLastColumn && row.type == 'total'
                                ? '—'
                                : row.natCell,
                            center: true,
                            bold: row.type == 'total',
                            boldAmount: row.type == 'solitaire' ||
                                row.type == 'diamond',
                          ),
                          if (showLastColumn)
                            _TableCell(
                              row.type == 'total'
                                  ? '—'
                                  : (row.col4Display.isEmpty
                                      ? '—'
                                      : row.col4Display),
                              bold: row.type != 'total' &&
                                  row.col4Display.isNotEmpty,
                              center: true,
                            ),
                        ],
                      ),
                    ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  final bool center;
  final bool boldAmount;

  const _TableCell(
    this.text, {
    this.bold = false,
    this.center = false,
    this.boldAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');

    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      alignment: center ? Alignment.center : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: RichText(
        textAlign: center ? TextAlign.center : TextAlign.left,
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            height: 1.35,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: lines.first,
              style: TextStyle(
                fontWeight:
                    bold || boldAmount ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            if (lines.length > 1)
              TextSpan(
                text: '\n${lines.skip(1).join('\n')}',
                style: TextStyle(
                  color: bold ? Colors.black : Colors.black54,
                  fontSize: 12,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);
}
