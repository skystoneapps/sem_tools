import 'package:flutter_test/flutter_test.dart';

import 'package:sem/heat_transfer/domain/physics.dart';

/// Each law against a value worked out by hand.
void main() {
  test('cylinder area is 2πrL', () {
    expect(cylinderArea(0.025, 10), closeTo(1.5707963, 1e-7));
  });

  test('surface resistance is 1 / (h·A)', () {
    expect(surfaceResistance(10, 2), 0.05);
  });

  test('cylindrical conduction follows ln(r₂/r₁) / (2πkL)', () {
    // 4 mm carbon steel wall around a 50 mm bore, 10 m long.
    expect(
      cylinderConductionResistance(0.025, 0.029, 45, 10),
      closeTo(5.249284e-5, 1e-11),
    );
    // A longer tube conducts proportionally more.
    expect(
      cylinderConductionResistance(0.025, 0.029, 45, 20),
      closeTo(5.249284e-5 / 2, 1e-11),
    );
  });

  test("Newton's law of cooling", () {
    expect(convectionHeatFlow(10, 2, 30, 20), closeTo(200, 1e-12));
  });

  test('Stefan–Boltzmann: a black body at 100 °C facing 0 °C', () {
    expect(radiationHeatFlow(1, 1, 100, 0), closeTo(783.716, 1e-3));
    expect(radiationHeatFlow(0, 1, 100, 0), 0);
  });

  test('the linearised radiation coefficient reproduces the radiated heat', () {
    const emissivity = 0.9, area = 3.7, ts = 27.6, tInf = 20.0;
    expect(
      radiationCoefficient(emissivity, ts, tInf) * area * (ts - tInf),
      closeTo(radiationHeatFlow(emissivity, area, ts, tInf), 1e-9),
    );
  });

  test('parallel resistances', () {
    expect(parallelResistance(2, 2), 1);
    expect(parallelResistance(double.infinity, 4), 4);
    expect(
      parallelResistance(double.infinity, double.infinity),
      double.infinity,
    );
  });

  test('the outlet temperature decays exponentially towards ambient', () {
    // ΣR·ṁ·c_p = 1, so the difference to ambient shrinks by a factor e.
    expect(
      outletTemperature(
        inletTemp: 150,
        ambientTemp: 20,
        totalResistance: 0.5,
        capacityRate: 2,
      ),
      closeTo(67.824327, 1e-6),
    );
    // Without a path to the surroundings, nothing changes.
    expect(
      outletTemperature(
        inletTemp: 150,
        ambientTemp: 20,
        totalResistance: double.infinity,
        capacityRate: 2,
      ),
      150,
    );
  });

  test('logarithmic mean temperature', () {
    expect(logMeanTemperature(150, 50, 20), closeTo(88.197144, 1e-6));
    // Equal differences: the mean is that temperature.
    expect(logMeanTemperature(80, 80, 20), closeTo(80, 1e-9));
    expect(logMeanTemperature(20, 20, 20), 20);
  });
}
