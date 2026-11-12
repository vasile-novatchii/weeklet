import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class StatsErrorView extends StatelessWidget {
  const StatsErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: context.colorScheme.error.withValues(alpha: .8),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.statsErrorTitle,
            style: context.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.tryAgainButtonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  context.colorScheme.primary.withValues(alpha: .1),
              foregroundColor: context.colorScheme.primary,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
