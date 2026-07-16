import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/mj_header.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class SolitaireFlowShell extends StatelessWidget {
  final Widget child;
  const SolitaireFlowShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Same top header style you already use
            MJHeader(
              username: authState.user.firstName,
              onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
              showHome: true,
              showSavedOrders: true,
              // onSavedOrdersPressed: () => context.push('/saved-orders'),
              onSavedOrdersPressed: () => context.go('/saved-orders?refresh=1'),
              // ✅ Navigate to project selection
              onHomePressed: () {
                context.go('/project');
              },
            ),
            const Divider(height: 1),

            // Title + Stepper row (common)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  const Text(
                    'Make your Own Jewellery',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _SolitaireStepper(
                    currentPath: GoRouterState.of(context).matchedLocation,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _SolitaireStepper extends StatelessWidget {
  final String currentPath;
  const _SolitaireStepper({required this.currentPath});

  bool _isStep(String path, int step) {
    if (step == 1) return path.contains('/solitaire/step1');
    if (step == 2) return path.contains('/solitaire/step2');
    return path.contains('/solitaire/step3');
  }

  @override
  Widget build(BuildContext context) {
    final s1 = _isStep(currentPath, 1);
    final s2 = _isStep(currentPath, 2);
    final s3 = _isStep(currentPath, 3);

    TextStyle style(bool active) => TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: active ? Colors.black : const Color(0xFFB0B0B0),
        );

    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: [
        Text('1. Choose your Ring', style: style(s1)),
        Text('2. Choose your Solitaire', style: style(s2)),
        Text('3. Your Customised Ring Details', style: style(s3)),
      ],
    );
  }
}

 

