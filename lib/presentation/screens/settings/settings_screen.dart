import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/router/app_routes.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/settings/widgets/currency_selection_sheet.dart';
import 'package:weeklet/presentation/screens/settings/widgets/language_selection_sheet.dart';
import 'package:weeklet/presentation/screens/settings/widgets/settings_section_header.dart';
import 'package:weeklet/presentation/screens/settings/widgets/settings_tile.dart';
import 'package:weeklet/presentation/screens/settings/widgets/theme_selection_sheet.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/deletion_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = info.version);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _version = '1.0.0');
      }
    }
  }

  Future<void> _showClearPreferencesDialog() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await CustomConfirmationDialog.show(
      context: context,
      icon: Icons.settings_backup_restore,
      iconBackgroundColor: context.colorScheme.primary,
      iconColor: Colors.white,
      title: l10n.clearPreferencesDialogTitle,
      subtitle1: l10n.clearPreferencesDialogSubtitle1,
      subtitle2: l10n.clearPreferencesDialogSubtitle2,
      confirmButtonColor: context.colorScheme.primary,
      confirmButtonTextColor: context.colorScheme.onPrimary,
      confirmButtonText: l10n.clearButtonLabel,
      cancelButtonColor: context.colorScheme.surface,
      cancelButtonTextColor: context.colorScheme.onSurface,
      cancelButtonText: l10n.keepSettingsButtonLabel,
    );
    if (confirmed == true && mounted) {
      context.read<SettingsBloc>().add(const ClearPreferencesRequested());
    }
  }

  Future<void> _showResetAllDataDialog() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await CustomConfirmationDialog.show(
      context: context,
      icon: Icons.delete_forever,
      iconBackgroundColor: context.colorScheme.error,
      iconColor: Colors.white,
      title: l10n.resetDataDialogTitle,
      subtitle1: l10n.resetDataDialogSubtitle1,
      subtitle2: l10n.actionCannotBeUndone,
      confirmButtonColor: context.colorScheme.error,
      confirmButtonTextColor: context.colorScheme.onError,
      confirmButtonText: l10n.resetButtonLabel,
      cancelButtonColor: context.colorScheme.surface,
      cancelButtonTextColor: context.colorScheme.onSurface,
      cancelButtonText: l10n.keepDataButtonLabel,
    );
    if (confirmed == true && mounted) {
      context.read<SettingsBloc>().add(const ResetAllDataRequested());
    }
  }

  Widget _buildCard(List<Widget> tiles) {
    final children = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      children.add(tiles[i]);
      if (i < tiles.length - 1) {
        children.add(const Divider(height: 1, indent: 56));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsScreenTitle),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded && state.actionError != null) {
            final l10n = AppLocalizations.of(context);
            final msg = switch (state.actionError!) {
              'errorBiometricFailed' => l10n.errorBiometricFailed,
              _ => state.actionError!,
            };
            context.showErrorSnackBar(msg);
          }
        },
        builder: (context, state) {
          if (state is SettingsInitial || state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is SettingsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.settingsLoadError,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () => context
                        .read<SettingsBloc>()
                        .add(const LoadSettingsRequested()),
                    child: Text(l10n.retryButtonLabel),
                  ),
                ],
              ),
            );
          }

          if (state is! SettingsLoaded) return const SizedBox.shrink();

          final themeLabel = switch (state.themeMode) {
            ThemeMode.system => l10n.themeSystemDefault,
            ThemeMode.light => l10n.themeLight,
            ThemeMode.dark => l10n.themeDark,
          };

          final languageLabel = switch (state.locale?.languageCode) {
            'ro' => l10n.languageRomanian,
            'ru' => l10n.languageRussian,
            'en' => l10n.languageEnglish,
            _ => l10n.languageSystemDefault,
          };

          return ListView(
            padding: EdgeInsets.only(
              bottom: 48.0 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              // ─── Security ───────────────────────────────────────────────
              SettingsSectionHeader(title: l10n.settingsSectionSecurity),
              _buildCard([
                SettingsTile(
                  leading: const Icon(Icons.fingerprint),
                  title: l10n.settingsBiometricTitle,
                  subtitle: state.biometricEnabled
                      ? l10n.settingsBiometricEnabledSubtitle
                      : l10n.settingsBiometricDisabledSubtitle,
                  trailing: Switch.adaptive(
                    value: state.biometricEnabled,
                    onChanged: (value) => context
                        .read<SettingsBloc>()
                        .add(BiometricToggled(enabled: value)),
                  ),
                ),
              ]),

              // ─── Appearance ─────────────────────────────────────────────
              SettingsSectionHeader(title: l10n.settingsSectionAppearance),
              _buildCard([
                SettingsTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: l10n.settingsThemeTitle,
                  subtitle: themeLabel,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ThemeSelectionSheet.show(context),
                ),
                SettingsTile(
                  leading: const Icon(Icons.language),
                  title: l10n.settingsLanguageTitle,
                  subtitle: languageLabel,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => LanguageSelectionSheet.show(context),
                ),
                SettingsTile(
                  leading: const Icon(Icons.attach_money),
                  title: l10n.settingsCurrencyTitle,
                  subtitle: state.currencySymbol,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => CurrencySelectionSheet.show(context),
                ),
              ]),

              // ─── Data ───────────────────────────────────────────────────
              SettingsSectionHeader(title: l10n.settingsSectionData),
              _buildCard([
                SettingsTile(
                  leading: const Icon(Icons.settings_backup_restore),
                  title: l10n.settingsClearPreferencesTitle,
                  subtitle: l10n.settingsClearPreferencesSubtitle,
                  onTap: _showClearPreferencesDialog,
                ),
              ]),
              const SizedBox(height: 12.0),
              _buildCard([
                SettingsTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: context.colorScheme.error,
                  ),
                  title: l10n.settingsResetDataTitle,
                  subtitle: l10n.settingsResetDataSubtitle,
                  trailing: Icon(
                    Icons.warning_amber_rounded,
                    color: context.colorScheme.error,
                    size: 18.0,
                  ),
                  onTap: _showResetAllDataDialog,
                ),
              ]),

              // ─── Legal ──────────────────────────────────────────────────
              SettingsSectionHeader(title: l10n.settingsSectionLegal),
              _buildCard([
                SettingsTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: l10n.settingsPrivacyPolicyTitle,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.privacyPolicyScreen),
                ),
                SettingsTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: l10n.settingsTermsTitle,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.termsScreen),
                ),
              ]),

              // ─── About ──────────────────────────────────────────────────
              SettingsSectionHeader(title: l10n.settingsSectionAbout),
              _buildCard([
                SettingsTile(
                  leading: const Icon(Icons.info_outline),
                  title: l10n.settingsAppVersionTitle,
                  subtitle: _version.isEmpty ? '...' : _version,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationVersion: _version,
                  ),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }
}
