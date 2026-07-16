// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
// import 'package:manubhaimlt/core/widgets/mj_text_field.dart';

// import '../../../core/theme/app_spacing.dart';
// import '../bloc/auth_bloc.dart';
// import '../bloc/auth_event.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _user = TextEditingController();
//   final _pass = TextEditingController();

//   @override
//   void dispose() {
//     _user.dispose();
//     _pass.dispose();
//     super.dispose();
//   }

//   void _login() {
//     context.read<AuthBloc>().add(
//           AuthLoginRequested(
//             username: _user.text.isEmpty ? 'User' : _user.text,
//             password: _pass.text,
//           ),
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
  
  
//     final t = Theme.of(context);

//     return Scaffold(
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 420),
//           child: Padding(
//             padding: const EdgeInsets.all(AppSpacing.lg),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   l10n.loginNow, // "LOGIN"
//                   style: t.textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: AppSpacing.xl),

//                 MJTextField(
//                   controller: _user,
//                   hintText: l10n.username, // "USERNAME"
//                   textInputAction: TextInputAction.next,
//                 ),

//                 const SizedBox(height: AppSpacing.md),

//                 MJTextField(
//                   controller: _pass,
//                   hintText: l10n.password, // "PASSWORD"
//                   obscureText: true,
//                   textInputAction: TextInputAction.done,
//                 ),

//                 const SizedBox(height: AppSpacing.md),

//                 SizedBox(
//                   width: double.infinity,
//                   child: MJPrimaryButton(
//                     text: l10n.loginNow, // "LOGIN NOW"
//                     onPressed: _login,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

///////////==============/////////////////

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:manubhaimlt/core/theme/app_spacing.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_text_field.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _user.text.trim();
    final password = _pass.text.trim();

    // --- Basic validations ---
    if (email.isEmpty) {
      showMJAlertDialog(
        context,
        title: 'Error',
        message: 'Please enter your email.',
        primaryButtonText: 'OK',
      );
      return;
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      showMJAlertDialog(
        context,
        title: 'Error',
        message: 'Please enter a valid email address.',
        primaryButtonText: 'OK',
      );
      return;
    }
    if (password.isEmpty) {
      showMJAlertDialog(
        context,
        title: 'Error',
        message: 'Please enter your password.',
        primaryButtonText: 'OK',
      );
      return;
    }

    // --- Trigger login ---
      // ✅ Get Firebase token
    final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';

    // ✅ Determine platform (1 for Android, 2 for iOS)
    final cseDevice = Platform.isAndroid ? '1' : '2';

    context.read<AuthBloc>().add(AuthLoginRequested(
          username: email,
          password: password,
          deviceToken: fcmToken,
          cseDevice: cseDevice,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is AuthError) {
          showMJAlertDialog(
            context,
            title: 'Error',
            message: state.message,
            primaryButtonText: 'OK',
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.loginNow, // "LOGIN NOW"
                      style: t.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    MJTextField(
                      controller: _user,
                      hintText: l10n.username, // "USERNAME"
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    MJTextField(
                      controller: _pass,
                      hintText: l10n.password, // "PASSWORD"
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    SizedBox(
                      width: double.infinity,
                      child: MJPrimaryButton(
                        text: _isLoading
                            ? 'LOGGING IN...'
                            : l10n.loginNow.toUpperCase(),
                        onPressed: _isLoading ? null : _login,
                        loading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
