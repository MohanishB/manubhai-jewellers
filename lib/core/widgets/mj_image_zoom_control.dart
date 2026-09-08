import 'package:flutter/material.dart';

enum MJImageZoomOrigin {
  center,
  top,
  left,
  bottom,
}

extension MJImageZoomOriginX on MJImageZoomOrigin {
  String get label {
    switch (this) {
      case MJImageZoomOrigin.center:
        return 'Center';
      case MJImageZoomOrigin.top:
        return 'Top';
      case MJImageZoomOrigin.left:
        return 'Left';
      case MJImageZoomOrigin.bottom:
        return 'Bottom';
    }
  }

  Alignment get alignment {
    switch (this) {
      case MJImageZoomOrigin.center:
        return Alignment.center;
      case MJImageZoomOrigin.top:
        return Alignment.topCenter;
      case MJImageZoomOrigin.left:
        return Alignment.centerLeft;
      case MJImageZoomOrigin.bottom:
        return Alignment.bottomCenter;
    }
  }
}

class MJImageZoomPreference {
  final bool enabled;
  final MJImageZoomOrigin origin;

  const MJImageZoomPreference({
    required this.enabled,
    required this.origin,
  });
}

Future<MJImageZoomPreference?> showMJImageZoomPreferenceDialog(
  BuildContext context, {
  required bool initialEnabled,
  required MJImageZoomOrigin initialOrigin,
}) {
  var enabled = initialEnabled;
  var origin = initialOrigin;

  return showDialog<MJImageZoomPreference>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Image Zoom',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apply zoom to all product images?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Yes'),
                          value: true,
                          groupValue: enabled,
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() => enabled = value);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('No'),
                          value: false,
                          groupValue: enabled,
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() => enabled = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MJImageZoomOrigin>(
                    value: origin,
                    decoration: const InputDecoration(
                      labelText: 'Zoom From',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: MJImageZoomOrigin.values
                        .map(
                          (value) => DropdownMenuItem<MJImageZoomOrigin>(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: enabled
                        ? (value) {
                            if (value == null) return;
                            setDialogState(() => origin = value);
                          }
                        : null,
                  ),
                  if (!enabled) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Default API zoom behavior will be used.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    MJImageZoomPreference(
                      enabled: enabled,
                      origin: origin,
                    ),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}
