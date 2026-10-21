import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/utils/app_bottom_sheet.dart';

/// Bottom sheet for selecting the display language.
/// Options (per D-06): System default, English, Romanian, Russian.
class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

  static Future<void> show(BuildContext context) => showAppBottomSheet<void>(
    context: context,
    builder: (context) => const ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: LanguageSelectionSheet(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<SettingsBloc>().state;
    final currentLocale = state is SettingsLoaded ? state.locale : null;
    final options = [
      (label: l10n.languageSystemDefault, locale: null),
      (label: l10n.languageEnglish, locale: const Locale('en')),
      (label: l10n.languageRomanian, locale: const Locale('ro')),
      (label: l10n.languageRussian, locale: const Locale('ru')),
    ];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.languageSheetTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1.0),
          RadioGroup<Locale?>(
            groupValue: currentLocale,
            onChanged: (value) {
              context.read<SettingsBloc>().add(LocaleChanged(value));
              Navigator.of(context).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map(
                    (option) => RadioListTile<Locale?>(
                      value: option.locale,
                      title: Text(option.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
