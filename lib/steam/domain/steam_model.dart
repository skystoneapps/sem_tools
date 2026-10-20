import 'dart:math' as math;

import 'steam_tables.dart';

export 'steam_tables.dart';

/// Critical pressure of water in bar (absolute): 22 064 kPa = 220.64 bar.
const double waterCriticalPressureBar = 220.64;

/// Critical temperature of water in °C.
const double waterCriticalTempCelsius = 373.95;

/// Kilograms in a metric ton (1 t = 1000 kg).
const double kgPerTon = 1000.0;

/// Seconds in an hour (1 h = 3600 s).
const double secondsPerHour = 3600.0;

/// Looks up saturated liquid enthalpy h₁ ≈ h_{f @ T₁} in kJ/kg from Table A-4
/// at temperature [tempC] (in °C).
double lookupLiquidEnthalpyA4(double tempC) {
  final t = tempC.clamp(tableA4.first.$1, tableA4.last.$1);
  if (t <= tableA4.first.$1) return tableA4.first.$2;
  for (var i = 1; i < tableA4.length; i++) {
    final (t1, hf1, _, _) = tableA4[i];
    if (t <= t1) {
      final (t0, hf0, _, _) = tableA4[i - 1];
      final frac = (t - t0) / (t1 - t0);
      return hf0 + frac * (hf1 - hf0);
    }
  }
  return tableA4.last.$2;
}

/// Saturation properties `(T_sat in °C, h_f in kJ/kg, h_fg in kJ/kg, h_g in kJ/kg)`
/// at absolute pressure [pressureBar] (in bar), interpolated from Table A-5
/// (where P is in kPa = 100 · bar).
({double tSat, double hf, double hfg, double hg}) lookupSaturationA5(
  double pressureBar,
) {
  final pKpa = (pressureBar * 100.0).clamp(tableA5.first.$1, tableA5.last.$1);
  if (pKpa <= tableA5.first.$1) {
    final (_, tSat, hf, hfg, hg) = tableA5.first;
    return (tSat: tSat, hf: hf, hfg: hfg, hg: hg);
  }
  for (var i = 1; i < tableA5.length; i++) {
    final (p1, t1, hf1, hfg1, hg1) = tableA5[i];
    if (pKpa <= p1) {
      final (p0, t0, hf0, hfg0, hg0) = tableA5[i - 1];
      final frac = (pKpa - p0) / (p1 - p0);
      return (
        tSat: t0 + frac * (t1 - t0),
        hf: hf0 + frac * (hf1 - hf0),
        hfg: hfg0 + frac * (hfg1 - hfg0),
        hg: hg0 + frac * (hg1 - hg0),
      );
    }
  }
  final (_, tSat, hf, hfg, hg) = tableA5.last;
  return (tSat: tSat, hf: hf, hfg: hfg, hg: hg);
}

/// Saturation (boiling) temperature T_sat in °C at [pressureBar] from Table A-5.
double waterSaturationTempCelsius(double pressureBar) =>
    lookupSaturationA5(pressureBar).tSat;

/// Latent heat of vaporisation h_fg in kJ/kg at [pressureBar] from Table A-5.
double waterLatentHeatKjPerKg(double pressureBar) =>
    lookupSaturationA5(pressureBar).hfg;

/// Superheated steam enthalpy h₂ in kJ/kg at absolute pressure [pressureBar]
/// (in bar) and temperature [steamTempC] (in °C), interpolated from Table A-6.
///
/// When [steamTempC] <= T_sat, returns h_g from Table A-5.
double lookupSuperheatedEnthalpyA6(double pressureBar, double steamTempC) {
  final sat = lookupSaturationA5(pressureBar);
  if (steamTempC <= sat.tSat + 1e-6) return sat.hg;

  final pMpa = pressureBar / 10.0;
  if (pMpa <= tableA6.first.pMpa) {
    return tableA6.first.enthalpyAt(steamTempC);
  }
  for (var i = 1; i < tableA6.length; i++) {
    final iso1 = tableA6[i];
    if (pMpa <= iso1.pMpa) {
      final iso0 = tableA6[i - 1];
      if ((pMpa - iso0.pMpa).abs() < 1e-9) return iso0.enthalpyAt(steamTempC);
      if ((pMpa - iso1.pMpa).abs() < 1e-9) return iso1.enthalpyAt(steamTempC);
      final frac = (pMpa - iso0.pMpa) / (iso1.pMpa - iso0.pMpa);
      // Evaluate superheat Δh_sup(ΔT_sup) on both bounding isobars so that
      // pressures between two Table A-6 blocks stay smooth right down to T_sat.
      final dtSup = steamTempC - sat.tSat;
      final dh0 = iso0.enthalpyAt(iso0.tSat + dtSup) - iso0.hgSat;
      final dh1 = iso1.enthalpyAt(iso1.tSat + dtSup) - iso1.hgSat;
      return sat.hg + dh0 + frac * (dh1 - dh0);
    }
  }
  final last = tableA6.last;
  final dtSup = steamTempC - sat.tSat;
  final dh = last.enthalpyAt(last.tSat + dtSup) - last.hgSat;
  return sat.hg + dh;
}

/// Stage of heating liquid water into (superheated) steam at constant pressure.
enum SteamStage {
  /// Heating subcooled liquid from T₁ to T_sat: q₁ = h_f − h₁.
  liquidHeating,

  /// Isobaric phase change at T_sat: q₂ = h_fg = h_g − h_f.
  evaporation,

  /// Heating saturated steam from T_sat to T₂: q₃ = h₂ − h_g.
  superheating,
}

/// Unit in which the optional steam mass flow rate (stoomdebiet) is entered.
enum SteamFlowUnit {
  /// Tons per hour (t/h), e.g. 1.5 t/h = 1500 kg / 3600 s.
  tonPerHour,

  /// Kilograms per second (kg/s).
  kgPerSecond,
}

/// Variables of the steam heat calculation (using Tables A-4, A-5 and A-6).
class SteamInputs {
  const SteamInputs({
    this.pressureBar = 5.0,
    this.startTemp = 20.0,
    this.steamTemp = 200.0,
    this.includeFlow = false,
    this.flowRate = 1.5,
    this.flowUnit = SteamFlowUnit.tonPerHour,
  });

  /// Absolute pressure P in bar (1 bar = 100 kPa = 0.1 MPa).
  final double pressureBar;

  /// Initial liquid water temperature T₁ in °C.
  final double startTemp;

  /// Final (target) steam temperature T₂ in °C.
  final double steamTemp;

  /// Whether a steam flow rate (stoomdebiet) is included to compute power in kW.
  final bool includeFlow;

  /// Steam mass flow rate in [flowUnit] (default: 1.5 t/h).
  final double flowRate;

  /// Unit of [flowRate] (`t/h` or `kg/s`).
  final SteamFlowUnit flowUnit;

  /// Pressure P in kPa (as listed in Table A-5).
  double get pressureKpa => pressureBar * 100.0;

  /// Pressure P in MPa (as listed in Table A-6).
  double get pressureMpa => pressureBar / 10.0;

  /// Saturation temperature T_sat in °C at [pressureBar] from Table A-5.
  double get saturationTemp => lookupSaturationA5(pressureBar).tSat;

  /// Mass flow rate ṁ in kg/s.
  double get massFlowKgPerS => switch (flowUnit) {
    SteamFlowUnit.tonPerHour => flowRate * kgPerTon / secondsPerHour,
    SteamFlowUnit.kgPerSecond => flowRate,
  };

  SteamInputs copyWith({
    double? pressureBar,
    double? startTemp,
    double? steamTemp,
    bool? includeFlow,
    double? flowRate,
    SteamFlowUnit? flowUnit,
  }) {
    return SteamInputs(
      pressureBar: pressureBar ?? this.pressureBar,
      startTemp: startTemp ?? this.startTemp,
      steamTemp: steamTemp ?? this.steamTemp,
      includeFlow: includeFlow ?? this.includeFlow,
      flowRate: flowRate ?? this.flowRate,
      flowUnit: flowUnit ?? this.flowUnit,
    );
  }
}

/// Result of a single stage in the steam generation process.
class SteamStageResult {
  const SteamStageResult({
    required this.stage,
    required this.tStart,
    required this.tEnd,
    required this.hStart,
    required this.hEnd,
  });

  final SteamStage stage;

  /// Temperature at the start of the stage, in °C.
  final double tStart;

  /// Temperature at the end of the stage, in °C.
  final double tEnd;

  /// Specific enthalpy h at the start of the stage, in kJ/kg.
  final double hStart;

  /// Specific enthalpy h at the end of the stage, in kJ/kg.
  final double hEnd;

  /// Specific heat q = hEnd − hStart added during this stage, in kJ/kg.
  double get specificHeat => math.max(0.0, hEnd - hStart);

  /// Temperature rise ΔT across this stage, in K.
  double get deltaT => tEnd - tStart;
}

/// Complete result of the steam heat calculation from Tables A-4, A-5 and A-6.
class SteamResult {
  const SteamResult({
    required this.inputs,
    required this.tSat,
    required this.h1,
    required this.hf,
    required this.hfg,
    required this.hg,
    required this.h2,
    required this.stages,
  });

  final SteamInputs inputs;

  /// Saturation temperature T_sat in °C (Table A-5 at P).
  final double tSat;

  /// Initial liquid enthalpy h₁ ≈ h_{f @ T₁} in kJ/kg (Table A-4 at T₁).
  final double h1;

  /// Saturated liquid enthalpy h_f in kJ/kg (Table A-5 at P).
  final double hf;

  /// Latent heat of vaporisation h_fg in kJ/kg (Table A-5 at P).
  final double hfg;

  /// Saturated vapour enthalpy h_g in kJ/kg (Table A-5 at P).
  final double hg;

  /// Final steam enthalpy h₂ in kJ/kg (Table A-6 at P, T₂; or h_g when T₂ = T_sat).
  final double h2;

  /// Results of the three stages in order.
  final List<SteamStageResult> stages;

  /// Sensible heat to warm liquid water from T₁ to T_sat: q₁ = h_f − h₁ (kJ/kg).
  double get qLiquid => stages[0].specificHeat;

  /// Latent heat to evaporate saturated water at T_sat: q₂ = h_fg (kJ/kg).
  double get qEvaporation => stages[1].specificHeat;

  /// Sensible heat to superheat steam from T_sat to T₂: q₃ = h₂ − h_g (kJ/kg).
  double get qSuperheat => stages[2].specificHeat;

  /// Total specific heat transfer q = h₂ − h₁ = q₁ + q₂ + q₃, in kJ/kg.
  double get qTotal => qLiquid + qEvaporation + qSuperheat;

  /// Whether the initial temperature T₁ is at or below T_sat.
  bool get startTempValid => inputs.startTemp <= tSat + 1e-6;

  /// Whether the target steam temperature T₂ is at or above T_sat.
  bool get steamTempValid => inputs.steamTemp >= tSat - 1e-6;

  /// Whether the temperatures form a valid liquid-to-steam heating path
  /// (T₁ ≤ T_sat ≤ T₂).
  bool get temperaturesValid => startTempValid && steamTempValid;

  /// Whether the target state is superheated (T₂ > T_sat) rather than dry
  /// saturated steam (T₂ = T_sat).
  bool get isSuperheated => inputs.steamTemp > tSat + 1e-3;

  /// Degree of superheat ΔT_sup = T₂ − T_sat, in K.
  double get superheatDeltaT => math.max(0.0, inputs.steamTemp - tSat);

  /// Liquid heating temperature rise ΔT_l = T_sat − T₁, in K.
  double get liquidDeltaT => math.max(0.0, tSat - inputs.startTemp);

  /// Mass flow rate ṁ in kg/s.
  double get massFlowKgPerS => inputs.massFlowKgPerS;

  /// Thermal power Q̇ = ṁ·q in kW (since 1 kg/s · 1 kJ/kg = 1 kJ/s = 1 kW).
  double get powerKw => massFlowKgPerS * qTotal;

  /// Thermal power Q̇ in MW.
  double get powerMw => powerKw / 1000.0;

  /// Thermal power for a single stage, in kW.
  double stagePowerKw(SteamStage stage) =>
      massFlowKgPerS * this[stage].specificHeat;

  SteamStageResult operator [](SteamStage stage) =>
      stages.firstWhere((s) => s.stage == stage);
}

SteamResult calculateSteam(SteamInputs inputs) {
  final sat = lookupSaturationA5(inputs.pressureBar);
  final tSat = sat.tSat;
  final hf = sat.hf;
  final hfg = sat.hfg;
  final hg = sat.hg;

  final t1Eff = math.min(inputs.startTemp, tSat);
  final t2Eff = math.max(inputs.steamTemp, tSat);

  final h1 = inputs.startTemp >= tSat
      ? hf
      : math.min(lookupLiquidEnthalpyA4(t1Eff), hf);
  final h2 = inputs.steamTemp <= tSat
      ? hg
      : math.max(lookupSuperheatedEnthalpyA6(inputs.pressureBar, t2Eff), hg);

  final stages = [
    SteamStageResult(
      stage: SteamStage.liquidHeating,
      tStart: t1Eff,
      tEnd: tSat,
      hStart: h1,
      hEnd: hf,
    ),
    SteamStageResult(
      stage: SteamStage.evaporation,
      tStart: tSat,
      tEnd: tSat,
      hStart: hf,
      hEnd: hg,
    ),
    SteamStageResult(
      stage: SteamStage.superheating,
      tStart: tSat,
      tEnd: t2Eff,
      hStart: hg,
      hEnd: h2,
    ),
  ];

  return SteamResult(
    inputs: inputs,
    tSat: tSat,
    h1: h1,
    hf: hf,
    hfg: hfg,
    hg: hg,
    h2: h2,
    stages: stages,
  );
}
