import 'package:flutter/material.dart';
import 'package:manubhaimlt/core/theme/app_colors.dart';

class MJMultiSelectChipsDropdownField<T extends Object> extends StatefulWidget {
  final List<T> values; // selected values
  final List<T> options; // all options (without "All ...")
  final String hintText;
  final String Function(T) labelBuilder;
  final ValueChanged<List<T>> onChanged;
  final bool enabled;

  final double height;
  final EdgeInsetsGeometry contentPadding;
  final double dropdownMaxHeight;

  const MJMultiSelectChipsDropdownField({
    super.key,
    required this.values,
    required this.options,
    required this.hintText,
    required this.labelBuilder,
    required this.onChanged,
    this.enabled = true,
    this.height = 46,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.dropdownMaxHeight = 260,
  });

  @override
  State<MJMultiSelectChipsDropdownField<T>> createState() =>
      _MJMultiSelectChipsDropdownFieldState<T>();
}

class _MJMultiSelectChipsDropdownFieldState<T extends Object>
    extends State<MJMultiSelectChipsDropdownField<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _open = false;

  void _toggle() {
    if (!widget.enabled) return;
    if (_open) {
      _close();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_open) return;
    _open = true;

    _overlayEntry = _buildOverlay();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _close() {
    _open = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleValue(T v) {
    final current = List<T>.from(widget.values);
    if (current.contains(v)) {
      current.remove(v);
    } else {
      current.add(v);
    }
    widget.onChanged(current);
    _overlayEntry?.markNeedsBuild();
  }

  void _removeChip(T v) {
    final current = List<T>.from(widget.values);
    current.remove(v);
    widget.onChanged(current);
    _overlayEntry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        final renderBox = this.context.findRenderObject() as RenderBox?;
        final fieldSize = renderBox?.size ?? const Size(280, 46);

        return Stack(
          children: [
            // Tap outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),

            // Dropdown anchored to field
            Positioned(
              width: fieldSize.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, fieldSize.height + 6),
                child: Material(
                  elevation: 6,
                  color: Colors.white,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.dropdownMaxHeight,
                      minWidth: fieldSize.width,
                      maxWidth: fieldSize.width,
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: widget.options.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, thickness: 1),
                      itemBuilder: (_, i) {
                        final opt = widget.options[i];
                        final label = widget.labelBuilder(opt);
                        final selected = widget.values.contains(opt);

                        return InkWell(
                          onTap: () => _toggleValue(opt),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: selected
                                      ? const Icon(Icons.check_box,
                                          size: 18, color: Color(0xFF0B2E5E))
                                      : const Icon(Icons.check_box_outline_blank,
                                          size: 18, color: Color(0xFF9E9E9E)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ This makes it look like website input: border box + chips inside.
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: widget.height,
          padding: widget.contentPadding,
          decoration: BoxDecoration(
            color: AppColors.dropDownBackground,
            border: Border.all(color: AppColors.dropDownBorder, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            children: [
              Expanded(
                child: _ChipsRow<T>(
                  values: widget.values,
                  hintText: widget.hintText,
                  labelBuilder: widget.labelBuilder,
                  enabled: widget.enabled,
                  onRemove: _removeChip,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.dropDownIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipsRow<T extends Object> extends StatelessWidget {
  final List<T> values;
  final String hintText;
  final String Function(T) labelBuilder;
  final bool enabled;
  final ValueChanged<T> onRemove;

  const _ChipsRow({
    required this.values,
    required this.hintText,
    required this.labelBuilder,
    required this.enabled,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      // ✅ Fix #1: no pill/round "Select options"
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          hintText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textFieldHint,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values.map((v) {
          final label = labelBuilder(v);

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _RectChip(
              label: label,
              enabled: enabled,
              onRemove: () => onRemove(v),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RectChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onRemove;

  const _RectChip({
    required this.label,
    required this.enabled,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Fix #2: chip style matches your screenshot (rectangular, subtle bg)
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(width: 6),
          if (enabled)
            InkWell(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16, color: Colors.black87),
            ),
        ],
      ),
    );
  }
}
