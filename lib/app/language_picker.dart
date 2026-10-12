import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Language names in their own language, so each is recognisable whatever
/// the current language is.
const _languageNames = {'en': 'English', 'nl': 'Nederlands'};

/// Top-bar button showing the current language; opens a menu to switch.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key, required this.onSelected});

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
