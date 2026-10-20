import 'package:flutter/material.dart';

import '../expansion/expansion_module.dart';
import '../heat_transfer/heat_transfer_module.dart';
import '../l10n/app_localizations.dart';
import '../price/price_module.dart';
import 'language_picker.dart';
import 'overview_page.dart';
import 'repository_link.dart';
import 'sem_module.dart';

/// Frame of SEM tools: a top bar with the language picker, and navigation
/// between the overview and the modules — a rail on wide screens, a drawer on
/// narrow ones.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.onLocaleChanged});

  /// Called when the user picks another language in the top bar.
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Every tool, in navigation order.
  late final List<SemModule> _modules = () {
    final heatTransfer = HeatTransferModule();
    return [
      heatTransfer,
      // Can take its heat loss from the heat transport module.
      PriceModule(heatTransfer: heatTransfer.controller),
      // Can take its tube volume from the heat transport module.
      ExpansionModule(heatTransfer: heatTransfer.controller),
    ];
  }();

  /// The open module; `null` is the overview.
  SemModule? _current;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// From this width on, the navigation is a rail instead of a drawer.
  static const _railBreakpoint = 840.0;

  @override
  void dispose() {
    for (final module in _modules) {
      module.dispose();
    }
    super.dispose();
  }

  int get _selectedIndex {
    final current = _current;
    return current == null ? 0 : _modules.indexOf(current) + 1;
  }

  void _select(int index) =>
      setState(() => _current = index == 0 ? null : _modules[index - 1]);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = _current;
    final wide = MediaQuery.sizeOf(context).width >= _railBreakpoint;

    final page = current == null
        ? OverviewPage(
            modules: _modules,
            onOpen: (module) => setState(() => _current = module),
          )
        : current.buildPage(context);

    final destinations = [
      (Icons.dashboard_outlined, Icons.dashboard, l10n.navOverview),
      for (final module in _modules)
        (module.icon, module.selectedIcon, module.title(l10n)),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(current?.pageTitle(l10n) ?? l10n.appTitle),
        actions: [
          if (current != null) ...current.buildActions(context),
          LanguagePicker(onSelected: widget.onLocaleChanged),
          const SizedBox(width: 8),
        ],
      ),
      drawer: wide
          ? null
          : NavigationDrawer(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                _select(index);
                _scaffoldKey.currentState?.closeDrawer();
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 16, 12),
                  child: Text(l10n.appTitle, style: theme.textTheme.titleSmall),
                ),
                for (final (icon, selectedIcon, label) in destinations)
                  NavigationDrawerDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selectedIcon),
                    // The drawer gives labels no flexible space; keep long
                    // ones within the tile.
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    leading: const Icon(Icons.code),
                    title: Text(
                      l10n.sourceCode,
                      style: theme.textTheme.labelLarge,
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: openRepository,
                  ),
                ),
              ],
            ),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  trailing: const Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: RepositoryIconButton(),
                      ),
                    ),
                  ),
                  destinations: [
                    for (final (icon, selectedIcon, label) in destinations)
                      NavigationRailDestination(
                        icon: Icon(icon),
                        selectedIcon: Icon(selectedIcon),
                        label: Text(label),
                      ),
                  ],
                ),
                VerticalDivider(
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(child: page),
              ],
            )
          : page,
    );
  }
}
