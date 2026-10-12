/// The heat transfer laws used by the calculator, one function per law, in
/// SI units. Temperatures are in °C unless stated otherwise.
library;

import 'dart:math' as math;

/// Stefan–Boltzmann constant in W/(m²·K⁴).
const double stefanBoltzmann = 5.670374419e-8;

/// Offset between degrees Celsius and kelvin.
const double kelvinOffset = 273.15;

double toKelvin(double celsius) => celsius + kelvinOffset;

/// Lateral area of a cylinder of radius [radius] and [length]: A = 2πrL.
double cylinderArea(double radius, double length) =>
    2 * math.pi * radius * length;

/// Resistance of heat transfer at a surface with coefficient [h] over [area]:
/// R = 1 / (h·A). Used for convection and for linearised radiation.
double surfaceResistance(double h, double area) => 1 / (h * area);

/// Fourier's law integrated over a cylindrical layer between [innerRadius]
/// and [outerRadius] with conductivity [k]: R = ln(r₂/r₁) / (2πkL).
double cylinderConductionResistance(
  double innerRadius,
  double outerRadius,
  double k,
  double length,
) => math.log(outerRadius / innerRadius) / (2 * math.pi * k * length);

/// Newton's law of cooling: Q = h·A·(T_s − T∞).
double convectionHeatFlow(
  double h,
  double area,
  double surfaceTemp,
  double ambientTemp,
) => h * area * (surfaceTemp - ambientTemp);

/// Stefan–Boltzmann law: Q = ε·σ·A·(T_s⁴ − T∞⁴), with temperatures in K.
double radiationHeatFlow(
  double emissivity,
  double area,
  double surfaceTemp,
  double ambientTemp,
) =>
    emissivity *
    stefanBoltzmann *
    area *
    (math.pow(toKelvin(surfaceTemp), 4) - math.pow(toKelvin(ambientTemp), 4));

/// Linearised radiation coefficient h_rad = εσ(T_s² + T∞²)(T_s + T∞), so
/// that radiation can be written as a resistance 1 / (h_rad·A).
double radiationCoefficient(
  double emissivity,
  double surfaceTemp,
  double ambientTemp,
) {
  final ts = toKelvin(surfaceTemp);
  final tInf = toKelvin(ambientTemp);
  return emissivity * stefanBoltzmann * (ts * ts + tInf * tInf) * (ts + tInf);
}

/// Two resistances in parallel: (1/R₁ + 1/R₂)⁻¹. Infinite when neither
/// conducts.
double parallelResistance(double r1, double r2) {
  final conductance = 1 / r1 + 1 / r2;
  return conductance == 0 ? double.infinity : 1 / conductance;
}

/// Outlet temperature of a fluid flowing through a tube whose total
/// resistance to the surroundings is [totalResistance]: the temperature
/// difference to ambient decays exponentially,
/// T_out = T∞ + (T_in − T∞)·exp(−1 / (ΣR·ṁ·c_p)).
double outletTemperature({
  required double inletTemp,
  required double ambientTemp,
  required double totalResistance,
  required double capacityRate,
}) =>
    ambientTemp +
    (inletTemp - ambientTemp) * math.exp(-1 / (totalResistance * capacityRate));

/// Logarithmic mean of the fluid temperature between [tIn] and [tOut],
/// measured from the ambient temperature [tInf].
double logMeanTemperature(double tIn, double tOut, double tInf) {
  final dIn = tIn - tInf;
  final dOut = tOut - tInf;
  if (dIn.abs() < 1e-12 || dOut.abs() < 1e-12) return tInf;
  if ((dIn - dOut).abs() < 1e-9 * dIn.abs()) return tInf + (dIn + dOut) / 2;
  return tInf + (dIn - dOut) / math.log(dIn / dOut);
}
