import 'package:flutter/material.dart';

/// Opens a modal bottom sheet that always clears the system navigation bar.
///
/// `useSafeArea: true` on [showModalBottomSheet] only avoids top, left and
/// right intrusions, not the bottom one, so the built child is additionally
/// wrapped in a bottom-aware [SafeArea].
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
}) => showModalBottomSheet<T>(
  context: context,
  useSafeArea: true,
  showDragHandle: true,
  isScrollControlled: isScrollControlled,
  useRootNavigator: useRootNavigator,
  builder: (sheetContext) => SafeArea(
    top: false,
    child: builder(sheetContext),
  ),
);
