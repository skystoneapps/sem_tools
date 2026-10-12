# SEM tools

Calculation tools for the **Sustainable Energy Management** advanced bachelor
(banaba) programme of [Howest](https://www.howest.be). Each tool shows not only
its results but also the worked calculation, step by step, with the formulas
used.

Available in English and Dutch.

## Tools

- **Heat transport** — heat loss and outlet temperature of an insulated tube,
  through convection (Newton's law of cooling), conduction (Fourier's law) and
  radiation (Stefan–Boltzmann law). The fluid temperature along the tube can be
  calculated exactly or simplified as constant.
- **Price calculation** — the cost of a heat loss over a usage duration at a
  given energy market price. The heat loss can be taken over from the heat
  transport tool.

## Disclaimer

These tools are provided for educational purposes, as is. I take no
responsibility for potential errors in the calculations or their results.
Always verify results before relying on them.

## Running

SEM tools is a [Flutter](https://flutter.dev) app. With Flutter installed:

```sh
flutter pub get
flutter run        # pick a device, e.g. -d macos or -d chrome
flutter test
```

## License

SEM tools is released under the [MIT License](LICENSE).
