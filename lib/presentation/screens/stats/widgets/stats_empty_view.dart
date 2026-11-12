import 'package:flutter/material.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/empty_state_view.dart';

class StatsEmptyView extends StatelessWidget {
  const StatsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: EmptyStateView(
        icon: Icons.query_stats_outlined,
        title: l10n.statsEmptyTitle,
        subtitle: l10n.statsEmptySubtitle,
      ),
    );
  }
}
