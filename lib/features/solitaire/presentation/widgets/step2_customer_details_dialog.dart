// import 'package:flutter/material.dart';
// import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
// import 'package:manubhaimlt/core/widgets/mj_text_field.dart';

// class Step2CustomerDetailsDialog extends StatefulWidget {
//   final VoidCallback onContinue;

//   const Step2CustomerDetailsDialog({
//     super.key,
//     required this.onContinue,
//   });

//   static Future<void> show(
//     BuildContext context, {
//     required VoidCallback onContinue,
//   }) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Step2CustomerDetailsDialog(onContinue: onContinue),
//     );
//   }

//   @override
//   State<Step2CustomerDetailsDialog> createState() =>
//       _Step2CustomerDetailsDialogState();
// }

// class _Step2CustomerDetailsDialogState extends State<Step2CustomerDetailsDialog> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();

//   final _nameFocus = FocusNode();
//   final _phoneFocus = FocusNode();
//   final _emailFocus = FocusNode();

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emailCtrl.dispose();
//     _nameFocus.dispose();
//     _phoneFocus.dispose();
//     _emailFocus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);

//     final screenW = mq.size.width;
//     final screenH = mq.size.height;

//     final keyboardH = mq.viewInsets.bottom;
//     final isLandscape = mq.orientation == Orientation.landscape;

//     final safeTop = mq.padding.top;
//     final safeBottom = mq.padding.bottom;

//     // Available visible height
//     final visibleH = screenH - safeTop - safeBottom;

//     // ✅ IMPORTANT: In landscape, DON'T reserve full keyboard height
//     // Reserve only a capped amount, otherwise dialog collapses/clips.
//     final double reservedBottom = isLandscape
//         ? (keyboardH * 0.35).clamp(0.0, visibleH * 0.28) // ✅ cap in landscape
//         : keyboardH; // portrait is fine with full keyboard inset

//     // Responsive width
//     final dialogW = screenW >= 900 ? 560.0 : (screenW * 0.92);

//     // ✅ Dialog max height based on remaining space
//     final availableH = (visibleH - reservedBottom).clamp(240.0, visibleH);
//     final dialogMaxH = (availableH * 0.92).clamp(240.0, visibleH * 0.92);

//     return SafeArea(
//       child: Align(
//         // ✅ in landscape, slightly top-align to keep fields visible
//         alignment: isLandscape ? Alignment.topCenter : Alignment.center,
//         child: Dialog(
//           // ✅ Use reservedBottom, not full keyboard height (landscape fix)
//           insetPadding: EdgeInsets.fromLTRB(18, 18, 18, 18 + reservedBottom),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           clipBehavior: Clip.antiAlias,
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxWidth: dialogW,
//               maxHeight: dialogMaxH,
//             ),
//             child: Material(
//               color: Colors.white,
//               child: SingleChildScrollView(
//                 // ✅ key: scroll when keyboard covers area
//                 padding: const EdgeInsets.all(18),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _header(),
//                       const SizedBox(height: 12),
//                       const Divider(height: 1),
//                       const SizedBox(height: 14),

//                       const Text('Full Name *',
//                           style: TextStyle(fontWeight: FontWeight.w900)),
//                       const SizedBox(height: 8),
//                       MJTextField(
//                         controller: _nameCtrl,
//                         focusNode: _nameFocus,
//                         hintText: 'Enter your full name',
//                         textInputAction: TextInputAction.next,
//                         onFieldSubmitted: (_) =>
//                             FocusScope.of(context).requestFocus(_phoneFocus),
//                         validator: (v) {
//                           final t = (v ?? '').trim();
//                           if (t.isEmpty) return 'Full name is required';
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 14),
//                       const Text('Phone Number *',
//                           style: TextStyle(fontWeight: FontWeight.w900)),
//                       const SizedBox(height: 8),
//                       MJTextField(
//                         controller: _phoneCtrl,
//                         focusNode: _phoneFocus,
//                         hintText: 'Enter your phone number',
//                         keyboardType: TextInputType.phone,
//                         textInputAction: TextInputAction.next,
//                         onFieldSubmitted: (_) =>
//                             FocusScope.of(context).requestFocus(_emailFocus),
//                         validator: (v) {
//                           final t = (v ?? '').trim();
//                           if (t.isEmpty) return 'Phone number is required';
//                           if (t.length < 8) return 'Enter valid phone number';
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 14),
//                       const Text('Email (Optional)',
//                           style: TextStyle(fontWeight: FontWeight.w900)),
//                       const SizedBox(height: 8),
//                       MJTextField(
//                         controller: _emailCtrl,
//                         focusNode: _emailFocus,
//                         hintText: 'Enter your email address',
//                         keyboardType: TextInputType.emailAddress,
//                         textInputAction: TextInputAction.done,
//                         onFieldSubmitted: (_) => _submit(),
//                       ),

//                       const SizedBox(height: 18),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _secondaryButton(
//                               text: 'Cancel',
//                               onPressed: () => Navigator.of(context).pop(),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: MJPrimaryButton(
//                               text: 'Continue to Step 3',
//                               onPressed: _submit,
//                               height: 48,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _submit() {
//     FocusScope.of(context).unfocus();
//     if (!_formKey.currentState!.validate()) return;
//     Navigator.of(context).pop();
//     widget.onContinue();
//   }

//   Widget _header() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Icon(Icons.person_outline, size: 34, color: Color(0xFF0B2E5E)),
//         const SizedBox(width: 10),
//         const Expanded(
//           child: Text(
//             'Customer\nDetails',
//             style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
//           ),
//         ),
//         const SizedBox(width: 10),
//         const Expanded(
//           child: Padding(
//             padding: EdgeInsets.only(top: 6),
//             child: Text(
//               'Please provide your details to proceed',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF616161),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _secondaryButton({
//     required String text,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       height: 48,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF616161),
//           foregroundColor: Colors.white,
//           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//           elevation: 0,
//         ),
//         onPressed: onPressed,
//         child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
//       ),
//     );
//   }
// }

//============================================//
//============================================//
//============================================//

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manubhaimlt/core/widgets/mj_primary_button.dart';
import 'package:manubhaimlt/core/widgets/mj_text_field.dart';

class Step2CustomerDetails {
  final String name;
  final String phone;
  final String email;
  const Step2CustomerDetails({
    required this.name,
    required this.phone,
    required this.email,
  });
}

class Step2CustomerDetailsDialog extends StatefulWidget {
  const Step2CustomerDetailsDialog({super.key});

  static Future<Step2CustomerDetails?> show(BuildContext context) {
    return showDialog<Step2CustomerDetails?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Step2CustomerDetailsDialog(),
    );
  }

  @override
  State<Step2CustomerDetailsDialog> createState() =>
      _Step2CustomerDetailsDialogState();
}

class _Step2CustomerDetailsDialogState extends State<Step2CustomerDetailsDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    final screenW = mq.size.width;
    final screenH = mq.size.height;

    final keyboardH = mq.viewInsets.bottom;
    final isLandscape = mq.orientation == Orientation.landscape;

    final safeTop = mq.padding.top;
    final safeBottom = mq.padding.bottom;

    final visibleH = screenH - safeTop - safeBottom;

    final double reservedBottom = isLandscape
        ? (keyboardH * 0.35).clamp(0.0, visibleH * 0.28)
        : keyboardH;

    final dialogW = screenW >= 900 ? 560.0 : (screenW * 0.92);

    final availableH = (visibleH - reservedBottom).clamp(240.0, visibleH);
    final dialogMaxH = (availableH * 0.92).clamp(240.0, visibleH * 0.92);

    return SafeArea(
      child: Align(
        alignment: isLandscape ? Alignment.topCenter : Alignment.center,
        child: Dialog(
          insetPadding: EdgeInsets.fromLTRB(18, 18, 18, 18 + reservedBottom),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogW,
              maxHeight: dialogMaxH,
            ),
            child: Material(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      const Text('Full Name *',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      MJTextField(
                        controller: _nameCtrl,
                        focusNode: _nameFocus,
                        hintText: 'Enter your full name',
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_phoneFocus),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Full name is required';
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),
                      const Text('Phone Number *',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                     
                      const SizedBox(height: 8),

                      MJTextField(
                        controller: _phoneCtrl,
                        focusNode: _phoneFocus,
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocus),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Phone number is required';

                          // allow only digits and exactly 10
                          if (!RegExp(r'^\d{10}$').hasMatch(t)) {
                            return 'Enter a valid 10-digit phone number';
                          }

                          return null;
                        },

                      ),

                      const SizedBox(height: 14),
                      const Text('Email (Optional)',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      MJTextField(
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        hintText: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                      ),

                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _secondaryButton(
                              text: 'Cancel',
                              onPressed: () => Navigator.of(context).pop(null),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MJPrimaryButton(
                              text: 'Continue to Step 3',
                              onPressed: _submit,
                              height: 48,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      Step2CustomerDetails(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person_outline, size: 34, color: Color(0xFF0B2E5E)),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Customer\nDetails',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Please provide your details to proceed',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF616161),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _secondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF616161),
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
