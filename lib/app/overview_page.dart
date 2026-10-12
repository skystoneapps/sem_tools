import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'repository_link.dart';
import 'sem_module.dart';

/// Home page of SEM tools: a card per module.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.modules, required this.onOpen});

  final List<SemModule> modules;
  final ValueChanged<SemModule> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        // The app name is already in the top bar.
        Text(
          l10n.overviewSubtitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final module in modules)
              SizedBox(
                width: 340,
                child: Card.outlined(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onOpen(module),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor:
                                theme.colorScheme.onPrimaryContainer,
                            child: Icon(module.icon),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            module.pageTitle(l10n),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.description(l10n),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 40),
        Text(l10n.about, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.aboutText, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                l10n.disclaimer,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: openRepository,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(
              '${l10n.sourceCode}  ·  '
              '${repositoryUrl.host}${repositoryUrl.path}',
            ),
          ),
        ),
      ],
    );
  }
}
