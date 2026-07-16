// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:manubhaimlt/core/theme/app_colors.dart';
// import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
// import 'package:manubhaimlt/core/widgets/mj_text_field.dart';
// import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_event.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_state.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_bloc.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_event.dart';
// import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_state.dart';
// import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_model.dart';

// class FilterDrawer extends StatefulWidget {
//   const FilterDrawer({super.key});

//   @override
//   State<FilterDrawer> createState() => _FilterDrawerState();
// }

// class _FilterDrawerState extends State<FilterDrawer> {
//   static const Color _mjBlue = AppColors.brand;

//   final Map<String, TextEditingController> _controllers = {};
//   Map<String, dynamic>? _pendingAppliedFilters;

//   // ✅ controllers to prevent Scrollbar crash
//   final ScrollController _drawerScrollCtrl = ScrollController();
//   final Map<String, ScrollController> _sectionScrollCtrls = {};

//   // UI tuning (kept as-is)
//   static const double _choiceIconSize = 26;
//   static const double _choiceFontSize = 15;
//   static const double _choiceRowVPad = 4;
//   static const double _choiceRowHPad = 10;
//   static const double _choiceGap = 3;
//   static const int _maxVisibleChoices = 5;

//   // ✅ per-section search controller
//   TextEditingController _searchControllerFor(String label) {
//     return _controllers.putIfAbsent('search_$label', () => TextEditingController());
//   }

//   // ✅ ensure tapped field is visible above keyboard even at end
//   void _ensureVisible(BuildContext fieldContext) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       Scrollable.ensureVisible(
//         fieldContext,
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         alignment: 0.2,
//       );
//     });
//   }

//   @override
//   void initState() {
//     super.initState();

//     final filterBloc = context.read<ProductFilterBloc>();
//     final authState = context.read<AuthBloc>().state;

//     if (filterBloc.state is! ProductFilterLoaded) {
//       if (authState is AuthAuthenticated) {
//         filterBloc.add(FetchProductFilters(authState.user.id));
//       }
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final searchState = context.read<ProductSearchBloc>().state;
//       if (searchState is ProductSearchLoaded) {
//         _syncDrawerFromAppliedFilters(searchState.appliedFilters);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     for (final c in _controllers.values) {
//       c.dispose();
//     }
//     _controllers.clear();

//     _drawerScrollCtrl.dispose();
//     for (final c in _sectionScrollCtrls.values) {
//       c.dispose();
//     }
//     _sectionScrollCtrls.clear();

//     super.dispose();
//   }

//   ScrollController _sectionCtrl(String key) {
//     return _sectionScrollCtrls.putIfAbsent(key, () => ScrollController());
//   }

//   TextEditingController _controllerFor(String key) {
//     return _controllers.putIfAbsent(key, () => TextEditingController());
//   }

//   void _setControllerText(String key, String text) {
//     final c = _controllerFor(key);
//     if (c.text == text) return;
//     c.value = c.value.copyWith(
//       text: text,
//       selection: TextSelection.collapsed(offset: text.length),
//       composing: TextRange.empty,
//     );
//   }

//   void _clearDrawerControllers() {
//     for (final c in _controllers.values) {
//       c.dispose();
//     }
//     _controllers.clear();
//     _pendingAppliedFilters = null;

//     for (final c in _sectionScrollCtrls.values) {
//       c.dispose();
//     }
//     _sectionScrollCtrls.clear();
//   }

//   /// ✅ Convert appliedFilters -> selectedFilters using ProductFilterModel mapping
//   void _syncDrawerFromAppliedFilters(Map<String, dynamic> appliedFilters) {
//     final filterBloc = context.read<ProductFilterBloc>();
//     final fs = filterBloc.state;

//     if (fs is! ProductFilterLoaded) {
//       _pendingAppliedFilters = appliedFilters;
//       return;
//     }

//     final updated = <String, dynamic>{};

//     for (final f in fs.filters) {
//       final label = f.labelDisplay;
//       final post = f.postName;

//       if (f.fieldType == 'radio') {
//         final key = post['para1']?.toString();
//         final v = (key != null) ? appliedFilters[key] : null;
//         final valueStr = v?.toString().trim() ?? '';
//         if (valueStr.isNotEmpty) updated[label] = valueStr;
//       } else if (f.fieldType == 'checkbox') {
//         final key = post['para1']?.toString();
//         final v = (key != null) ? appliedFilters[key] : null;

//         if (v is List) {
//           final setVal = v.map((e) => e.toString()).toSet();
//           if (setVal.isNotEmpty) updated[label] = setVal;
//         } else if (v is Set) {
//           final setVal = v.map((e) => e.toString()).toSet();
//           if (setVal.isNotEmpty) updated[label] = setVal;
//         } else if (v != null) {
//           final s = v.toString().trim();
//           if (s.isNotEmpty) updated[label] = <String>{s};
//         }
//       } else if (f.fieldType == 'input_from_to') {
//         final k1 = post['para1']?.toString();
//         final k2 = post['para2']?.toString();

//         final from =
//             (k1 != null ? appliedFilters[k1] : null)?.toString().trim() ?? '';
//         final to =
//             (k2 != null ? appliedFilters[k2] : null)?.toString().trim() ?? '';

//         if (from.isNotEmpty || to.isNotEmpty) {
//           updated[label] = {'from': from, 'to': to};
//         }

//         _setControllerText('${label}_from', from);
//         _setControllerText('${label}_to', to);
//       }
//     }

//     // (keeping your approach)
//     filterBloc.emit(fs.copyWith(selectedFilters: updated));
//   }

//   void _applySelectedFilters(
//     List<ProductFilterModel> filters,
//     Map<String, dynamic> selectedFilters, {
//     required bool preserveExistingSort,
//     bool closeDrawer = false,
//   }) {
//     final authState = context.read<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) return;

//     final validationError = _validateFilters(filters, selectedFilters);
//     if (validationError != null) {
//       showMJAlertDialog(
//         context,
//         title: "Validation Error",
//         message: validationError,
//         primaryButtonText: "OK",
//       );
//       return;
//     }

//     final apiFilters = _buildApiParams(filters, selectedFilters);

//     if (preserveExistingSort) {
//       final ps = context.read<ProductSearchBloc>().state;
//       if (ps is ProductSearchLoaded) {
//         final existingSort = ps.appliedFilters['sort_by'];
//         if (existingSort != null &&
//             existingSort.toString().trim().isNotEmpty &&
//             !apiFilters.containsKey('sort_by')) {
//           apiFilters['sort_by'] = existingSort;
//         }
//       }
//     } else {
//       apiFilters.remove('sort_by');
//     }

//     apiFilters['cse_id'] = authState.user.id;

//     context.read<ProductSearchBloc>().add(ApplyFilters(apiFilters));

//     if (closeDrawer) Navigator.pop(context);
//   }

//   bool _sectionHasValue(ProductFilterModel filter, Map<String, dynamic> selectedFilters) {
//     final v = selectedFilters[filter.labelDisplay];
//     if (v == null) return false;

//     if (filter.fieldType == 'radio') {
//       return (v.toString().trim()).isNotEmpty;
//     }
//     if (filter.fieldType == 'checkbox') {
//       return v is Set && v.isNotEmpty;
//     }
//     if (filter.fieldType == 'input_from_to') {
//       final map = (v as Map?) ?? {};
//       final from = map['from']?.toString().trim() ?? '';
//       final to = map['to']?.toString().trim() ?? '';
//       return from.isNotEmpty || to.isNotEmpty;
//     }
//     return false;
//   }

//   void _clearSingleSectionAndApply(
//     List<ProductFilterModel> filters,
//     Map<String, dynamic> selectedFilters,
//     ProductFilterModel filter,
//   ) {
//     if (filter.mandatory) return;

//     final pfBloc = context.read<ProductFilterBloc>();
//     final pfState = pfBloc.state;
//     if (pfState is! ProductFilterLoaded) return;

//     final updated = Map<String, dynamic>.from(selectedFilters);
//     updated.remove(filter.labelDisplay);

//     if (filter.fieldType == 'input_from_to') {
//       final label = filter.labelDisplay;
//       _setControllerText('${label}_from', '');
//       _setControllerText('${label}_to', '');
//     }

//     pfBloc.emit(pfState.copyWith(selectedFilters: updated));
//   }

//   void _clearAllNonMandatoryAndApply(
//     List<ProductFilterModel> filters,
//     Map<String, dynamic> selectedFilters,
//   ) {
//     final pfBloc = context.read<ProductFilterBloc>();
//     final pfState = pfBloc.state;
//     if (pfState is! ProductFilterLoaded) return;

//     final updated = Map<String, dynamic>.from(selectedFilters);

//     for (final f in filters) {
//       if (f.mandatory) continue;

//       updated.remove(f.labelDisplay);

//       if (f.fieldType == 'input_from_to') {
//         final label = f.labelDisplay;
//         _setControllerText('${label}_from', '');
//         _setControllerText('${label}_to', '');
//       }
//     }

//     pfBloc.emit(pfState.copyWith(selectedFilters: updated));
//   }

//   Widget _clearLink(VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: const Padding(
//         padding: EdgeInsets.only(left: 10, right: 2),
//         child: Text(
//           'Clear',
//           style: TextStyle(
//             color: _mjBlue,
//             fontSize: 13.5,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       // ✅ moves whole drawer up when keyboard opens (no permanent bottom gap)
//       child: AnimatedPadding(
//         duration: const Duration(milliseconds: 150),
//         curve: Curves.easeOut,
//         padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         child: SafeArea(
//           child: BlocListener<AuthBloc, AuthState>(
//             listenWhen: (prev, curr) =>
//                 curr is AuthUnauthenticated || curr is AuthAuthenticated,
//             listener: (context, state) {
//               if (state is AuthUnauthenticated) {
//                 _clearDrawerControllers();
//                 context.read<ProductFilterBloc>().add(const ResetProductFilters());
//                 return;
//               }

//               if (state is AuthAuthenticated) {
//                 final pfBloc = context.read<ProductFilterBloc>();
//                 if (pfBloc.state is! ProductFilterLoaded &&
//                     pfBloc.state is! ProductFilterLoading) {
//                   pfBloc.add(FetchProductFilters(state.user.id));
//                 }
//               }
//             },
//             child: BlocListener<ProductSearchBloc, ProductSearchState>(
//               listenWhen: (prev, curr) => curr is ProductSearchLoaded,
//               listener: (context, state) {
//                 if (state is ProductSearchLoaded) {
//                   _syncDrawerFromAppliedFilters(state.appliedFilters);
//                 }
//               },
//               child: BlocBuilder<ProductFilterBloc, ProductFilterState>(
//                 builder: (context, state) {
//                   if (state is ProductFilterLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (state is ProductFilterError) {
//                     return Center(child: Text(state.message));
//                   } else if (state is ProductFilterLoaded) {
//                     if (_pendingAppliedFilters != null) {
//                       final pending = _pendingAppliedFilters!;
//                       _pendingAppliedFilters = null;
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         _syncDrawerFromAppliedFilters(pending);
//                       });
//                     }
//                     return _buildFilterList(state.filters, state.selectedFilters);
//                   } else {
//                     final authState = context.read<AuthBloc>().state;
//                     if (authState is AuthAuthenticated) {
//                       context.read<ProductFilterBloc>().add(
//                             FetchProductFilters(authState.user.id),
//                           );
//                     }
//                     return const SizedBox.shrink();
//                   }
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterList(
//     List<ProductFilterModel> filters,
//     Map<String, dynamic> selectedFilters,
//   ) {
//     final kb = MediaQuery.of(context).viewInsets.bottom;

//     bool hasAnyNonMandatorySelection() {
//       for (final f in filters) {
//         if (f.mandatory) continue;
//         if (_sectionHasValue(f, selectedFilters)) return true;
//       }
//       return false;
//     }

//     return Column(
//       children: [
//         Expanded(
//           child: Scrollbar(
//             controller: _drawerScrollCtrl,
//             thumbVisibility: true,
//             child: SingleChildScrollView(
//               controller: _drawerScrollCtrl,
//               // ✅ professional: no extra space when keyboard closed
//               // ✅ adds scroll room ONLY while keyboard is open
//               padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + (kb > 0 ? kb : 0)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                     decoration: const BoxDecoration(color: _mjBlue),
//                     child: const Text(
//                       'Filter By',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   for (int i = 0; i < filters.length; i++) ...[
//                     _buildFilterSection(filters, filters[i], selectedFilters),
//                     if (i != filters.length - 1)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         child: Divider(
//                           thickness: 1,
//                           color: _mjBlue.withOpacity(0.55),
//                         ),
//                       ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(14),
//           child: Row(
//             children: [
//               Expanded(
//                 child: MJPrimaryButton(
//                   text: 'APPLY',
//                   height: 35,
//                   onPressed: () {
//                     _applySelectedFilters(
//                       filters,
//                       selectedFilters,
//                       preserveExistingSort: true,
//                       closeDrawer: true,
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: MJPrimaryButton(
//                   text: 'CLEAR ALL',
//                   height: 35,
//                   onPressed: hasAnyNonMandatorySelection()
//                       ? () => _clearAllNonMandatoryAndApply(filters, selectedFilters)
//                       : null,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   String? _validateFilters(
//     List<ProductFilterModel> filters,
//     Map<String, dynamic> selectedFilters,
//   ) {
//     for (final f in filters) {
//       final label = f.labelDisplay;
//       final value = selectedFilters[label];

//       if (f.mandatory) {
//         if (f.fieldType == 'radio' &&
//             (value == null || (value as String).isEmpty)) {
//           return '${f.labelDisplay} is mandatory.';
//         } else if (f.fieldType == 'checkbox' &&
//             (value == null || (value as Set).isEmpty)) {
//           return '${f.labelDisplay} is mandatory.';
//         } else if (f.fieldType == 'input_from_to') {
//           final map = (value as Map?) ?? {};
//           final from = map['from']?.toString().trim() ?? '';
//           final to = map['to']?.toString().trim() ?? '';
//           if (from.isEmpty || to.isEmpty) {
//             return 'Please enter both FROM and TO for ${f.labelDisplay}.';
//           }
//         }
//       } else if (f.fieldType == 'input_from_to') {
//         final map = (value as Map?) ?? {};
//         final from = map['from']?.toString().trim() ?? '';
//         final to = map['to']?.toString().trim() ?? '';
//         if ((from.isNotEmpty && to.isEmpty) || (from.isEmpty && to.isNotEmpty)) {
//           return 'Please enter both FROM and TO for ${f.labelDisplay}.';
//         }
//       }
//     }
//     return null;
//   }

//   Map<String, dynamic> _buildApiParams(
//     List<ProductFilterModel> filters,
//     Map<String, dynamic> selectedFilters,
//   ) {
//     final Map<String, dynamic> result = {};
//     for (final f in filters) {
//       final label = f.labelDisplay;
//       if (!selectedFilters.containsKey(label)) continue;
//       final value = selectedFilters[label];
//       final post = f.postName;

//       if (f.fieldType == 'radio') {
//         result[post['para1']] = value;
//       } else if (f.fieldType == 'checkbox') {
//         result[post['para1']] = (value as Set<String>).toList();
//       } else if (f.fieldType == 'input_from_to') {
//         final from = (value as Map)['from'] ?? '';
//         final to = value['to'] ?? '';
//         result[post['para1']] = from;
//         result[post['para2']] = to;
//       }
//     }
//     return result;
//   }

//   Widget _buildFilterSection(
//     List<ProductFilterModel> allFilters,
//     ProductFilterModel filter,
//     Map<String, dynamic> selectedFilters,
//   ) {
//     switch (filter.fieldType) {
//       case 'radio':
//         return _radioSection(allFilters, filter, selectedFilters);
//       case 'checkbox':
//         return _checkboxSection(allFilters, filter, selectedFilters);
//       case 'input_from_to':
//         return _fromToSection(allFilters, filter, selectedFilters);
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _radioSection(
//     List<ProductFilterModel> allFilters,
//     ProductFilterModel filter,
//     Map<String, dynamic> selectedFilters,
//   ) {
//     final String? selected = selectedFilters[filter.labelDisplay] as String?;
//     final title = filter.mandatory ? '${filter.labelDisplay} *' : filter.labelDisplay;

//     final searchCtrl = _searchControllerFor(filter.labelDisplay);
//     final query = searchCtrl.text.trim().toLowerCase();

//     // ✅ filtered values (start search only after 2 chars)
//     final filteredValues = (query.isEmpty || query.length < 2)
//         ? filter.values
//         : filter.values.where((v) => v.toLowerCase().contains(query)).toList();

//     final itemCount = filteredValues.length;
//     final needsScroll = itemCount > _maxVisibleChoices;

//     final visibleHeight =
//         (_maxVisibleChoices * (_choiceRowVPad * 2 + _choiceIconSize)).toDouble() +
//             ((_maxVisibleChoices - 1) * _choiceGap);

//     final ctrl = _sectionCtrl('radio_${filter.labelDisplay}');
//     final showClear = !filter.mandatory && (selected?.trim().isNotEmpty ?? false);

//     return _section(
//       title: title,
//       trailing: showClear
//           ? _clearLink(() => _clearSingleSectionAndApply(allFilters, selectedFilters, filter))
//           : null,
//       child: Column(
//         children: [
//           // ✅ Search bar with auto-scroll on focus
//           Builder(
//             builder: (fieldCtx) {
//               return Focus(
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus) _ensureVisible(fieldCtx);
//                 },
//                 child: MJTextField(
//                   controller: searchCtrl,
//                   hintText: 'Search $title',
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
//                   onChanged: (_) => setState(() {}),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: needsScroll ? visibleHeight : null,
//             child: Scrollbar(
//               controller: ctrl,
//               thumbVisibility: needsScroll,
//               child: ListView.separated(
//                 controller: ctrl,
//                 primary: false,
//                 shrinkWrap: !needsScroll,
//                 physics: needsScroll
//                     ? const ClampingScrollPhysics()
//                     : const NeverScrollableScrollPhysics(),
//                 itemCount: itemCount,
//                 separatorBuilder: (_, __) => const SizedBox(height: _choiceGap),
//                 itemBuilder: (context, idx) {
//                   final value = filteredValues[idx];
//                   final isSelected = selected == value;

//                   return InkWell(
//                     onTap: () {
//                       if (!isSelected) {
//                         context
//                             .read<ProductFilterBloc>()
//                             .add(UpdateSelectedFilter(filter.labelDisplay, value));
//                       }
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: _choiceRowHPad,
//                         vertical: _choiceRowVPad,
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
//                             size: _choiceIconSize,
//                             color: isSelected ? _mjBlue : AppColors.unselectedRadioButton,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               value,
//                               style: TextStyle(
//                                 fontSize: _choiceFontSize,
//                                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
//                                 color: AppColors.textFilterTitle,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _checkboxSection(
//     List<ProductFilterModel> allFilters,
//     ProductFilterModel filter,
//     Map<String, dynamic> selectedFilters,
//   ) {
//     final selectedValues =
//         selectedFilters[filter.labelDisplay] as Set<String>? ?? <String>{};
//     final title = filter.mandatory ? '${filter.labelDisplay} *' : filter.labelDisplay;

//     final searchCtrl = _searchControllerFor(filter.labelDisplay);
//     final query = searchCtrl.text.trim().toLowerCase();

//     // ✅ filtered values (start search only after 2 chars)
//     final filteredValues = (query.isEmpty || query.length < 2)
//         ? filter.values
//         : filter.values.where((v) => v.toLowerCase().contains(query)).toList();

//     final itemCount = filteredValues.length;
//     final needsScroll = itemCount > _maxVisibleChoices;

//     final visibleHeight =
//         (_maxVisibleChoices * (_choiceRowVPad * 2 + _choiceIconSize)).toDouble() +
//             ((_maxVisibleChoices - 1) * _choiceGap);

//     final ctrl = _sectionCtrl('chk_${filter.labelDisplay}');
//     final showClear = !filter.mandatory && selectedValues.isNotEmpty;

//     return _section(
//       title: title,
//       trailing: showClear
//           ? _clearLink(() => _clearSingleSectionAndApply(allFilters, selectedFilters, filter))
//           : null,
//       child: Column(
//         children: [
//           // ✅ Search bar with auto-scroll on focus
//           Builder(
//             builder: (fieldCtx) {
//               return Focus(
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus) _ensureVisible(fieldCtx);
//                 },
//                 child: MJTextField(
//                   controller: searchCtrl,
//                   hintText: 'Search $title',
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
//                   onChanged: (_) => setState(() {}),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: needsScroll ? visibleHeight : null,
//             child: Scrollbar(
//               controller: ctrl,
//               thumbVisibility: needsScroll,
//               child: ListView.separated(
//                 controller: ctrl,
//                 primary: false,
//                 shrinkWrap: !needsScroll,
//                 physics: needsScroll
//                     ? const ClampingScrollPhysics()
//                     : const NeverScrollableScrollPhysics(),
//                 itemCount: itemCount,
//                 separatorBuilder: (_, __) => const SizedBox(height: _choiceGap),
//                 itemBuilder: (context, idx) {
//                   final value = filteredValues[idx];
//                   final checked = selectedValues.contains(value);

//                   return InkWell(
//                     onTap: () {
//                       final updated = Set<String>.from(selectedValues);
//                       checked ? updated.remove(value) : updated.add(value);
//                       context
//                           .read<ProductFilterBloc>()
//                           .add(UpdateSelectedFilter(filter.labelDisplay, updated));
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: _choiceRowHPad,
//                         vertical: _choiceRowVPad,
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             checked ? Icons.check_box : Icons.check_box_outline_blank,
//                             size: _choiceIconSize,
//                             color: checked ? _mjBlue : AppColors.uncheckedCheckBox,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               value,
//                               style: TextStyle(
//                                 fontSize: _choiceFontSize,
//                                 fontWeight: checked ? FontWeight.w700 : FontWeight.w600,
//                                 color: AppColors.textFilterTitle,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _fromToSection(
//     List<ProductFilterModel> allFilters,
//     ProductFilterModel filter,
//     Map<String, dynamic> selectedFilters,
//   ) {
//     final label = filter.labelDisplay;

//     final fromCtrl = _controllerFor('${label}_from');
//     final toCtrl = _controllerFor('${label}_to');

//     final saved = selectedFilters[label] as Map<String, dynamic>? ?? {};
//     final savedFrom = saved['from']?.toString() ?? '';
//     final savedTo = saved['to']?.toString() ?? '';

//     _setControllerText('${label}_from', savedFrom);
//     _setControllerText('${label}_to', savedTo);

//     final showClear = !filter.mandatory &&
//         ((savedFrom.trim().isNotEmpty) || (savedTo.trim().isNotEmpty));

//     return _section(
//       title: filter.mandatory ? '$label *' : label,
//       trailing: showClear
//           ? _clearLink(() => _clearSingleSectionAndApply(allFilters, selectedFilters, filter))
//           : null,
//       child: Row(
//         children: [
//           Expanded(
//             child: Builder(
//               builder: (fieldCtx) {
//                 return Focus(
//                   onFocusChange: (hasFocus) {
//                     if (hasFocus) _ensureVisible(fieldCtx);
//                   },
//                   child: MJTextField(
//                     controller: fromCtrl,
//                     hintText: 'FROM',
//                     keyboardType: TextInputType.number,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
//                     onChanged: (v) => context.read<ProductFilterBloc>().add(
//                           UpdateSelectedFilter(label, {'from': v, 'to': toCtrl.text}),
//                         ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Builder(
//               builder: (fieldCtx) {
//                 return Focus(
//                   onFocusChange: (hasFocus) {
//                     if (hasFocus) _ensureVisible(fieldCtx);
//                   },
//                   child: MJTextField(
//                     controller: toCtrl,
//                     hintText: 'TO',
//                     keyboardType: TextInputType.number,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
//                     onChanged: (v) => context.read<ProductFilterBloc>().add(
//                           UpdateSelectedFilter(label, {'from': fromCtrl.text, 'to': v}),
//                         ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _section({
//     required String title,
//     required Widget child,
//     Widget? trailing,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 1),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16.5,
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.textFilterSectionTitle,
//                   ),
//                 ),
//               ),
//               if (trailing != null) trailing,
//             ],
//           ),
//           const SizedBox(height: 8),
//           child,
//         ],
//       ),
//     );
//   }
// }


//================= Single Filter Logic above =================//

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manubhaimlt/core/theme/app_colors.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_text_field.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productFilters/product_filter_state.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/productSearch/product_search_state.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/product_filter_model.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  static const Color _mjBlue = AppColors.brand;

  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic>? _pendingAppliedFilters;

  // ✅ controllers to prevent Scrollbar crash
  final ScrollController _drawerScrollCtrl = ScrollController();
  final Map<String, ScrollController> _sectionScrollCtrls = {};

  // UI tuning (kept as-is)
  static const double _choiceIconSize = 26;
  static const double _choiceFontSize = 15;
  static const double _choiceRowVPad = 4;
  static const double _choiceRowHPad = 10;
  static const double _choiceGap = 3;
  static const int _maxVisibleChoices = 5;

  bool _isLobOrCategory(ProductFilterModel filter) {
    final postName = filter.postName['para1']?.toString().trim() ?? '';
    return postName == 'lob' || postName == 'category';
  }

  bool _shouldBlockUntilMainSelected(ProductFilterModel filter) {
    final state = context.read<ProductFilterBloc>().state;

    if (state is! ProductFilterLoaded) return false;
    if (_isLobOrCategory(filter)) return false;

    final lobSelected = state.selectedFilters.entries.any((entry) {
      final f =
          state.filters.where((x) => x.labelDisplay == entry.key).toList();
      if (f.isEmpty) return false;
      return f.first.postName['para1'] == 'lob' &&
          entry.value.toString().trim().isNotEmpty;
    });

    final categorySelected = state.selectedFilters.entries.any((entry) {
      final f =
          state.filters.where((x) => x.labelDisplay == entry.key).toList();
      if (f.isEmpty) return false;
      return f.first.postName['para1'] == 'category' &&
          entry.value.toString().trim().isNotEmpty;
    });

    return !lobSelected || !categorySelected || !state.subFiltersLoaded;
  }

  void _fetchSubFiltersIfReady() {
    final authState = context.read<AuthBloc>().state;
    final pfState = context.read<ProductFilterBloc>().state;

    if (authState is! AuthAuthenticated) return;
    if (pfState is! ProductFilterLoaded) return;

    String lob = '';
    String category = '';

    for (final filter in pfState.filters) {
      final postName = filter.postName['para1']?.toString().trim() ?? '';
      final value =
          pfState.selectedFilters[filter.labelDisplay]?.toString().trim() ?? '';

      if (postName == 'lob') lob = value;
      if (postName == 'category') category = value;
    }

    if (lob.isNotEmpty && category.isNotEmpty) {
      context.read<ProductFilterBloc>().add(
            FetchProductSubFilters(
              cseId: authState.user.id,
              lob: lob,
              category: category,
            ),
          );
    }
  }

  // ✅ per-section search controller
  TextEditingController _searchControllerFor(String label) {
    return _controllers.putIfAbsent('search_$label', () => TextEditingController());
  }

  // ✅ ensure tapped field is visible above keyboard even at end
  void _ensureVisible(BuildContext fieldContext) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    final filterBloc = context.read<ProductFilterBloc>();
    final authState = context.read<AuthBloc>().state;

    if (filterBloc.state is! ProductFilterLoaded) {
      if (authState is AuthAuthenticated) {
        filterBloc.add(FetchProductFilters(authState.user.id));
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchState = context.read<ProductSearchBloc>().state;
      if (searchState is ProductSearchLoaded) {
        _syncDrawerFromAppliedFilters(searchState.appliedFilters);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();

    _drawerScrollCtrl.dispose();
    for (final c in _sectionScrollCtrls.values) {
      c.dispose();
    }
    _sectionScrollCtrls.clear();

    super.dispose();
  }

  ScrollController _sectionCtrl(String key) {
    return _sectionScrollCtrls.putIfAbsent(key, () => ScrollController());
  }

  TextEditingController _controllerFor(String key) {
    return _controllers.putIfAbsent(key, () => TextEditingController());
  }

  void _setControllerText(String key, String text) {
    final c = _controllerFor(key);
    if (c.text == text) return;
    c.value = c.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }

  void _clearDrawerControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _pendingAppliedFilters = null;

    for (final c in _sectionScrollCtrls.values) {
      c.dispose();
    }
    _sectionScrollCtrls.clear();
  }

  /// ✅ Convert appliedFilters -> selectedFilters using ProductFilterModel mapping
  void _syncDrawerFromAppliedFilters(Map<String, dynamic> appliedFilters) {
    final filterBloc = context.read<ProductFilterBloc>();
    final fs = filterBloc.state;

    if (fs is! ProductFilterLoaded) {
      _pendingAppliedFilters = appliedFilters;
      return;
    }

    final updated = <String, dynamic>{};

    for (final f in fs.filters) {
      final label = f.labelDisplay;
      final post = f.postName;

      if (f.fieldType == 'radio') {
        final key = post['para1']?.toString();
        final v = (key != null) ? appliedFilters[key] : null;
        final valueStr = v?.toString().trim() ?? '';
        if (valueStr.isNotEmpty) updated[label] = valueStr;
      } else if (f.fieldType == 'checkbox') {
        final key = post['para1']?.toString();
        final v = (key != null) ? appliedFilters[key] : null;

        if (v is List) {
          final setVal = v.map((e) => e.toString()).toSet();
          if (setVal.isNotEmpty) updated[label] = setVal;
        } else if (v is Set) {
          final setVal = v.map((e) => e.toString()).toSet();
          if (setVal.isNotEmpty) updated[label] = setVal;
        } else if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty) updated[label] = <String>{s};
        }
      } else if (f.fieldType == 'input_from_to') {
        final k1 = post['para1']?.toString();
        final k2 = post['para2']?.toString();

        final from =
            (k1 != null ? appliedFilters[k1] : null)?.toString().trim() ?? '';
        final to =
            (k2 != null ? appliedFilters[k2] : null)?.toString().trim() ?? '';

        if (from.isNotEmpty || to.isNotEmpty) {
          updated[label] = {'from': from, 'to': to};
        }

        _setControllerText('${label}_from', from);
        _setControllerText('${label}_to', to);
      }
    }

    // (keeping your approach)
    filterBloc.emit(fs.copyWith(selectedFilters: updated));
  }

  void _applySelectedFilters(
    List<ProductFilterModel> filters,
    Map<String, dynamic> selectedFilters, {
    required bool preserveExistingSort,
    bool closeDrawer = false,
  }) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final validationError = _validateFilters(filters, selectedFilters);
    if (validationError != null) {
      showMJAlertDialog(
        context,
        title: "Validation Error",
        message: validationError,
        primaryButtonText: "OK",
      );
      return;
    }

    final apiFilters = _buildApiParams(filters, selectedFilters);

    if (preserveExistingSort) {
      final ps = context.read<ProductSearchBloc>().state;
      if (ps is ProductSearchLoaded) {
        final existingSort = ps.appliedFilters['sort_by'];
        if (existingSort != null &&
            existingSort.toString().trim().isNotEmpty &&
            !apiFilters.containsKey('sort_by')) {
          apiFilters['sort_by'] = existingSort;
        }
      }
    } else {
      apiFilters.remove('sort_by');
    }

    apiFilters['cse_id'] = authState.user.id;

    context.read<ProductSearchBloc>().add(ApplyFilters(apiFilters));

    if (closeDrawer) Navigator.pop(context);
  }

  bool _sectionHasValue(ProductFilterModel filter, Map<String, dynamic> selectedFilters) {
    final v = selectedFilters[filter.labelDisplay];
    if (v == null) return false;

    if (filter.fieldType == 'radio') {
      return (v.toString().trim()).isNotEmpty;
    }
    if (filter.fieldType == 'checkbox') {
      return v is Set && v.isNotEmpty;
    }
    if (filter.fieldType == 'input_from_to') {
      final map = (v as Map?) ?? {};
      final from = map['from']?.toString().trim() ?? '';
      final to = map['to']?.toString().trim() ?? '';
      return from.isNotEmpty || to.isNotEmpty;
    }
    return false;
  }

  void _clearSingleSectionAndApply(
    List<ProductFilterModel> filters,
    Map<String, dynamic> selectedFilters,
    ProductFilterModel filter,
  ) {
    if (filter.mandatory) return;

    final pfBloc = context.read<ProductFilterBloc>();
    final pfState = pfBloc.state;
    if (pfState is! ProductFilterLoaded) return;

    final updated = Map<String, dynamic>.from(selectedFilters);
    updated.remove(filter.labelDisplay);

    if (filter.fieldType == 'input_from_to') {
      final label = filter.labelDisplay;
      _setControllerText('${label}_from', '');
      _setControllerText('${label}_to', '');
    }

    pfBloc.emit(pfState.copyWith(selectedFilters: updated));
  }

  void _clearAllNonMandatoryAndApply(
    List<ProductFilterModel> filters,
    Map<String, dynamic> selectedFilters,
  ) {
    final pfBloc = context.read<ProductFilterBloc>();
    final pfState = pfBloc.state;
    if (pfState is! ProductFilterLoaded) return;

    final updated = Map<String, dynamic>.from(selectedFilters);

    for (final f in filters) {
      if (f.mandatory) continue;

      updated.remove(f.labelDisplay);

      if (f.fieldType == 'input_from_to') {
        final label = f.labelDisplay;
        _setControllerText('${label}_from', '');
        _setControllerText('${label}_to', '');
      }
    }

    pfBloc.emit(pfState.copyWith(selectedFilters: updated));
  }

  Widget _clearLink(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.only(left: 10, right: 2),
        child: Text(
          'Clear',
          style: TextStyle(
            color: _mjBlue,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // ✅ moves whole drawer up when keyboard opens (no permanent bottom gap)
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) =>
                curr is AuthUnauthenticated || curr is AuthAuthenticated,
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                _clearDrawerControllers();
                context.read<ProductFilterBloc>().add(const ResetProductFilters());
                return;
              }

              if (state is AuthAuthenticated) {
                final pfBloc = context.read<ProductFilterBloc>();
                if (pfBloc.state is! ProductFilterLoaded &&
                    pfBloc.state is! ProductFilterLoading) {
                  pfBloc.add(FetchProductFilters(state.user.id));
                }
              }
            },
            child: BlocListener<ProductSearchBloc, ProductSearchState>(
              listenWhen: (prev, curr) => curr is ProductSearchLoaded,
              listener: (context, state) {
                if (state is ProductSearchLoaded) {
                  _syncDrawerFromAppliedFilters(state.appliedFilters);
                }
              },
              child: BlocBuilder<ProductFilterBloc, ProductFilterState>(
                builder: (context, state) {
                  if (state is ProductFilterLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductFilterError) {
                    return Center(child: Text(state.message));
                  } else if (state is ProductFilterLoaded) {
                    if (_pendingAppliedFilters != null) {
                      final pending = _pendingAppliedFilters!;
                      _pendingAppliedFilters = null;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _syncDrawerFromAppliedFilters(pending);
                      });
                    }
                    return _buildFilterList(state.filters, state.selectedFilters);
                  } else {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<ProductFilterBloc>().add(
                            FetchProductFilters(authState.user.id),
                          );
                    }
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterList(
    List<ProductFilterModel> filters,
    Map<String, dynamic> selectedFilters,
  ) {
    final kb = MediaQuery.of(context).viewInsets.bottom;

    bool hasAnyNonMandatorySelection() {
      for (final f in filters) {
        if (f.mandatory) continue;
        if (_sectionHasValue(f, selectedFilters)) return true;
      }
      return false;
    }

    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            controller: _drawerScrollCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _drawerScrollCtrl,
              // ✅ professional: no extra space when keyboard closed
              // ✅ adds scroll room ONLY while keyboard is open
              padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + (kb > 0 ? kb : 0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: const BoxDecoration(color: _mjBlue),
                    child: const Text(
                      'Filter By',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < filters.length; i++) ...[
                    _buildFilterSection(filters, filters[i], selectedFilters),
                    if (i != filters.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          thickness: 1,
                          color: _mjBlue.withOpacity(0.55),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: MJPrimaryButton(
                  text: 'APPLY',
                  height: 35,
                  onPressed: () {
                    _applySelectedFilters(
                      filters,
                      selectedFilters,
                      preserveExistingSort: true,
                      closeDrawer: true,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MJPrimaryButton(
                  text: 'CLEAR ALL',
                  height: 35,
                  onPressed: hasAnyNonMandatorySelection()
                      ? () => _clearAllNonMandatoryAndApply(filters, selectedFilters)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _validateFilters(
    List<ProductFilterModel> filters,
    Map<String, dynamic> selectedFilters,
  ) {
    for (final f in filters) {
      final label = f.labelDisplay;
      final value = selectedFilters[label];

      if (f.mandatory) {
        if (f.fieldType == 'radio' &&
            (value == null || (value as String).isEmpty)) {
          return '${f.labelDisplay} is mandatory.';
        } else if (f.fieldType == 'checkbox' &&
            (value == null || (value as Set).isEmpty)) {
          return '${f.labelDisplay} is mandatory.';
        } else if (f.fieldType == 'input_from_to') {
          final map = (value as Map?) ?? {};
          final from = map['from']?.toString().trim() ?? '';
          final to = map['to']?.toString().trim() ?? '';
          if (from.isEmpty || to.isEmpty) {
            return 'Please enter both FROM and TO for ${f.labelDisplay}.';
          }
        }
      } else if (f.fieldType == 'input_from_to') {
        final map = (value as Map?) ?? {};
        final from = map['from']?.toString().trim() ?? '';
        final to = map['to']?.toString().trim() ?? '';
        if ((from.isNotEmpty && to.isEmpty) || (from.isEmpty && to.isNotEmpty)) {
          return 'Please enter both FROM and TO for ${f.labelDisplay}.';
        }
      }
    }
    return null;
  }

  Map<String, dynamic> _buildApiParams(
    List<ProductFilterModel> filters,
    Map<String, dynamic> selectedFilters,
  ) {
    final Map<String, dynamic> result = {};
    for (final f in filters) {
      final label = f.labelDisplay;
      if (!selectedFilters.containsKey(label)) continue;
      final value = selectedFilters[label];
      final post = f.postName;

      if (f.fieldType == 'radio') {
        result[post['para1']] = value;
      } else if (f.fieldType == 'checkbox') {
        result[post['para1']] = (value as Set<String>).toList();
      } else if (f.fieldType == 'input_from_to') {
        final from = (value as Map)['from'] ?? '';
        final to = value['to'] ?? '';
        result[post['para1']] = from;
        result[post['para2']] = to;
      }
    }
    return result;
  }

  Widget _buildFilterSection(
    List<ProductFilterModel> allFilters,
    ProductFilterModel filter,
    Map<String, dynamic> selectedFilters,
  ) {
    switch (filter.fieldType) {
      case 'radio':
        return _radioSection(allFilters, filter, selectedFilters);
      case 'checkbox':
        return _checkboxSection(allFilters, filter, selectedFilters);
      case 'input_from_to':
        return _fromToSection(allFilters, filter, selectedFilters);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _radioSection(
    List<ProductFilterModel> allFilters,
    ProductFilterModel filter,
    Map<String, dynamic> selectedFilters,
  ) {
    final String? selected = selectedFilters[filter.labelDisplay] as String?;
    final title = filter.mandatory ? '${filter.labelDisplay} *' : filter.labelDisplay;

    final searchCtrl = _searchControllerFor(filter.labelDisplay);
    final query = searchCtrl.text.trim().toLowerCase();

    // ✅ filtered values (start search only after 2 chars)
    final filteredValues = (query.isEmpty || query.length < 2)
        ? filter.values
        : filter.values.where((v) => v.toLowerCase().contains(query)).toList();

    final itemCount = filteredValues.length;
    final needsScroll = itemCount > _maxVisibleChoices;

    final visibleHeight =
        (_maxVisibleChoices * (_choiceRowVPad * 2 + _choiceIconSize)).toDouble() +
            ((_maxVisibleChoices - 1) * _choiceGap);

    final ctrl = _sectionCtrl('radio_${filter.labelDisplay}');
    final showClear = !filter.mandatory && (selected?.trim().isNotEmpty ?? false);

    return _section(
      title: title,
      trailing: showClear
          ? _clearLink(() => _clearSingleSectionAndApply(allFilters, selectedFilters, filter))
          : null,
      child: Column(
        children: [
          // ✅ Search bar with auto-scroll on focus
          Builder(
            builder: (fieldCtx) {
              return Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) _ensureVisible(fieldCtx);
                },
                child: MJTextField(
                  controller: searchCtrl,
                  hintText: 'Search $title',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  onChanged: (_) => setState(() {}),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: needsScroll ? visibleHeight : null,
            child: Scrollbar(
              controller: ctrl,
              thumbVisibility: needsScroll,
              child: ListView.separated(
                controller: ctrl,
                primary: false,
                shrinkWrap: !needsScroll,
                physics: needsScroll
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: _choiceGap),
                itemBuilder: (context, idx) {
                  final value = filteredValues[idx];
                  final isSelected = selected == value;

                  return InkWell(
                    onTap: () {
                      if (!isSelected) {
                        context.read<ProductFilterBloc>().add(
                            UpdateSelectedFilter(filter.labelDisplay, value));

                        final postName =
                            filter.postName['para1']?.toString().trim() ?? '';

                        if (postName == 'lob' || postName == 'category') {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _fetchSubFiltersIfReady();
                          });
                        }
                      }
                    },
                    // onTap: () {
                    //   if (!isSelected) {
                    //     context
                    //         .read<ProductFilterBloc>()
                    //         .add(UpdateSelectedFilter(filter.labelDisplay, value));
                    //   }
                    // },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _choiceRowHPad,
                        vertical: _choiceRowVPad,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            size: _choiceIconSize,
                            color: isSelected ? _mjBlue : AppColors.unselectedRadioButton,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: _choiceFontSize,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: AppColors.textFilterTitle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkboxSection(
    List<ProductFilterModel> allFilters,
    ProductFilterModel filter,
    Map<String, dynamic> selectedFilters,
  ) {
    final selectedValues =
        selectedFilters[filter.labelDisplay] as Set<String>? ?? <String>{};
    final title = filter.mandatory ? '${filter.labelDisplay} *' : filter.labelDisplay;
    final blocked = _shouldBlockUntilMainSelected(filter);

    if (blocked) {
      return _section(
        title: title,
        child: const Text(
          'Select Lob and Category first',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      );
    }

    final searchCtrl = _searchControllerFor(filter.labelDisplay);
    final query = searchCtrl.text.trim().toLowerCase();

    // ✅ filtered values (start search only after 2 chars)
    final filteredValues = (query.isEmpty || query.length < 2)
        ? filter.values
        : filter.values.where((v) => v.toLowerCase().contains(query)).toList();

    final itemCount = filteredValues.length;
    final needsScroll = itemCount > _maxVisibleChoices;

    final visibleHeight =
        (_maxVisibleChoices * (_choiceRowVPad * 2 + _choiceIconSize)).toDouble() +
            ((_maxVisibleChoices - 1) * _choiceGap);

    final ctrl = _sectionCtrl('chk_${filter.labelDisplay}');
    final showClear = !filter.mandatory && selectedValues.isNotEmpty;

    return _section(
      title: title,
      trailing: showClear
          ? _clearLink(() => _clearSingleSectionAndApply(allFilters, selectedFilters, filter))
          : null,
      child: Column(
        children: [
          // ✅ Search bar with auto-scroll on focus
          Builder(
            builder: (fieldCtx) {
              return Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) _ensureVisible(fieldCtx);
                },
                child: MJTextField(
                  controller: searchCtrl,
                  hintText: 'Search $title',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  onChanged: (_) => setState(() {}),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: needsScroll ? visibleHeight : null,
            child: Scrollbar(
              controller: ctrl,
              thumbVisibility: needsScroll,
              child: ListView.separated(
                controller: ctrl,
                primary: false,
                shrinkWrap: !needsScroll,
                physics: needsScroll
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: _choiceGap),
                itemBuilder: (context, idx) {
                  final value = filteredValues[idx];
                  final checked = selectedValues.contains(value);

                  return InkWell(
                    onTap: () {
                      final updated = Set<String>.from(selectedValues);
                      checked ? updated.remove(value) : updated.add(value);
                      context
                          .read<ProductFilterBloc>()
                          .add(UpdateSelectedFilter(filter.labelDisplay, updated));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _choiceRowHPad,
                        vertical: _choiceRowVPad,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            checked ? Icons.check_box : Icons.check_box_outline_blank,
                            size: _choiceIconSize,
                            color: checked ? _mjBlue : AppColors.uncheckedCheckBox,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: _choiceFontSize,
                                fontWeight: checked ? FontWeight.w700 : FontWeight.w600,
                                color: AppColors.textFilterTitle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fromToSection(
    List<ProductFilterModel> allFilters,
    ProductFilterModel filter,
    Map<String, dynamic> selectedFilters,
  ) {
    final label = filter.labelDisplay;

    final blocked = _shouldBlockUntilMainSelected(filter);

    if (blocked) {
      return _section(
        title: filter.mandatory ? '$label *' : label,
        child: const Text(
          'Select Lob and Category first',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      );
    }

    final fromCtrl = _controllerFor('${label}_from');
    final toCtrl = _controllerFor('${label}_to');

    final saved = selectedFilters[label] as Map<String, dynamic>? ?? {};
    final savedFrom = saved['from']?.toString() ?? '';
    final savedTo = saved['to']?.toString() ?? '';

    _setControllerText('${label}_from', savedFrom);
    _setControllerText('${label}_to', savedTo);

    final showClear = !filter.mandatory &&
        ((savedFrom.trim().isNotEmpty) || (savedTo.trim().isNotEmpty));

    return _section(
      title: filter.mandatory ? '$label *' : label,
      trailing: showClear
          ? _clearLink(() => _clearSingleSectionAndApply(allFilters, selectedFilters, filter))
          : null,
      child: Row(
        children: [
          Expanded(
            child: Builder(
              builder: (fieldCtx) {
                return Focus(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) _ensureVisible(fieldCtx);
                  },
                  child: MJTextField(
                    controller: fromCtrl,
                    hintText: 'FROM',
                    keyboardType: TextInputType.number,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    onChanged: (v) => context.read<ProductFilterBloc>().add(
                          UpdateSelectedFilter(label, {'from': v, 'to': toCtrl.text}),
                        ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Builder(
              builder: (fieldCtx) {
                return Focus(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) _ensureVisible(fieldCtx);
                  },
                  child: MJTextField(
                    controller: toCtrl,
                    hintText: 'TO',
                    keyboardType: TextInputType.number,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    onChanged: (v) => context.read<ProductFilterBloc>().add(
                          UpdateSelectedFilter(label, {'from': fromCtrl.text, 'to': v}),
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textFilterSectionTitle,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
