import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

/// Scrollable legal document: titled sections plus a GitHub repo link.
class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    super.key,
    required this.sections,
    this.openUrl,
  });

  /// Fixed repository URL; never derived from user input.
  static final Uri repoUri = Uri.parse('https://github.com/Infvyr/weeklet');

  final List<({String title, String body})> sections;

  /// Overrides the URL opener (used by tests).
  final Future<bool> Function(Uri uri)? openUrl;

  Future<bool> _open(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  Future<void> _onLinkTap(BuildContext context) async {
    final message = AppLocalizations.of(context).errorGeneric;
    var opened = false;
    try {
      opened = await (openUrl ?? _open)(repoUri);
    } catch (e) {
      debugPrint('[LegalDocumentView._onLinkTap] error: $e');
    }
    if (!opened && context.mounted) {
      context.showErrorSnackBar(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.legalLastUpdated,
            style: context.textTheme.bodySmall,
          ),
          for (final section in sections) ...[
            const SizedBox(height: 16),
            Text(section.title, style: context.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(section.body, style: context.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _onLinkTap(context),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.legalRepoLinkLabel),
          ),
        ],
      ),
    );
  }
}
