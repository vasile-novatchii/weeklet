import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';
import 'package:weeklet/presentation/screens/expenses/expenses_screen.dart';
import 'package:weeklet/presentation/screens/settings/settings_screen.dart';
import 'package:weeklet/presentation/screens/stats/stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ExpensesScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            final statsState = context.read<StatsBloc>().state;
            if (statsState is MonthlyStatsLoaded) {
              context.read<StatsBloc>().add(
                LoadMonthlyStats(
                  month: statsState.month,
                  year: statsState.year,
                ),
              );
            } else {
              context.read<StatsBloc>().add(
                LoadMonthlyStats(year: DateTime.now().year),
              );
            }
          }
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        useLegacyColorScheme: false,
        iconSize: 20,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.navExpenses,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            label: l10n.navStats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
