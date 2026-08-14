import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../config/locale_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../utils/l10n_extension.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: PremiumAppBar(title: loc.settings),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            loc.language,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildLanguageTile(
            context,
            ref,
            context.l10n.langEnglish,
            'en',
            locale.languageCode == 'en',
          ),
          const SizedBox(height: 12),
          _buildLanguageTile(
            context,
            ref,
            context.l10n.langHindi,
            'hi',
            locale.languageCode == 'hi',
          ),
          const SizedBox(height: 32),
          Text(
            context.l10n.account,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.history,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              context.l10n.paymentHistory,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(context.l10n.viewPastTransactions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/payment-history-auth');
            },
          ),
          const SizedBox(height: 32),
          Text(
            context.l10n.legalAndSupport,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            context,
            LucideIcons.fileText,
            context.l10n.termsAndConditions,
            () => context.push('/terms'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            LucideIcons.shield,
            context.l10n.privacyPolicy,
            () => context.push('/privacy'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            LucideIcons.helpCircle,
            'FAQ',
            () => context.push('/faq'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    String code,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(localeControllerProvider.notifier).setLocale(code);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
