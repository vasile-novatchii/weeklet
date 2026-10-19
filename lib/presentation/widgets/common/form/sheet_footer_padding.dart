import 'package:flutter/material.dart';

/// Padding for bottom sheet action bars that keeps buttons clear of the
/// system gesture/navigation bar.
class SheetFooterPadding extends StatelessWidget {
  const SheetFooterPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      12,
      16,
      12 + 8 + MediaQuery.viewPaddingOf(context).bottom,
    ),
    child: child,
  );
}
