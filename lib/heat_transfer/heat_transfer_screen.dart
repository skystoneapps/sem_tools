import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'details_pane.dart';
import 'heat_model.dart';
import 'heat_palette.dart';
import 'inputs_panel.dart';
import 'results_panel.dart';
import 'tube_painter.dart';

/// Heat transport through an insulated tube: the tube, its variables and the
/// results on the left, the calculation of the selected stage on the right.
class HeatTransferScreen extends StatefulWidget {
  const HeatTransferScreen({super.key, required this.onLocaleChanged});

  /// Called when the user picks another language in the top bar.
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<HeatTransferScreen> createState() => _HeatTransferScreenState();
}

class _HeatTransferScreenState extends State<HeatTransferScreen>
    with SingleTickerProviderStateMixin {
  TubeInputs _inputs = const TubeInputs();

  /// Stage shown in the detail pane; `null` shows the total.
  HeatStage? _selected = HeatStage.innerConvection;
  int _resetCount = 0;

  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _inputs = const TubeInputs();
      _resetCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = calculateHeatTransfer(_inputs);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final tube = _TubeView(result: result, selected: _selected, flow: _flow);
    final inputs = InputsSection(
      inputs: _inputs,
      child: InputsPanel(
        key: ValueKey(_resetCount),
        inputs: _inputs,
        onChanged: (value) => setState(() => _inputs = value),
      ),
    );
    void select(HeatStage? stage) => setState(() => _selected = stage);
    void includeRadiation(bool value) =>
        setState(() => _inputs = _inputs.copyWith(includeRadiation: value));
    ResultsPanel results({VoidCallback? afterSelect}) => ResultsPanel(
      result: result,
      selected: _selected,
      onSelected: (stage) {
        select(stage);
        afterSelect?.call();
      },
      onIncludeRadiationChanged: includeRadiation,
    );
    final details = DetailsPane(
      result: result,
      selected: _selected,
      onSelected: select,
      onIncludeRadiationChanged: includeRadiation,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenTitle),
        actions: [
          _LanguagePicker(onSelected: widget.onLocaleChanged),
          IconButton(
            tooltip: l10n.resetTooltip,
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1000) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    children: [
                      tube,
                      const SizedBox(height: 8),
                      inputs,
                      results(),
                    ],
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                SizedBox(
                  width: (constraints.maxWidth * 0.42).clamp(440, 620),
                  child: ColoredBox(
                    color: theme.colorScheme.surfaceContainerLow,
                    child: details,
                  ),
                ),
              ],
            );
          }
          // Narrow screens: the detail pane goes in its own tab.
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: l10n.tabTubeAndVariables),
                    Tab(text: l10n.tabDetails),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Builder(
                        // Picking a result row jumps to its details.
                        builder: (context) => ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          children: [
                            tube,
                            const SizedBox(height: 8),
                            inputs,
                            results(
                              afterSelect: () =>
                                  DefaultTabController.of(context).animateTo(1),
                            ),
                          ],
                        ),
                      ),
                      ColoredBox(
                        color: theme.colorScheme.surfaceContainerLow,
                        child: details,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TubeView extends StatelessWidget {
  const _TubeView({
    required this.result,
    required this.selected,
    required this.flow,
  });

  final HeatTransferResult result;
  final HeatStage? selected;
  final Animation<double> flow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: TubePainter(
            result: result,
            palette: HeatPalette.of(context),
            l10n: AppLocalizations.of(context),
            textStyle: DefaultTextStyle.of(context).style
                .copyWith(fontSize: 13),
            highlighted: selected,
            animation: flow,
          ),
        ),
      ),
    );
  }
}

/// Language names in their own language, so each is recognisable whatever
/// the current language is.
const _languageNames = {'en': 'English', 'nl': 'Nederlands'};

/// Top-bar button showing the current language; opens a menu to switch.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.onSelected});

  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<Locale>(
      tooltip: AppLocalizations.of(context).languageTooltip,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final locale in AppLocalizations.supportedLocales)
          CheckedPopupMenuItem(
            value: locale,
            checked: locale.languageCode == current,
            child: Text(
              _languageNames[locale.languageCode] ?? locale.languageCode,
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 20),
            const SizedBox(width: 6),
            Text(current.toUpperCase(), style: theme.textTheme.labelLarge),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
