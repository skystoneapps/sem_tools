/// Watt-hours in a megawatt-hour.
const wattHoursPerMegawattHour = 1e6;

/// Variables of the price calculation.
class PriceInputs {
  const PriceInputs({
    this.power = 1000,
    this.duration = 3000,
    this.marketPrice = 100,
  });

  /// Heat loss (power) in W.
  final double power;

  /// Usage duration in hours.
  final double duration;

  /// Energy market price in € per MWh.
  final double marketPrice;

  PriceInputs copyWith({double? power, double? duration, double? marketPrice}) {
    return PriceInputs(
      power: power ?? this.power,
      duration: duration ?? this.duration,
      marketPrice: marketPrice ?? this.marketPrice,
    );
  }
}

class PriceResult {
  const PriceResult({required this.inputs, required this.energyWattHours});

  final PriceInputs inputs;

  /// Energy lost over the usage duration, E = P·t, in Wh.
  final double energyWattHours;

  /// Energy lost in MWh.
  double get energyMegawattHours => energyWattHours / wattHoursPerMegawattHour;

  /// Cost of the energy lost, C = E·p, in €.
  double get cost => energyMegawattHours * inputs.marketPrice;

  /// Cost per hour of use, P·p / 10⁶, in €/h.
  double get costPerHour =>
      inputs.power * inputs.marketPrice / wattHoursPerMegawattHour;
}

PriceResult calculatePrice(PriceInputs inputs) => PriceResult(
  inputs: inputs,
  energyWattHours: inputs.power * inputs.duration,
);
