import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/utils/app_bottom_sheet.dart';

/// Bottom sheet for selecting the app theme.
/// Options: System default, Light, Dark.
class ThemeSelectionSheet extends StatelessWidget {
  const ThemeSelectionSheet({super.key});

  static Future<void> show(BuildContext context) => showAppBottomSheet<void>(
    context: context,
    builder: (context) => const ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: ThemeSelectionSheet(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsBloc>().state;
    final currentTheme = state is SettingsLoaded
        ? state.themeMode
        : ThemeMode.system;

    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.settingsThemeTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1.0),
          RadioGroup<ThemeMode>(
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsBloc>().add(ThemeChanged(value));
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(l10n.themeSystemDefault),
                  subtitle: Text(l10n.themeSystemDefaultSubtitle),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text(l10n.themeLight),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text(l10n.themeDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
