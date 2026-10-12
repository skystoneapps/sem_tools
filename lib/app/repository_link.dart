import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

/// Public repository of SEM tools.
final repositoryUrl = Uri.parse('https://github.com/skystoneapps/sem_tools');

/// Opens the repository in the browser.
Future<void> openRepository() =>
    launchUrl(repositoryUrl, mode: LaunchMode.externalApplication);

/// Compact button to the repository, for the navigation rail.
class RepositoryIconButton extends StatelessWidget {
  const RepositoryIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context).sourceCode,
      onPressed: openRepository,
      icon: const Icon(Icons.code),
    );
  }
}
