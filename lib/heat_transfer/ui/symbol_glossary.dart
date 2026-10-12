import '../../l10n/app_localizations.dart';

/// Every symbol used in the formulas, with its [FormulaText] markup, its TeX
/// form and its unit (`null` for temperatures, which appear in both °C and K,
/// and for dimensionless quantities).
enum Sym {
  heatFlow('Q', 'Q', 'W'),
  heatFlowConvection('Q_{conv}', r'Q_{\mathrm{conv}}', 'W'),
  heatFlowRadiation('Q_{rad}', r'Q_{\mathrm{rad}}', 'W'),
  heatFlowPerMetre("q'", "q'", 'W/m'),
  massFlow('ṁ', r'\dot{m}', 'kg/s'),
  specificHeat('c_p', 'c_p', 'J/kg·K'),
  areaInner('A_i', 'A_i', 'm²'),
  areaOuter('A_o', 'A_o', 'm²'),
  hInner('h_i', 'h_i', 'W/m²·K'),
  hOuter('h_o', 'h_o', 'W/m²·K'),
  hRadiation('h_{rad}', r'h_{\mathrm{rad}}', 'W/m²·K'),
  kPipe('k_p', 'k_p', 'W/m·K'),
  kInsulation('k_{ins}', r'k_{\mathrm{ins}}', 'W/m·K'),
  inletTemp('T_{in}', r'T_{\mathrm{in}}', null),
  outletTemp('T_{out}', r'T_{\mathrm{out}}', null),
  meanFluidTemp('T_m', 'T_m', null),
  ambientTemp('T_∞', r'T_\infty', null),
  surfaceTemp('T_s', 'T_s', null),
  innerWallTemp('T_1', 'T_1', null),
  interfaceTemp('T_2', 'T_2', null),
  deltaT('ΔT', r'\Delta T', 'K'),
  gradient('dT/dr', r'\mathrm{d}T/\mathrm{d}r', 'K/m'),
  radius('r', 'r', 'm'),
  radiusInner('r_1', 'r_1', 'm'),
  radiusPipe('r_2', 'r_2', 'm'),
  radiusOuter('r_3', 'r_3', 'm'),
  length('L', 'L', 'm'),
  resistance('R', 'R', 'K/W'),
  resistanceInnerConvection('R_{conv,i}', r'R_{\mathrm{conv,i}}', 'K/W'),
  resistancePipe('R_{pipe}', r'R_{\mathrm{pipe}}', 'K/W'),
  resistanceInsulation('R_{ins}', r'R_{\mathrm{ins}}', 'K/W'),
  resistanceOuterConvection('R_{conv,o}', r'R_{\mathrm{conv,o}}', 'K/W'),
  resistanceRadiation('R_{rad}', r'R_{\mathrm{rad}}', 'K/W'),
  resistanceOuter('R_{out}', r'R_{\mathrm{out}}', 'K/W'),
  resistanceTotal('ΣR', r'\Sigma R', 'K/W'),
  emissivity('ε', r'\varepsilon', null),
  stefanBoltzmann('σ', r'\sigma', 'W/m²·K⁴');

  const Sym(this.markup, this.tex, this.unit);

  final String markup;
  final String tex;
  final String? unit;

  String description(AppLocalizations l10n) => switch (this) {
    heatFlow => l10n.symbolHeatFlow,
    heatFlowConvection => l10n.symbolHeatFlowConvection,
    heatFlowRadiation => l10n.symbolHeatFlowRadiation,
    heatFlowPerMetre => l10n.symbolHeatFlowPerMetre,
    massFlow => l10n.symbolMassFlow,
    specificHeat => l10n.symbolSpecificHeat,
    areaInner => l10n.symbolAreaInner,
    areaOuter => l10n.symbolAreaOuter,
    hInner => l10n.symbolConvectionCoefficientInner,
    hOuter => l10n.symbolConvectionCoefficientOuter,
    hRadiation => l10n.symbolRadiationCoefficient,
    kPipe => l10n.symbolConductivityPipe,
    kInsulation => l10n.symbolConductivityInsulation,
    inletTemp => l10n.symbolInletTemperature,
    outletTemp => l10n.symbolOutletTemperature,
    meanFluidTemp => l10n.symbolMeanFluidTemperature,
    ambientTemp => l10n.symbolAmbientTemperature,
    surfaceTemp => l10n.symbolSurfaceTemperature,
    innerWallTemp => l10n.symbolInnerWallTemperature,
    interfaceTemp => l10n.symbolInterfaceTemperature,
    deltaT => l10n.symbolTemperatureDifference,
    gradient => l10n.symbolTemperatureGradient,
    radius => l10n.symbolRadius,
    radiusInner => l10n.symbolRadiusInner,
    radiusPipe => l10n.symbolRadiusPipe,
    radiusOuter => l10n.symbolRadiusOuter,
    length => l10n.symbolLength,
    resistance => l10n.symbolResistance,
    resistanceInnerConvection => l10n.symbolResistanceInnerConvection,
    resistancePipe => l10n.symbolResistancePipe,
    resistanceInsulation => l10n.symbolResistanceInsulation,
    resistanceOuterConvection => l10n.symbolResistanceOuterConvection,
    resistanceRadiation => l10n.symbolResistanceRadiation,
    resistanceOuter => l10n.symbolResistanceOuter,
    resistanceTotal => l10n.symbolResistanceTotal,
    emissivity => l10n.symbolEmissivity,
    stefanBoltzmann => l10n.symbolStefanBoltzmann,
  };

  static final _byMarkup = {for (final s in values) s.markup: s};

  static Sym? byMarkup(String markup) => _byMarkup[markup];
}

/// Candidate symbols in [FormulaText] markup. Multi-character symbols come
/// first so they win over their first letter.
final symbolPattern = RegExp(
  r"(?<![A-Za-z])(ΣR|ΔT|dT/dr|q'|ṁ|[A-Za-zεσ](?:_\{[^}]*\}|_[^\s{])?)"
  r'(?![A-Za-z])',
);

/// Description and unit of a formula symbol in [FormulaText] markup, or
/// `null` when it is not a known symbol (e.g. a unit such as `m` or `K`).
(String, String?)? describeSymbol(String markup, AppLocalizations l10n) {
  final sym = Sym.byMarkup(markup);
  return sym == null ? null : (sym.description(l10n), sym.unit);
}
