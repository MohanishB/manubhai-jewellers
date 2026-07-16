// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Simple splash -> go login after build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.go('/login');
//     });

//     return const Scaffold(
//       body: Center(
//         child: Text(
//           'MJ-MLT',
//           style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // If you want delay, keep it. If not, remove the next line.
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return; // ✅ prevents "deactivated widget" crash
      context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: Image.asset(
          'assets/images/mj_logo_blue.png',
          height: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
