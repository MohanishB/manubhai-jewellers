import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppPage extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AppPage({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
