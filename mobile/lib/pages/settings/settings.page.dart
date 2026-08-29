import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../config/locale_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../utils/l10n_extension.dart';
import 'settings.logic.dart';
import '../../theme/theme.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final settingsState = const SettingsLogic().fromLocale(locale.languageCode);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: PremiumAppBar(title: loc.settings),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(loc.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildLanguageTile(
              context,
              ref,
              context.l10n.langEnglish,
              'en',
              settingsState.languageCode == 'en',
            ),
            const SizedBox(height: 12),
            _buildLanguageTile(
              context,
              ref,
              context.l10n.langHindi,
              'hi',
              settingsState.languageCode == 'hi',
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.aboutCompany,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              context,
              LucideIcons.building,
              context.l10n.aboutCompany,
              () => context.push('/home/about'),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              LucideIcons.phoneCall,
              context.l10n.contactUs,
              () => context.push('/home/contact'),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              LucideIcons.calculator,
              context.l10n.emiCalculator,
              () => context.push('/home/emi-calculator'),
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.legalAndPolicies,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              context,
              LucideIcons.fileText,
              context.l10n.termsAndConditions,
              () => context.push('/home/terms'),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              LucideIcons.shield,
              context.l10n.privacyPolicy,
              () => context.push('/home/privacy'),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              LucideIcons.helpCircle,
              context.l10n.faq,
              () => context.push('/home/faq'),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      trailing: const Icon(Icons.chevron_right, size: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : AppTheme.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : AppTheme.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
