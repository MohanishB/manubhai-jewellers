import 'package:flutter/material.dart';
import 'package:manubhaimlt/core/theme/app_colors.dart';
import 'mj_primary_button.dart';

Future<void> showMJAlertDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String primaryButtonText,
  VoidCallback? onPrimaryPressed,
  String? secondaryButtonText,
  VoidCallback? onSecondaryPressed,
  bool dismissible = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: AppColors.alertBarrierColor.withValues(alpha: 0.55),  
    builder: (_) => MJAlertDialog(
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      secondaryButtonText: secondaryButtonText,
      onSecondaryPressed: onSecondaryPressed,
    ),
  );
}

class MJAlertDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const MJAlertDialog({
    super.key,
    required this.title,
    this.message,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
     // ✅ phone: keep margins, tablet: cap at 360
    final dialogWidth = screenW >= 420 ? 360.0 : screenW - 48.0; // 24 padding each side
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 22),
          decoration: BoxDecoration(
            color: AppColors.alertBackground,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.alertTextTitle,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),

              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.alertTextMessage,
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 22),

              SizedBox(
                width: 240,
                child: MJPrimaryButton(
                  text: primaryButtonText,
                  onPressed: () {
                    Navigator.pop(context);
                    onPrimaryPressed?.call();
                  },
                ),
              ),

              const SizedBox(height: 10),
              if (secondaryButtonText != null) ...[
                const SizedBox(height: 10),
                 MJPrimaryButton(
                  text: secondaryButtonText!,
                  onPressed: () {
                    Navigator.pop(context);
                    onSecondaryPressed?.call();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
