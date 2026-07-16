// // solitaire/presentation/widgets/step2_filters_card.dart
// import 'package:flutter/material.dart';
// import 'package:manubhaimlt/core/widgets/mj_dropdown_field.dart';
// import 'package:manubhaimlt/core/widgets/mj_search_field.dart';
// import 'package:manubhaimlt/core/widgets/mj_selected_filters_row.dart';
// import 'package:manubhaimlt/core/widgets/mj_text_field.dart';

// class Step2FiltersCard extends StatelessWidget {
//   final bool isTablet;

//   // controllers
//   final TextEditingController priceFromCtrl;
//   final TextEditingController priceToCtrl;
//   final TextEditingController caratFromCtrl;
//   final TextEditingController caratToCtrl;
//   final TextEditingController searchCtrl;

//   // values
//   final String shape;
//   final String color;
//   final String clarity;
//   final String cut;
//   final String certificate;

//   // options
//   final List<String> colorOptions;
//   final List<String> clarityOptions;
//   final List<String> cutOptions;
//   final List<String> certificateOptions;

//   // selected filter chips (static for now)
//   final List<String> selectedFilters;

//   // callbacks
//   final ValueChanged<String> onColorChanged;
//   final ValueChanged<String> onClarityChanged;
//   final ValueChanged<String> onCutChanged;
//   final ValueChanged<String> onCertificateChanged;

//   final VoidCallback onApply;
//   final VoidCallback onClear;

//   final ValueChanged<String> onSearchChanged;
//   final VoidCallback onSearchClear;

//   final ValueChanged<String> onRemoveChip;

//   const Step2FiltersCard({
//     super.key,
//     required this.isTablet,
//     required this.priceFromCtrl,
//     required this.priceToCtrl,
//     required this.caratFromCtrl,
//     required this.caratToCtrl,
//     required this.searchCtrl,
//     required this.shape,
//     required this.color,
//     required this.clarity,
//     required this.cut,
//     required this.certificate,
//     required this.colorOptions,
//     required this.clarityOptions,
//     required this.cutOptions,
//     required this.certificateOptions,
//     required this.selectedFilters,
//     required this.onColorChanged,
//     required this.onClarityChanged,
//     required this.onCutChanged,
//     required this.onCertificateChanged,
//     required this.onApply,
//     required this.onClear,
//     required this.onSearchChanged,
//     required this.onSearchClear,
//     required this.onRemoveChip,
//   });

//   static const _shadow = [
//     BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: _shadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.search, size: 20, color: Color(0xFF424242)),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'Filter Solitaires',
//                   style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // ✅ Search input (missing earlier)
//           // MJSearchField(
//           //   controller: searchCtrl,
//           //   hintText: 'Search...',
//           //   minCharsToSearch: 1,
//           //   onChanged: onSearchChanged,
//           //   onClear: onSearchClear,
//           //   padding: EdgeInsets.zero,
//           // ),
//           const SizedBox(height: 12),

//           // ✅ Selected filter chips row (missing earlier)
//           Row(
//             children: [
//               MJSelectedFiltersRow(
//                 filters: selectedFilters,
//                 onRemove: onRemoveChip,
//               ),
//             ],
//           ),
//           if (selectedFilters.isNotEmpty) const SizedBox(height: 14),

//           if (isTablet) _desktopLayout() else _mobileLayout(),

//           const SizedBox(height: 14),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: [
//               SizedBox(
//                 width: isTablet ? 190 : double.infinity,
//                 child: _actionButton(
//                   text: 'Apply Filters',
//                   onPressed: onApply,
//                   bg: const Color(0xFF0B2E5E),
//                 ),
//               ),
//               SizedBox(
//                 width: isTablet ? 170 : double.infinity,
//                 child: _actionButton(
//                   text: 'Clear Filters',
//                   onPressed: onClear,
//                   bg: const Color(0xFF616161),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _desktopLayout() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(child: _labeled('Shape', _shapeDropdown())),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _labeled(
//                 'Price From (INR)',
//                 MJTextField(
//                   controller: priceFromCtrl,
//                   hintText: 'Min Price (Optional)',
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _labeled(
//                 'Price To (INR)',
//                 MJTextField(
//                   controller: priceToCtrl,
//                   hintText: 'Max Price (Optional)',
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _labeled(
//                 'Carat From',
//                 MJTextField(
//                   controller: caratFromCtrl,
//                   hintText: 'Min Carat (Optional)',
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _labeled(
//                 'Carat To',
//                 MJTextField(
//                   controller: caratToCtrl,
//                   hintText: 'Max Carat (Optional)',
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _labeled(
//                 'Color',
//                 MJDropdownField<String>(
//                   value: color,
//                   hintText: 'All Colors',
//                   items: colorOptions
//                       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                       .toList(),
//                   onChanged: (v) => onColorChanged(v ?? color),
//                   height: 46,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _labeled(
//                 'Clarity',
//                 MJDropdownField<String>(
//                   value: clarity,
//                   hintText: 'All Clarity',
//                   items: clarityOptions
//                       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                       .toList(),
//                   onChanged: (v) => onClarityChanged(v ?? clarity),
//                   height: 46,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _labeled(
//                 'Cut',
//                 MJDropdownField<String>(
//                   value: cut,
//                   hintText: 'All Cuts',
//                   items: cutOptions
//                       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                       .toList(),
//                   onChanged: (v) => onCutChanged(v ?? cut),
//                   height: 46,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: _labeled(
//                 'Certificate',
//                 MJDropdownField<String>(
//                   value: certificate,
//                   hintText: 'All Certificates',
//                   items: certificateOptions
//                       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                       .toList(),
//                   onChanged: (v) => onCertificateChanged(v ?? certificate),
//                   height: 46,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _mobileLayout() {
//     return Column(
//       children: [
//         _labeled('Shape', _shapeDropdown()),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _labeled(
//                 'Price From (INR)',
//                 MJTextField(
//                   controller: priceFromCtrl,
//                   hintText: 'Min Price',
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _labeled(
//                 'Price To (INR)',
//                 MJTextField(
//                   controller: priceToCtrl,
//                   hintText: 'Max Price',
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _labeled(
//                 'Carat From',
//                 MJTextField(
//                   controller: caratFromCtrl,
//                   hintText: 'Min Carat',
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _labeled(
//                 'Carat To',
//                 MJTextField(
//                   controller: caratToCtrl,
//                   hintText: 'Max Carat',
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _labeled(
//           'Color',
//           MJDropdownField<String>(
//             value: color,
//             hintText: 'All Colors',
//             items: colorOptions
//                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                 .toList(),
//             onChanged: (v) => onColorChanged(v ?? color),
//             height: 46,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _labeled(
//           'Clarity',
//           MJDropdownField<String>(
//             value: clarity,
//             hintText: 'All Clarity',
//             items: clarityOptions
//                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                 .toList(),
//             onChanged: (v) => onClarityChanged(v ?? clarity),
//             height: 46,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _labeled(
//           'Cut',
//           MJDropdownField<String>(
//             value: cut,
//             hintText: 'All Cuts',
//             items: cutOptions
//                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                 .toList(),
//             onChanged: (v) => onCutChanged(v ?? cut),
//             height: 46,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _labeled(
//           'Certificate',
//           MJDropdownField<String>(
//             value: certificate,
//             hintText: 'All Certificates',
//             items: certificateOptions
//                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                 .toList(),
//             onChanged: (v) => onCertificateChanged(v ?? certificate),
//             height: 46,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _labeled(String label, Widget child) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
//         const SizedBox(height: 8),
//         child,
//       ],
//     );
//   }

//   Widget _readonly(String text) {
//     return Container(
//       height: 46,
//       alignment: Alignment.centerLeft,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF2F2F2),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: Text(text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
//     );
//   }

//   Widget _actionButton({
//     required String text,
//     required VoidCallback onPressed,
//     required Color bg,
//   }) {
//     return SizedBox(
//       height: 46,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: bg,
//           foregroundColor: Colors.white,
//           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//           elevation: 0,
//         ),
//         onPressed: onPressed,
//         child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
//       ),
//     );
//   }
// }

/// ////////////==========================================///////////
////=======================================================/////////


import 'package:flutter/material.dart';
import 'package:manubhaimlt/core/widgets/mj_dropdown_field.dart';
import 'package:manubhaimlt/core/widgets/mj_multiselect_chips_dropdown_field.dart';
import 'package:manubhaimlt/core/widgets/mj_selected_filters_row.dart';
import 'package:manubhaimlt/core/widgets/mj_text_field.dart';

class Step2FiltersCard extends StatelessWidget {
  final bool isTablet;

  final TextEditingController priceFromCtrl;
  final TextEditingController priceToCtrl;
  final TextEditingController caratFromCtrl;
  final TextEditingController caratToCtrl;
  final TextEditingController searchCtrl;

  final String shape;
  final List<String> shapeOptions;
  final ValueChanged<String> onShapeChanged;

  // ✅ multi selected values
  final List<String> colors;
  final List<String> clarities;
  final List<String> cuts;
  final List<String> certificates;

  // options (with "All ...")
  final List<String> colorOptions;
  final List<String> clarityOptions;
  final List<String> cutOptions;
  final List<String> certificateOptions;

  final List<String> selectedFilters;

  final ValueChanged<List<String>> onColorsChanged;
  final ValueChanged<List<String>> onClaritiesChanged;
  final ValueChanged<List<String>> onCutsChanged;
  final ValueChanged<List<String>> onCertificatesChanged;

  final VoidCallback onApply;
  final VoidCallback onClear;

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;

  final ValueChanged<String> onRemoveChip;

  const Step2FiltersCard({
    super.key,
    required this.isTablet,
    required this.priceFromCtrl,
    required this.priceToCtrl,
    required this.caratFromCtrl,
    required this.caratToCtrl,
    required this.searchCtrl,
    required this.shape,
    required this.shapeOptions,
    required this.onShapeChanged,
    required this.colors,
    required this.clarities,
    required this.cuts,
    required this.certificates,
    required this.colorOptions,
    required this.clarityOptions,
    required this.cutOptions,
    required this.certificateOptions,
    required this.selectedFilters,
    required this.onColorsChanged,
    required this.onClaritiesChanged,
    required this.onCutsChanged,
    required this.onCertificatesChanged,
    required this.onApply,
    required this.onClear,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onRemoveChip,
  });

  static const _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.search, size: 20, color: Color(0xFF424242)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Filter Solitaires',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row(
          //   children: [
          //     MJSelectedFiltersRow(filters: selectedFilters, onRemove: onRemoveChip),
          //   ],
          // ),
          if (selectedFilters.isNotEmpty) const SizedBox(height: 14),

          if (isTablet) _desktopLayout() else _mobileLayout(),

          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isTablet ? 190 : double.infinity,
                child: _actionButton(
                  text: 'Apply Filters',
                  onPressed: onApply,
                  bg: const Color(0xFF0B2E5E),
                ),
              ),
              SizedBox(
                width: isTablet ? 170 : double.infinity,
                child: _actionButton(
                  text: 'Clear Filters',
                  onPressed: onClear,
                  bg: const Color(0xFF616161),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _desktopLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _labeled('Shape', _shapeDropdown())),
            const SizedBox(width: 14),
            Expanded(
              child: _labeled(
                'Price From (INR)',
                MJTextField(
                  controller: priceFromCtrl,
                  hintText: 'Min Price (Optional)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _labeled(
                'Price To (INR)',
                MJTextField(
                  controller: priceToCtrl,
                  hintText: 'Max Price (Optional)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _labeled(
                'Carat From',
                MJTextField(
                  controller: caratFromCtrl,
                  hintText: 'Min Carat (Optional)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _labeled(
                'Carat To',
                MJTextField(
                  controller: caratToCtrl,
                  hintText: 'Max Carat (Optional)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _labeled(
                'Color (Multiple)',
                MJMultiSelectChipsDropdownField<String>(
                  values: colors,
                  options: _stripAll(colorOptions),
                  hintText: 'Select options',
                  labelBuilder: (v) => v,
                  onChanged: onColorsChanged,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _labeled(
                'Clarity (Multiple)',
                MJMultiSelectChipsDropdownField<String>(
                  values: clarities,
                  options: _stripAll(clarityOptions),
                  hintText: 'Select options',
                  labelBuilder: (v) => v,
                  onChanged: onClaritiesChanged,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _labeled(
                'Cut (Multiple)',
                MJMultiSelectChipsDropdownField<String>(
                  values: cuts,
                  options: _stripAll(cutOptions),
                  hintText: 'Select options',
                  labelBuilder: (v) => v,
                  onChanged: onCutsChanged,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _labeled(
                'Certificate (Multiple)',
                MJMultiSelectChipsDropdownField<String>(
                  values: certificates,
                  options: _stripAll(certificateOptions),
                  hintText: 'Select options',
                  labelBuilder: (v) => v,
                  onChanged: onCertificatesChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _mobileLayout() {
    return Column(
      children: [
        _labeled('Shape', _shapeDropdown()),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _labeled(
                'Price From (INR)',
                MJTextField(
                  controller: priceFromCtrl,
                  hintText: 'Min Price',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _labeled(
                'Price To (INR)',
                MJTextField(
                  controller: priceToCtrl,
                  hintText: 'Max Price',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _labeled(
                'Carat From',
                MJTextField(
                  controller: caratFromCtrl,
                  hintText: 'Min Carat',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _labeled(
                'Carat To',
                MJTextField(
                  controller: caratToCtrl,
                  hintText: 'Max Carat',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _labeled(
          'Color (Multiple)',
          MJMultiSelectChipsDropdownField<String>(
            values: colors,
            options: _stripAll(colorOptions),
            hintText: 'Select options',
            labelBuilder: (v) => v,
            onChanged: onColorsChanged,
          ),
        ),
        const SizedBox(height: 12),
        _labeled(
          'Clarity (Multiple)',
          MJMultiSelectChipsDropdownField<String>(
            values: clarities,
            options: _stripAll(clarityOptions),
            hintText: 'Select options',
            labelBuilder: (v) => v,
            onChanged: onClaritiesChanged,
          ),
        ),
        const SizedBox(height: 12),
        _labeled(
          'Cut (Multiple)',
          MJMultiSelectChipsDropdownField<String>(
            values: cuts,
            options: _stripAll(cutOptions),
            hintText: 'Select options',
            labelBuilder: (v) => v,
            onChanged: onCutsChanged,
          ),
        ),
        const SizedBox(height: 12),
        _labeled(
          'Certificate (Multiple)',
          MJMultiSelectChipsDropdownField<String>(
            values: certificates,
            options: _stripAll(certificateOptions),
            hintText: 'Select options',
            labelBuilder: (v) => v,
            onChanged: onCertificatesChanged,
          ),
        ),
      ],
    );
  }


  Widget _shapeDropdown() {
    final options = shapeOptions.isEmpty ? <String>[shape] : shapeOptions;
    final safeValue = options.contains(shape) ? shape : options.first;

    return MJDropdownField<String>(
      value: safeValue,
      hintText: 'Select Shape',
      items: options
          .map((e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e.toUpperCase()),
              ))
          .toList(),
      onChanged: (v) {
        if (v == null || v == shape) return;
        onShapeChanged(v);
      },
      height: 46,
    );
  }

  List<String> _stripAll(List<String> opts) {
    return opts.where((e) => !e.toLowerCase().startsWith('all ')).toList();
  }

  Widget _labeled(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _readonly(String text) {
    return Container(
      height: 46,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required VoidCallback onPressed,
    required Color bg,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
