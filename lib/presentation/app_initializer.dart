import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/di/service_locator.dart' show sl;
import 'package:weeklet/core/services/biometric_service.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';

/// Widget responsible for initializing app data on startup and managing
/// the biometric gate overlay on foreground resume.
class AppInitializer extends StatefulWidget {
  const AppInitializer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late final AppLifecycleListener _lifecycleListener;
  bool _isLocked = false;
  bool _defaultCategoryRequested = false;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onResume,
    );
    _initializeAppData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Localizations are only reachable after initState, so the one-time
    // default-category seeding (and categories load) happens here. The name
    // is resolved with the locale in effect now and is never renamed later.
    if (_defaultCategoryRequested) return;
    _defaultCategoryRequested = true;
    context.read<CategoryBloc>().add(
      EnsureDefaultCategoryRequested(
        localizedName: AppLocalizations.of(context).defaultCategoryName,
      ),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _initializeAppData() {
    // Load settings FIRST — MaterialApp reads theme/locale from SettingsBloc
    context.read<SettingsBloc>().add(const LoadSettingsRequested());

    // Load all expenses
    context.read<ExpenseBloc>().add(const LoadExpensesRequested());

    // Load all incomes
    context.read<IncomeBloc>().add(const LoadIncomesRequested());

    // Categories (with default seeding) load from didChangeDependencies,
    // where localizations are available.

    // Preload stats so the Stats screen shows data immediately without a spinner
    context.read<StatsBloc>().add(
      LoadMonthlyStats(year: DateTime.now().year),
    );
  }

  void _onResume() {
    // Biometric gate only applies on mobile platforms — local_auth does not
    // reliably support macOS/desktop in debug/simulator builds.
    if (!Platform.isIOS && !Platform.isAndroid) return;

    // Check biometric state from DI (not context — this is a lifecycle callback,
    // context.read may not be available depending on widget tree state)
    final settingsState = sl<SettingsBloc>().state;
    if (settingsState is SettingsLoaded && settingsState.biometricEnabled) {
      if (mounted) {
        setState(() => _isLocked = true);
      }
    }
  }

  Future<void> _unlock() async {
    final l10n = AppLocalizations.of(context);
    final authenticated = await sl<BiometricService>().authenticate(
      reason: l10n.biometricAuthReason,
    );
    if (authenticated && mounted) {
      setState(() => _isLocked = false);
    }
    // If not authenticated: overlay stays, user can tap "Try Again"
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (_isLocked) _BiometricGateOverlay(onTryAgain: _unlock),
    ],
  );
}

/// Full-screen biometric gate overlay.
///
/// Cannot be dismissed by back gesture (absorbs all input via [Scaffold]).
/// Shows app icon, heading, body text, and "Try Again" button.
class _BiometricGateOverlay extends StatelessWidget {
  const _BiometricGateOverlay({required this.onTryAgain});

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon placeholder — 64x64 dp as per UI-SPEC
                const FlutterLogo(size: 64.0),
                const SizedBox(height: 24.0),
                Text(
                  l10n.biometricGateTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  l10n.biometricGateSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                FilledButton(
                  onPressed: onTryAgain,
                  child: Text(l10n.tryAgainButtonLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
