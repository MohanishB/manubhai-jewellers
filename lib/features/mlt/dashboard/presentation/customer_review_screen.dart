import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/core/widgets/mj_text_field.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/customerService/customer_experience_bloc.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/customerService/customer_experience_event.dart';
import 'package:manubhaimlt/features/mlt/products/bloc/CSE/customerService/customer_experience_state.dart';
import 'package:manubhaimlt/features/mlt/products/data/models/CSE_models/customer_experience_models.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';

enum ExperienceRating { happy, normal, sad }

extension ExperienceRatingApi on ExperienceRating {
  String toApiValue() {
    switch (this) {
      case ExperienceRating.happy:
        return 'HAPPY';
      case ExperienceRating.normal:
        return 'NORMAL';
      case ExperienceRating.sad:
        return 'SAD';
    }
  }

  String label() {
    switch (this) {
      case ExperienceRating.happy:
        return 'Happy';
      case ExperienceRating.normal:
        return 'Normal';
      case ExperienceRating.sad:
        return 'Sad';
    }
  }
}

class CustomerExperienceScreen extends StatefulWidget {
  const CustomerExperienceScreen({super.key});

  @override
  State<CustomerExperienceScreen> createState() =>
      _CustomerExperienceScreenState();
}

class _CustomerExperienceScreenState extends State<CustomerExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  ExperienceRating? _rating;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _resetScreenFresh() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _phoneCtrl.clear();
    setState(() => _rating = null);
    FocusScope.of(context).unfocus();
  }

  void _submit(AuthAuthenticated auth) {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_rating == null) {
      showMJAlertDialog(
        context,
        title: 'Validation Error',
        message: 'Please select an experience option.',
        primaryButtonText: 'OK',
      );
      return;
    }

    final req = CustomerExperienceRequest(
      cseId: auth.user.id,
      expType: _rating!.toApiValue(), // HAPPY/NORMAL/SAD
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
    );

    context.read<CustomerExperienceBloc>().add(SubmitCustomerExperience(req));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocListener<CustomerExperienceBloc, CustomerExperienceState>(
      listener: (context, state) async {
        if (state is CustomerExperienceSuccess) {
          // ✅ Reset screen fresh + show success MJAlert
          _resetScreenFresh();

          await showMJAlertDialog(
            context,
            title: 'Thank you',
            message: 'Your feedback has been submitted.',
            primaryButtonText: 'OK',
            onPrimaryPressed: () {
              context.read<CustomerExperienceBloc>().add(const ResetCustomerExperience());
            },
          );
        }

        if (state is CustomerExperienceError) {
          await showMJAlertDialog(
            context,
            title: 'Unable to submit',
            message: state.message,
            primaryButtonText: 'OK',
            onPrimaryPressed: () {
              context.read<CustomerExperienceBloc>().add(const ResetCustomerExperience());
            },
          );
        }
      },
      child: MJScaffold(
        username: authState.user.firstName,
        onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
        requestSafeCount: 0,
        receivedSafeCount: 0,
        onRequestSafe: () {},
        // onRequestedList: () => {},
        // onReceivedSafe: () {},
        showHome: true,
        showBack: true,
        // onCustomerExperience: () {},
        onRequestedList: () {
          if (GoRouterState.of(context).uri.toString() ==
              '/a/requested-stock-list') return;
          context.pushReplacement('/a/requested-stock-list');
        },

        onReceivedSafe: () {
          if (GoRouterState.of(context).uri.toString() == '/a/received-safe')
            return;
          context.pushReplacement('/a/received-safe');
        },

        onCustomerExperience: () {
          if (GoRouterState.of(context).uri.toString() == '/a/customer-review')
            return;
          context.pushReplacement('/a/customer-review');
        },

        body: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final isTablet = w >= 700;

            final contentMaxWidth = isTablet ? 980.0 : double.infinity;

            final bottomSafePad = MediaQuery.of(context).padding.bottom;
            final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

            final isLoading =
                context.watch<CustomerExperienceBloc>().state is CustomerExperienceLoading;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 24 : 14,
                    14,
                    isTablet ? 24 : 14,
                    24 + bottomSafePad + keyboardInset,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _titleBox(isTablet: isTablet),
                        const SizedBox(height: 14),

                        _ratingCardArea(isTablet: isTablet),
                        const SizedBox(height: 16),

                        _inputCard(isTablet: isTablet),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: isTablet ? 360 : double.infinity,
                          child: MJPrimaryButton(
                            text: isLoading ? 'SUBMITTING...' : 'SUBMIT',
                            onPressed: isLoading ? null : () => _submit(authState),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _titleBox({required bool isTablet}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
      ),
      child: Text(
        'HOW WAS YOUR EXPERIENCE ?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isTablet ? 22 : 16,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E5AA8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _ratingCardArea({required bool isTablet}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: LayoutBuilder(
        builder: (context, cc) {
          final maxW = cc.maxWidth;
          final gap = isTablet ? 12.0 : (maxW < 360 ? 6.0 : 8.0);
          final tileW = (maxW - 2 * gap) / 3;

          final phoneBaseTileW = 120.0;
          final scale = isTablet ? 1.0 : (tileW / phoneBaseTileW).clamp(0.78, 1.0);

   
          return Row(
            children: [
              Expanded(
                child: _ratingTile(
                  isTablet: isTablet,
                  tileWidth: tileW,
                  scale: scale,
                  rating: ExperienceRating.happy,
                  borderColor: const Color(0xFF45C26B),
                  iconColor: const Color(0xFF45C26B),
                  icon: Icons.sentiment_satisfied_alt,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: _ratingTile(
                  isTablet: isTablet,
                  tileWidth: tileW,
                  scale: scale,
                  rating: ExperienceRating.normal,
                  borderColor: const Color(0xFFE0B100),
                  iconColor: const Color(0xFFE0B100),
                  icon: Icons.sentiment_neutral,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: _ratingTile(
                  isTablet: isTablet,
                  tileWidth: tileW,
                  scale: scale,
                  rating: ExperienceRating.sad,
                  borderColor: const Color(0xFFE05252),
                  iconColor: const Color(0xFFE05252),
                  icon: Icons.sentiment_very_dissatisfied,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

   Widget _ratingTile({
    required bool isTablet,
    required double tileWidth,
    required double scale,
    required ExperienceRating rating,
    required Color borderColor,
    required Color iconColor,
    required IconData icon,
  }) {
    final selected = _rating == rating;

    final tilePadding = isTablet ? 12.0 : (8.0 * scale).clamp(6.0, 10.0);
    final labelSize = isTablet ? 14.0 : (12.0 * scale).clamp(10.0, 12.5);

    final circleSize =
        isTablet ? 140.0 : (tileWidth * 0.78).clamp(52.0, 90.0);

    final borderW = isTablet ? 10.0 : (6.0 * scale).clamp(4.0, 6.0);
    final iconSize = isTablet ? 64.0 : (circleSize * 0.48).clamp(26.0, 44.0);

    // ✅ FIX (PHONE ONLY):
    // Calculate the tile height based on content so label never overflows.
    final gapBelowCircle = isTablet ? 10.0 : 6.0; // slightly smaller on phone
    final estimatedLabelHeight = labelSize * 1.25; // safe estimate for font height
    final computedPhoneHeight =
        (tilePadding * 2) + circleSize + gapBelowCircle + estimatedLabelHeight + 6;

    final tileHeight = isTablet ? 220.0 : computedPhoneHeight;

    return InkWell(
      onTap: () => setState(() => _rating = rating),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: tileHeight,
        padding: EdgeInsets.all(tilePadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? borderColor : borderColor.withOpacity(0.45),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: circleSize,
              height: circleSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor, width: borderW),
                ),
                child: Center(
                  child: Icon(icon, size: iconSize, color: iconColor),
                ),
              ),
            ),
            SizedBox(height: gapBelowCircle),
            Text(
              rating.label(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _ratingTile({
  //   required bool isTablet,
  //   required double tileWidth,
  //   required double scale,
  //   required ExperienceRating rating,
  //   required Color borderColor,
  //   required Color iconColor,
  //   required IconData icon,
  // }) {
  //   final selected = _rating == rating;

  //   final tilePadding = isTablet ? 12.0 : (8.0 * scale).clamp(6.0, 10.0);
  //   final labelSize = isTablet ? 14.0 : (12.0 * scale).clamp(10.0, 12.5);
    

  //   final circleSize =
  //       isTablet ? 140.0 : (tileWidth * 0.78).clamp(52.0, 90.0);

  //   final borderW = isTablet ? 10.0 : (6.0 * scale).clamp(4.0, 6.0);
  //   final iconSize = isTablet ? 64.0 : (circleSize * 0.48).clamp(26.0, 44.0);

  //   final tileHeight = isTablet ? 220.0 : (130.0 * scale).clamp(110.0, 135.0);

  //   return InkWell(
  //     onTap: () => setState(() => _rating = rating),
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 160),
  //       height: tileHeight,
  //       padding: EdgeInsets.all(tilePadding),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(6),
  //         border: Border.all(
  //           color: selected ? borderColor : borderColor.withOpacity(0.45),
  //           width: selected ? 2 : 1,
  //         ),
  //         boxShadow: selected
  //             ? [
  //                 BoxShadow(
  //                   color: borderColor.withOpacity(0.25),
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 3),
  //                 )
  //               ]
  //             : [],
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           SizedBox(
  //             width: circleSize,
  //             height: circleSize,
  //             child: DecoratedBox(
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 border: Border.all(color: iconColor, width: borderW),
  //               ),
  //               child: Center(child: Icon(icon, size: iconSize, color: iconColor)),
  //             ),
  //           ),
  //           SizedBox(height: isTablet ? 10 : 8),
  //           Text(
  //             rating.label(),
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             style: TextStyle(
  //               fontSize: labelSize,
  //               fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
  //               color: Colors.black87,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _inputCard({required bool isTablet}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: isTablet
          ? Row(
              children: [
                Expanded(
                  child: MJTextField(
                    controller: _nameCtrl,
                    hintText: 'Name',
                    keyboardType: TextInputType.name,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Name is required';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MJTextField(
                    controller: _phoneCtrl,
                    hintText: 'Phone',
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Phone is required';
                      if (s.length < 8) return 'Enter a valid phone number';
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) _submit(authState);
                    },
                  ),
                ),
              ],
            )
          : Column(
              children: [
                MJTextField(
                  controller: _nameCtrl,
                  hintText: 'Name',
                  keyboardType: TextInputType.name,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Name is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                MJTextField(
                  controller: _phoneCtrl,
                  hintText: 'Phone',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Phone is required';
                    if (s.length < 8) return 'Enter a valid phone number';
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) _submit(authState);
                  },
                ),
              ],
            ),
    );
  }
}

//============================================//
//============================================//
//============================================//

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:manubhaimlt/core/widgets/mj_alert_dialog.dart';
// import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
// import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
// import 'package:manubhaimlt/core/widgets/mj_text_field.dart';
// import '../../../auth/bloc/auth_bloc.dart';
// import '../../../auth/bloc/auth_event.dart';
// import '../../../auth/bloc/auth_state.dart';

// enum ExperienceRating { happy, normal, sad }

// extension ExperienceRatingApi on ExperienceRating {
//   String toApiValue() {
//     switch (this) {
//       case ExperienceRating.happy:
//         return 'HAPPY';
//       case ExperienceRating.normal:
//         return 'NORMAL';
//       case ExperienceRating.sad:
//         return 'SAD';
//     }
//   }

//   String label() {
//     switch (this) {
//       case ExperienceRating.happy:
//         return 'Happy';
//       case ExperienceRating.normal:
//         return 'Normal';
//       case ExperienceRating.sad:
//         return 'Sad';
//     }
//   }
// }

// class CustomerExperienceScreen extends StatefulWidget {
//   const CustomerExperienceScreen({super.key});

//   @override
//   State<CustomerExperienceScreen> createState() =>
//       _CustomerExperienceScreenState();
// }

// class _CustomerExperienceScreenState extends State<CustomerExperienceScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();

//   ExperienceRating? _rating;

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _phoneCtrl.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     final ok = _formKey.currentState?.validate() ?? false;
//     if (!ok) return;

//     if (_rating == null) {
//       showMJAlertDialog(
//         context,
//         title: 'Validation Error',
//         message: 'Please select an experience option.',
//         primaryButtonText: 'OK',
//       );
//       return;
//     }

//     final payload = {
//       'name': _nameCtrl.text.trim(),
//       'phone': _phoneCtrl.text.trim(),
//       'experience': _rating!.toApiValue(),
//     };

//     debugPrint('✅ Customer Experience Payload: $payload');

//     // TODO: call API here

//     showMJAlertDialog(
//       context,
//       title: 'Thank you',
//       message: 'Your feedback has been submitted.',
//       primaryButtonText: 'OK',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = context.watch<AuthBloc>().state;
//     if (authState is! AuthAuthenticated) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return MJScaffold(
//       username: authState.user.firstName,
//       onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
//       requestSafeCount: 0,
//       receivedSafeCount: 0,
//       onRequestSafe: () {},
//       onRequestedList: () => {},
//       onReceivedSafe: () {},
//       showHome: true,
//       showBack: true,
//       onCustomerExperience: () {},
//       body: LayoutBuilder(
//         builder: (context, c) {
//           final w = c.maxWidth;
//           final isTablet = w >= 700;

//           final contentMaxWidth = isTablet ? 980.0 : double.infinity;

//           final bottomSafePad = MediaQuery.of(context).padding.bottom;
//           final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

//           return Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: contentMaxWidth),
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.fromLTRB(
//                   isTablet ? 24 : 14,
//                   14,
//                   isTablet ? 24 : 14,
//                   24 + bottomSafePad + keyboardInset,
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       _titleBox(isTablet: isTablet),
//                       const SizedBox(height: 14),

//                       _ratingCardArea(isTablet: isTablet),
//                       const SizedBox(height: 16),

//                       _inputCard(isTablet: isTablet),
//                       const SizedBox(height: 16),

//                       SizedBox(
//                         width: isTablet ? 360 : double.infinity,
//                         child: MJPrimaryButton(
//                           text: 'SUBMIT',
//                           onPressed: _submit,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _titleBox({required bool isTablet}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
//       ),
//       child: Text(
//         'HOW WAS YOUR EXPERIENCE ?',
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           fontSize: isTablet ? 22 : 16,
//           fontWeight: FontWeight.w800,
//           color: const Color(0xFF1E5AA8),
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }

//   Widget _ratingCardArea({required bool isTablet}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.10),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: LayoutBuilder(
//         builder: (context, cc) {
//           final maxW = cc.maxWidth;

//           final gap = isTablet ? 12.0 : (maxW < 360 ? 6.0 : 8.0);
//           final tileW = (maxW - 2 * gap) / 3;

//           final phoneBaseTileW = 120.0;
//           final scale = isTablet
//               ? 1.0
//               : (tileW / phoneBaseTileW).clamp(0.78, 1.0);

//           return Row(
//             children: [
//               Expanded(
//                 child: _ratingTile(
//                   isTablet: isTablet,
//                   tileWidth: tileW,
//                   scale: scale,
//                   rating: ExperienceRating.happy,
//                   borderColor: const Color(0xFF45C26B),
//                   iconColor: const Color(0xFF45C26B),
//                   icon: Icons.sentiment_satisfied_alt,
//                 ),
//               ),
//               SizedBox(width: gap),
//               Expanded(
//                 child: _ratingTile(
//                   isTablet: isTablet,
//                   tileWidth: tileW,
//                   scale: scale,
//                   rating: ExperienceRating.normal,
//                   borderColor: const Color(0xFFE0B100),
//                   iconColor: const Color(0xFFE0B100),
//                   icon: Icons.sentiment_neutral,
//                 ),
//               ),
//               SizedBox(width: gap),
//               Expanded(
//                 child: _ratingTile(
//                   isTablet: isTablet,
//                   tileWidth: tileW,
//                   scale: scale,
//                   rating: ExperienceRating.sad,
//                   borderColor: const Color(0xFFE05252),
//                   iconColor: const Color(0xFFE05252),
//                   icon: Icons.sentiment_very_dissatisfied,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _ratingTile({
//     required bool isTablet,
//     required double tileWidth,
//     required double scale,
//     required ExperienceRating rating,
//     required Color borderColor,
//     required Color iconColor,
//     required IconData icon,
//   }) {
//     final selected = _rating == rating;

//     final tilePadding = isTablet ? 12.0 : (8.0 * scale).clamp(6.0, 10.0);
//     final labelSize = isTablet ? 14.0 : (12.0 * scale).clamp(10.0, 12.5);

//     final circleSize =
//         isTablet ? 140.0 : (tileWidth * 0.78).clamp(52.0, 90.0);

//     final borderW = isTablet ? 10.0 : (6.0 * scale).clamp(4.0, 6.0);
//     final iconSize = isTablet ? 64.0 : (circleSize * 0.48).clamp(26.0, 44.0);

//     // ✅ FIX (PHONE ONLY):
//     // Calculate the tile height based on content so label never overflows.
//     final gapBelowCircle = isTablet ? 10.0 : 6.0; // slightly smaller on phone
//     final estimatedLabelHeight = labelSize * 1.25; // safe estimate for font height
//     final computedPhoneHeight =
//         (tilePadding * 2) + circleSize + gapBelowCircle + estimatedLabelHeight + 6;

//     final tileHeight = isTablet ? 220.0 : computedPhoneHeight;

//     return InkWell(
//       onTap: () => setState(() => _rating = rating),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 160),
//         height: tileHeight,
//         padding: EdgeInsets.all(tilePadding),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(
//             color: selected ? borderColor : borderColor.withOpacity(0.45),
//             width: selected ? 2 : 1,
//           ),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: borderColor.withOpacity(0.25),
//                     blurRadius: 10,
//                     offset: const Offset(0, 3),
//                   )
//                 ]
//               : [],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: circleSize,
//               height: circleSize,
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: iconColor, width: borderW),
//                 ),
//                 child: Center(
//                   child: Icon(icon, size: iconSize, color: iconColor),
//                 ),
//               ),
//             ),
//             SizedBox(height: gapBelowCircle),
//             Text(
//               rating.label(),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: labelSize,
//                 fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _inputCard({required bool isTablet}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: isTablet
//           ? Row(
//               children: [
//                 Expanded(
//                   child: MJTextField(
//                     controller: _nameCtrl,
//                     hintText: 'Name',
//                     keyboardType: TextInputType.name,
//                     validator: (v) {
//                       final s = (v ?? '').trim();
//                       if (s.isEmpty) return 'Name is required';
//                       return null;
//                     },
//                     textInputAction: TextInputAction.next,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: MJTextField(
//                     controller: _phoneCtrl,
//                     hintText: 'Phone',
//                     keyboardType: TextInputType.phone,
//                     validator: (v) {
//                       final s = (v ?? '').trim();
//                       if (s.isEmpty) return 'Phone is required';
//                       if (s.length < 8) return 'Enter a valid phone number';
//                       return null;
//                     },
//                     textInputAction: TextInputAction.done,
//                     onFieldSubmitted: (_) => _submit(),
//                   ),
//                 ),
//               ],
//             )
//           : Column(
//               children: [
//                 MJTextField(
//                   controller: _nameCtrl,
//                   hintText: 'Name',
//                   keyboardType: TextInputType.name,
//                   validator: (v) {
//                     final s = (v ?? '').trim();
//                     if (s.isEmpty) return 'Name is required';
//                     return null;
//                   },
//                   textInputAction: TextInputAction.next,
//                 ),
//                 const SizedBox(height: 12),
//                 MJTextField(
//                   controller: _phoneCtrl,
//                   hintText: 'Phone',
//                   keyboardType: TextInputType.phone,
//                   validator: (v) {
//                     final s = (v ?? '').trim();
//                     if (s.isEmpty) return 'Phone is required';
//                     if (s.length < 8) return 'Enter a valid phone number';
//                     return null;
//                   },
//                   textInputAction: TextInputAction.done,
//                   onFieldSubmitted: (_) => _submit(),
//                 ),
//               ],
//             ),
//     );
//   }
// }
