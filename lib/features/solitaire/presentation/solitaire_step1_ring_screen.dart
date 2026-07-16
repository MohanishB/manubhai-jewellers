import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_search_field.dart';
import 'package:manubhaimlt/core/theme/app_colors.dart';
import 'package:manubhaimlt/core/theme/app_spacing.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';  

import 'package:manubhaimlt/features/solitaire/bloc/stock_detail_bloc.dart';
import 'package:manubhaimlt/features/solitaire/bloc/stock_detail_event.dart';
import 'package:manubhaimlt/features/solitaire/bloc/stock_detail_state.dart';
import 'package:manubhaimlt/features/solitaire/data/repositories/stock_repository.dart';

class SolitaireStep1RingScreen extends StatefulWidget {
  const SolitaireStep1RingScreen({super.key});

  @override
  State<SolitaireStep1RingScreen> createState() =>
      _SolitaireStep1RingScreenState();
}

class _SolitaireStep1RingScreenState extends State<SolitaireStep1RingScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _showErrorDialog(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showMJAlertDialog(
        context,
        title: 'Error',
        message: message,
        primaryButtonText: 'OK',
        onPrimaryPressed: () {
          // Navigator.pop(context);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockDetailBloc(
        StockRepository(
          baseUrl: 'https://vitazreportingservices.com/choose_jewellery',
        ),
      ),
      child: BlocConsumer<StockDetailBloc, StockDetailState>(
        listener: (context, state) {
          if (state is StockError) {
            _searchController.clear();
            _showErrorDialog(context, state.message);
          }
        },
        builder: (context, state) {
          final w = MediaQuery.of(context).size.width;
          final isTablet = w >= 900;

          const tabletImageH = 420.0;
          const thumbsH = 110.0;
          const between = 12.0;
          const tabletLeftColumnH = tabletImageH + between + thumbsH;

          final searchBar = isTablet
              ? Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: MJSearchField(
                        controller: _searchController,
                        variant: MJSearchFieldVariant.flat,
                        hintText: 'Search Stock Code',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      height: 48,
                      child: MJPrimaryButton(
                        text: 'SEARCH',
                        onPressed: () {
                          final code = _searchController.text.trim();
                          if (code.isNotEmpty) {
                            context
                                .read<StockDetailBloc>()
                                .add(FetchStockDetailEvent(code));
                          }
                        },
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MJSearchField(
                        controller: _searchController,
                        variant: MJSearchFieldVariant.flat,
                        hintText: 'Search Stock Code',
                      ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: MJPrimaryButton(
                        text: 'SEARCH',
                        onPressed: () {
                          final code = _searchController.text.trim();
                          if (code.isNotEmpty) {
                            context
                                .read<StockDetailBloc>()
                                .add(FetchStockDetailEvent(code));
                          }
                        },
                      ),
                    ),
                  ],
                );

          if (state is StockInitial || state is StockError) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchBar,
                ],
              ),
            );
          }

          if (state is StockLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is StockLoaded) {
            final s = state.stock;

            final mainImage = s.stockImage.isNotEmpty
                ? s.stockImage
                : 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=1200&q=80';

            final thumbs = [mainImage];

            final format = (String value) {
              if (value.isEmpty) return '0';
              if (value.contains('.')) value = value.split('.')[0];
              return value;
            };

            final isLg = s.lob.trim().toUpperCase() == 'LG';
            final tableRows = <Widget>[
              _row('Gross Weight', s.grossWt),
              _row('Net Weight', s.netWt),
              _row('Solitaire Weight', '${s.solitaireWt} ct'),
              _row('Diamonds Weight', '${s.diamondWt} ct'),
            ];

            if (!isLg) {
              tableRows.addAll([
                _row('Labour', 'INR ${format(s.labourAmount)}'),
                _row('Metal Value', 'INR ${format(s.metalAmount)}'),
                _row('Solitaire Value', 'INR ${format(s.solitaireAmount)}'),
                _row('Diamond Value', 'INR ${format(s.diamondAmount)}'),
                _row('Total', 'INR ${format(s.finalAmount)}', bold: true),
              ]);
            }

            final table = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: tableRows,
            );

            // final table = Column(
            //   crossAxisAlignment: CrossAxisAlignment.stretch,
            //   children: [
            //     // _row('Gross Weight', format(s.grossWt)),
            //     // _row('Net Weight', format(s.netWt)),
            //     _row('Gross Weight', s.grossWt),
            //     _row('Net Weight', s.netWt),
            //     _row('Labour', 'INR ${format(s.labourAmount)}'),
            //     _row('Metal Value', 'INR ${format(s.metalAmount)}'),
            //     // _row('Solitaire Weight', '${format(s.solitaireWt)} ct'),
            //     // _row('Diamonds Weight', '${format(s.diamondWt)} ct'),
            //     _row('Solitaire Weight', '${s.solitaireWt} ct'),
            //     _row('Diamonds Weight', '${s.diamondWt} ct'),
            //     _row('Solitaire Value', 'INR ${format(s.solitaireAmount)}'),
            //     _row('Diamond Value', 'INR ${format(s.diamondAmount)}'),
            //     _row('Total', 'INR ${format(s.finalAmount)}', bold: true),
            //   ],
            // );

            if (!isTablet) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchBar,
                    const SizedBox(height: 18),
                    _bigImage(mainImage, height: 320),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: thumbs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _thumb(thumbs[i], selected: i == 0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    table,
                    const SizedBox(height: 14),
                    // _rightButtons(context, fixedHeight: null),
                    _rightButtons(
                      context,
                      fixedHeight: null,
                      stockCode: s
                          .stockCode, // if your model uses a different name, use that
                      solitaireWt: s.solitaireWt,
                      solitaireAmount: s.solitaireAmount,
                      grossWt: s.grossWt,
                      totalAmount:
                          s.finalAmount, // your step1 uses finalAmount as total
                      lob: s.lob,
                    ),

                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchBar,
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: tabletLeftColumnH,
                          child: _imageColumn(
                            mainImage,
                            thumbs,
                            imageHeight: tabletImageH,
                            thumbsHeight: thumbsH,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: SizedBox(
                          height: tabletLeftColumnH,
                          child: SingleChildScrollView(child: table),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: SizedBox(
                          height: tabletLeftColumnH,
                          child: _rightButtons(
                            context,
                            fixedHeight: tabletLeftColumnH,
                            stockCode: s.stockCode,
                            solitaireWt: s.solitaireWt,
                            solitaireAmount: s.solitaireAmount,
                            grossWt: s.grossWt,
                            totalAmount: s.finalAmount,
                            lob: s.lob,
                          ),

                          // child: _rightButtons(
                          //   context,
                          //   fixedHeight: tabletLeftColumnH,
                          // ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --------------------------
  // Helpers
  // --------------------------
  Widget _row(String left, String right, {bool bold = false}) {
    final s = TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(left, style: s),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(right, style: s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageColumn(String mainImage, List<String> thumbs,
      {required double imageHeight, required double thumbsHeight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _bigImage(mainImage, height: imageHeight),
        const SizedBox(height: 12),
        SizedBox(
          height: thumbsHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: thumbs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _thumb(thumbs[i], selected: i == 0),
          ),
        ),
      ],
    );
  }

  Widget _bigImage(String url, {double height = 420}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: height,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFF2F2F2),
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported, color: Colors.black45),
          ),
        ),
      ),
    );
  }

  Widget _thumb(String url, {bool selected = false}) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? AppColors.brand : const Color(0xFFCCCCCC),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF2F2F2),
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported, color: Colors.black45),
        ),
      ),
    );
  }

  Widget _rightButtons(
    BuildContext context, {
    double? fixedHeight,
    required String stockCode,
    required String solitaireWt,
    required String solitaireAmount,
    required String grossWt,
    required String totalAmount,
    required String lob,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fixedHeight != null) const Spacer(),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: MJPrimaryButton(
            text: 'CUSTOMISE YOUR RING',
            onPressed: () {
               final authState = context.read<AuthBloc>().state;
              if (authState is! AuthAuthenticated) return;
              final cseId = authState.user.id;
              context.go(
                '/solitaire/step2',
                extra: {
                  'cseId': cseId,
                  'stockCode': stockCode,
                  'solitaireWt': solitaireWt,
                  'solitaireAmount': solitaireAmount,
                  'grossWt': grossWt,
                  'totalAmount': totalAmount,
                  'lob': lob,
                },
              );
            },
          ),
        ),
      ],
    );
    return content;
  }
   
  //  Widget _rightButtons(
  //   BuildContext context, {
  //   double? fixedHeight,
  //   required String stockCode,
  //   required String solitaireWt,
  //   required String solitaireAmount,
  //   required String grossWt,
  //   required String totalAmount,
  // }) {
  //   final content = Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       if (fixedHeight != null) const Spacer(),
  //       const SizedBox(height: 18),
  //       SizedBox(
  //         width: double.infinity,
  //         height: 54,
  //         child: MJPrimaryButton(
  //           text: 'CUSTOMISE YOUR RING',
  //           onPressed: () {
  //             print('stockCodeDebug $stockCode');
  //             context.go(
  //               '/solitaire/step2',
  //               extra: {
  //                 'stockCode': stockCode,
  //                 'solitaireWt': solitaireWt,
  //                 'solitaireAmount': solitaireAmount,
  //                 'grossWt': grossWt,
  //                 'totalAmount': totalAmount,
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  //   return content;
  // }

}

