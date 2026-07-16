import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/mj_logo_blue.png',
                  height: 170,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),

                SizedBox(
                 width: 260, // keep same width if design needs it
                 child: MJPrimaryButton(
                 text: 'LOGIN',
                 onPressed: () {
                   context.go('/login');
                  },
                  ),
                 ),


                //  SizedBox(
                //   width: 260,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: const Color(0xFF1E5AA8),
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(14),
                //       ),
                //     ),
                //     onPressed: () {
                //       context.go('/login');
                //     },
                //     child: const Text('LOGIN',
                //         style: TextStyle(fontWeight: FontWeight.w700)),
                //   ),
                // ),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}
