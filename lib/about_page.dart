import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/app_info.dart';

/// Local About screen: version, licence, source code and the bundled licence
/// registry. Nothing here makes a network request; the licence list comes
/// from Flutter's in-app registry.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Center(
            child: Image.asset(
              'assets/images/icon/icon.png',
              width: 88,
              height: 88,
              cacheWidth: 176,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppInfo.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              l10n.versionBuild(AppInfo.version, AppInfo.buildNumber),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              l10n.aboutTagline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.openSourceLine,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            children: [
              _InfoTile(
                icon: Icons.code,
                label: l10n.repository,
                value: AppInfo.repositoryUrl,
                trailing: IconButton(
                  tooltip: l10n.copyLink,
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    final messenger = ScaffoldMessenger.maybeOf(context);
                    // Clipboard access can be unavailable; the link is still
                    // on screen to copy by hand.
                    unawaited(
                      Clipboard.setData(
                        const ClipboardData(text: AppInfo.repositoryUrl),
                      ).catchError((Object _) {}),
                    );
                    messenger?.showSnackBar(
                      SnackBar(content: Text(l10n.linkCopied)),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.gavel,
                label: l10n.licence,
                value: AppInfo.licenseName,
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.lock_outline,
                label: l10n.privacy,
                value: l10n.privacyStatement,
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.favorite_outline,
                label: l10n.madeBy(AppInfo.teamName),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.openSourceLicences),
            trailing: const Icon(Icons.chevron_right),
            contentPadding: EdgeInsets.zero,
            onTap: () => showLicensePage(
              context: context,
              applicationName: AppInfo.name,
              applicationVersion: '${AppInfo.version} (${AppInfo.buildNumber})',
              applicationLegalese:
                  'PolyForm Noncommercial 1.0.0, ${AppInfo.teamName}',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (value != null) ...[
                  const SizedBox(height: 2),
                  SelectableText(value!, style: const TextStyle(height: 1.3)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
