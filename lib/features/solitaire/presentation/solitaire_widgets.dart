import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SolitaireShell extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;
  final int step; // 1,2,3
  final Widget child;

  const SolitaireShell({
    super.key,
    required this.username,
    required this.onLogout,
    required this.step,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopHeader(username: username, onLogout: onLogout),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 26 : 14, vertical: 14),
              child: Column(
                children: [
                  const Text(
                    'Make your Own Jewellery',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  _StepRow(activeStep: step),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 26 : 14, vertical: 16),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;

  const _TopHeader({required this.username, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/mj_logo_blue.png',
            height: 32,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Text(
            'Welcome $username',
            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E5AA8)),
          ),
          const SizedBox(width: 18),
          InkWell(
            onTap: onLogout,
            child: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E5AA8),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int activeStep;
  const _StepRow({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    TextStyle style(bool active) => TextStyle(
          fontSize: 18,
          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          color: active ? Colors.black87 : Colors.black38,
        );

    Widget stepItem(int n, String text, String route) {
      final active = activeStep == n;
      return InkWell(
        onTap: () => context.go(route),
        child: Text('$n. $text', style: style(active)),
      );
    }

    return Row(
      children: [
        stepItem(1, 'Choose your Ring', '/solitaire/step1'),
        const SizedBox(width: 24),
        stepItem(2, 'Choose your Solitaire', '/solitaire/step2'),
        const SizedBox(width: 24),
        stepItem(3, 'Your Customised Ring Details', '/solitaire/step3'),
      ],
    );
  }
}
