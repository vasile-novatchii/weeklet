import 'package:flutter/material.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/settings/widgets/legal_document_view.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, this.openUrl});

  /// Overrides the URL opener (used by tests).
  final Future<bool> Function(Uri uri)? openUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTermsTitle),
      ),
      body: LegalDocumentView(
        openUrl: openUrl,
        sections: [
          (title: l10n.termsSection1Title, body: l10n.termsSection1Body),
          (title: l10n.termsSection2Title, body: l10n.termsSection2Body),
          (title: l10n.termsSection3Title, body: l10n.termsSection3Body),
          (title: l10n.termsSection4Title, body: l10n.termsSection4Body),
          (title: l10n.termsSection5Title, body: l10n.termsSection5Body),
          (title: l10n.termsSection6Title, body: l10n.termsSection6Body),
        ],
      ),
    );
  }
}
