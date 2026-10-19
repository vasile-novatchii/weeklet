import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class NoIconsFoundView extends StatelessWidget {
  const NoIconsFoundView({
    required this.searchTerm,
    super.key,
  });

  final String searchTerm;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      AppLocalizations.of(context).noIconsFoundForSearch(searchTerm),
      style: context.textTheme.bodyLarge,
    ),
  );
}
