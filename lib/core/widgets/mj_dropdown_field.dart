import 'package:flutter/material.dart';
import 'package:manubhaimlt/core/theme/app_colors.dart';

class MJDropdownField<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  /// ✅ NEW: control overall field height (outer height)
  final double? height;

  /// ✅ NEW: control padding (inner height feel)
  final EdgeInsetsGeometry? contentPadding;

  /// ✅ NEW: allow dense toggle if needed
  final bool isDense;

  const MJDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.height,
    this.contentPadding,
    this.isDense = true,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = AppColors.dropDownBorder;

    final field = DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true, // ✅ helps layout & consistent height
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.dropDownBackground,
        isDense: isDense,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.dropDownDisabledBorder, width: 1),
        ),
      ),
      // icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF616161)),
       icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.dropDownIcon),
      hint: Text(
        hintText,
        style: const TextStyle(color: AppColors.textFieldHint, fontSize: 13),
      ),
      style: const TextStyle(color: AppColors.text, fontSize: 14),
    );

    // ✅ If height provided, enforce it
    if (height != null) {
      return SizedBox(
        height: height,
        child: Center(
          // keeps the field vertically centered within fixed height
          child: field,
        ),
      );
    }

    return field;
  }
}
