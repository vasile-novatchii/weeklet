import 'package:flutter/material.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/settings/widgets/legal_document_view.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key, this.openUrl});

  /// Overrides the URL opener (used by tests).
  final Future<bool> Function(Uri uri)? openUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsPrivacyPolicyTitle),
      ),
      body: LegalDocumentView(
        openUrl: openUrl,
        sections: [
          (title: l10n.privacySection1Title, body: l10n.privacySection1Body),
          (title: l10n.privacySection2Title, body: l10n.privacySection2Body),
          (title: l10n.privacySection3Title, body: l10n.privacySection3Body),
          (title: l10n.privacySection4Title, body: l10n.privacySection4Body),
          (title: l10n.privacySection5Title, body: l10n.privacySection5Body),
          (title: l10n.privacySection6Title, body: l10n.privacySection6Body),
          (title: l10n.privacySection7Title, body: l10n.privacySection7Body),
        ],
      ),
    );
  }
}
