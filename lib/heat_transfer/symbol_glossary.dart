import '../l10n/app_localizations.dart';

/// Formula symbols that get a hover explanation, in [FormulaText] markup.
/// Multi-character symbols come first so they win over their first letter.
final symbolPattern = RegExp(
  r"(?<![A-Za-z])(ΣR|ΔT|dT/dr|q'|[A-Za-zεσ](?:_\{[^}]*\}|_[^\s{])?)"
  r'(?![A-Za-z])',
);

/// Description and unit of a formula [symbol], or `null` when it is not a
/// known symbol (e.g. a unit such as `m` or `K`).
(String, String?)? describeSymbol(String symbol, AppLocalizations l10n) {
  return switch (symbol) {
    'Q' => (l10n.symbolHeatFlow, 'W'),
    'Q_{conv}' => (l10n.symbolHeatFlowConvection, 'W'),
    'Q_{rad}' => (l10n.symbolHeatFlowRadiation, 'W'),
    "q'" => (l10n.symbolHeatFlowPerMetre, 'W/m'),
    'A' => (l10n.symbolArea, 'm²'),
    'A_i' => (l10n.symbolAreaInner, 'm²'),
    'A_o' => (l10n.symbolAreaOuter, 'm²'),
    'h' => (l10n.symbolConvectionCoefficient, 'W/m²·K'),
    'h_i' => (l10n.symbolConvectionCoefficientInner, 'W/m²·K'),
    'h_o' => (l10n.symbolConvectionCoefficientOuter, 'W/m²·K'),
    'h_{rad}' => (l10n.symbolRadiationCoefficient, 'W/m²·K'),
    'k' => (l10n.symbolConductivity, 'W/m·K'),
    'k_p' => (l10n.symbolConductivityPipe, 'W/m·K'),
    'k_{ins}' => (l10n.symbolConductivityInsulation, 'W/m·K'),
    'T_f' => (l10n.symbolFluidTemperature, null),
    'T_∞' => (l10n.symbolAmbientTemperature, null),
    'T_s' => (l10n.symbolSurfaceTemperature, null),
    'T_1' => (l10n.symbolInnerWallTemperature, null),
    'T_2' => (l10n.symbolInterfaceTemperature, null),
    'T_{sur}' => (l10n.symbolSurroundingsTemperature, null),
    'ΔT' => (l10n.symbolTemperatureDifference, 'K'),
    'dT/dr' => (l10n.symbolTemperatureGradient, 'K/m'),
    'r' => (l10n.symbolRadius, 'm'),
    'r_1' => (l10n.symbolRadiusInner, 'm'),
    'r_2' => (l10n.symbolRadiusPipe, 'm'),
    'r_3' => (l10n.symbolRadiusOuter, 'm'),
    'L' => (l10n.symbolLength, 'm'),
    'R' => (l10n.symbolResistance, 'K/W'),
    'R_{conv,i}' => (l10n.symbolResistanceInnerConvection, 'K/W'),
    'R_{pipe}' => (l10n.symbolResistancePipe, 'K/W'),
    'R_{ins}' => (l10n.symbolResistanceInsulation, 'K/W'),
    'R_{conv,o}' => (l10n.symbolResistanceOuterConvection, 'K/W'),
    'R_{rad}' => (l10n.symbolResistanceRadiation, 'K/W'),
    'R_{out}' => (l10n.symbolResistanceOuter, 'K/W'),
    'ΣR' => (l10n.symbolResistanceTotal, 'K/W'),
    'ε' => (l10n.symbolEmissivity, null),
    'σ' => (l10n.symbolStefanBoltzmann, 'W/m²·K⁴'),
    _ => null,
  };
}
