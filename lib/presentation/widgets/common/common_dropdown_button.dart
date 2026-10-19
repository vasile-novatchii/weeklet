import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/theme/colors.dart';
import 'package:weeklet/l10n/app_localizations.dart';

/// Generic dropdown button component with clean UX
///
/// Displays a button with selected value and dropdown menu
class CommonDropdownButton<T extends Object?> extends StatefulWidget {
  const CommonDropdownButton({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.selectedItem,
    required this.onChanged,
    this.label,
    required this.hint,
    this.isLoading = false,
    this.errorText,
  });

  /// List of items to display in dropdown
  final List<T> items;

  /// Builder function to display each item
  /// Returns a widget to display for each item
  final Widget Function(T item) itemBuilder;

  /// Currently selected item
  final T? selectedItem;

  /// Called when user selects an item
  final ValueChanged<T?> onChanged;

  /// Optional label above the dropdown
  final String? label;

  /// Text to show when nothing is selected
  final String hint;

  /// Show loading indicator
  final bool isLoading;

  /// Error message to display
  final String? errorText;

  @override
  State<CommonDropdownButton<T>> createState() =>
      _CommonDropdownButtonState<T>();
}

class _CommonDropdownButtonState<T extends Object?>
    extends State<CommonDropdownButton<T>> {
  late GlobalKey _buttonKey;
  double _buttonWidth = double.infinity;

  @override
  void initState() {
    super.initState();
    _buttonKey = GlobalKey();
  }

  /// Update button width after layout
  void _updateButtonWidth() {
    final size = _buttonKey.currentContext?.size;
    if (size != null && _buttonWidth != size.width) {
      setState(() {
        _buttonWidth = size.width;
      });
    }
  }

  /// Check if the selected item is in the items list
  bool _isItemSelected() {
    final selected = widget.selectedItem;
    if (selected == null) {
      return widget.items.any((item) => item == null);
    }
    return widget.items.contains(selected);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonWidth();
    });

    return Column(
      crossAxisAlignment: .start,
      spacing: 8,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: context.labelMedium?.copyWith(
              fontWeight: .w500,
            ),
          ),
        MenuAnchor(
          alignmentOffset: const Offset(0, 8),
          consumeOutsideTap: true,
          style: MenuStyle(
            padding: WidgetStateProperty.all(.zero),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: .circular(8),
              ),
            ),
            backgroundColor: WidgetStateProperty.all(
              context.isDarkMode
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
            ),
          ),
          builder: (context, controller, ___) => SizedBox(
            key: _buttonKey,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.darkInputFill
                    : AppColors.lightInputFill,
                border: Border.all(
                  color: widget.errorText != null
                      ? context.colorScheme.error
                      : context.colorScheme.outline,
                ),
                borderRadius: .circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: .circular(8),
                child: InkWell(
                  onTap: widget.isLoading
                      ? null
                      : () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                  borderRadius: .circular(8),
                  child: Padding(
                    padding: const .only(
                      left: 16,
                      right: 8,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Expanded(
                          child: widget.isLoading
                              ? Text(
                                  AppLocalizations.of(
                                    context,
                                  ).dropdownLoadingLabel,
                                  style: context.bodyLarge?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : _isItemSelected()
                              ? widget.itemBuilder(widget.selectedItem as T)
                              : Text(
                                  widget.hint,
                                  style: context.bodyLarge?.copyWith(
                                    color: context
                                        .colorScheme
                                        .surfaceContainerHighest,
                                  ),
                                ),
                        ),
                        Icon(
                          Icons.expand_more,
                          color: context.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          menuChildren: widget.items
              .map(
                (item) => ClipRRect(
                  borderRadius: .circular(8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: _buttonWidth),
                    child: MenuItemButton(
                      onPressed: () => widget.onChanged(item),
                      child: widget.itemBuilder(item),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const .only(left: 16),
            child: Text(
              widget.errorText!,
              style: context.labelSmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
