import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'details_pane.dart';
import '../domain/heat_transfer.dart';
import 'heat_palette.dart';
import 'heat_transfer_controller.dart';
import 'inputs_panel.dart';
import 'results_panel.dart';
import 'tube_painter.dart';

/// Heat transport through an insulated tube: the tube, its variables and the
/// results on the left, the calculation of the selected stage on the right.
class HeatTransferScreen extends StatefulWidget {
  const HeatTransferScreen({super.key, required this.controller});

  final HeatTransferController controller;

  @override
  State<HeatTransferScreen> createState() => _HeatTransferScreenState();
}

class _HeatTransferScreenState extends State<HeatTransferScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => _build(context),
  );

  Widget _build(BuildContext context) {
    final controller = widget.controller;
    final result = calculateHeatTransfer(controller.inputs);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final tube = _TubeView(
      result: result,
      selected: controller.selected,
      flow: _flow,
    );
    final inputs = InputsSection(
      inputs: controller.inputs,
      child: InputsPanel(
        key: ValueKey(controller.resetCount),
        inputs: controller.inputs,
        onChanged: (value) => controller.inputs = value,
      ),
    );
    void select(HeatStage? stage) => controller.selected = stage;
    void includeRadiation(bool value) =>
        controller.inputs = controller.inputs.copyWith(includeRadiation: value);
    ResultsPanel results({VoidCallback? afterSelect}) => ResultsPanel(
      result: result,
      selected: controller.selected,
      onSelected: (stage) {
        select(stage);
        afterSelect?.call();
      },
      onIncludeRadiationChanged: includeRadiation,
    );
    final details = DetailsPane(
      result: result,
      selected: controller.selected,
      onSelected: select,
      onIncludeRadiationChanged: includeRadiation,
    );

    return LayoutBuilder(
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
