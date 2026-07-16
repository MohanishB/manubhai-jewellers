import 'package:flutter/material.dart';
import 'package:manubhaimlt/core/theme/mj_ui.dart';
 
class MJTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry contentPadding;
  final bool enabled;


  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const MJTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

    // ✅ NEW
    this.focusNode,
    this.onTap,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,               
      onTap: onTap,                       
      keyboardType: keyboardType,
      textInputAction: textInputAction,  
      onFieldSubmitted: onFieldSubmitted, 
      obscureText: obscureText,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: MJInputDecorations.textField(
        hintText: hintText.toUpperCase(),
        contentPadding: contentPadding,
      ),
    );
  }
}
