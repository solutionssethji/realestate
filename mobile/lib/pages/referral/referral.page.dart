import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/premium_app_bar.dart';
import '../../utils/l10n_extension.dart';
import '../../utils/snackbar_utils.dart';
import '../../theme/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'referral.logic.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';

class ReferralPage extends HookConsumerWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final customerAsync = ref.watch(customerProvider);
    final referralCodeAsync = ref.watch(referralCodeProvider);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.referralRewards),
      body: SafeArea(
        child: user == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(context.l10n.loginToReferral),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.midnightNavy, AppTheme.slateBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.midnightNavy.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.yourReferralCode,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: AppTheme.white),
                              ),
                              const Icon(
                                LucideIcons.gift,
                                color: AppTheme.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          referralCodeAsync.when(
                            data: (code) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SelectableText(
                                    code,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          letterSpacing: 2.0,
                                          color: AppTheme.white,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: code),
                                          );
                                          if (context.mounted) {
                                            AppSnackbar.showSuccess(
                                              context,
                                              context.l10n.referralCodeCopied,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.white,
                                          foregroundColor:
                                              AppTheme.midnightNavy,
                                          elevation: 0,
                                        ),
                                        icon: const Icon(LucideIcons.copy),
                                        label: Text(context.l10n.copyCode),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final shareText =
                                              '🏠 Join me on Shubhaytanam Connect!\n\n'
                                              'Use my referral code: $code\n\n'
                                              'Find your perfect home and get started today! 🎁';

                                          await SharePlus.instance.share(
                                            ShareParams(text: shareText),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.white,
                                          foregroundColor:
                                              AppTheme.midnightNavy,
                                          elevation: 0,
                                        ),
                                        icon: const Icon(LucideIcons.share),
                                        label: Text(context.l10n.shareCode),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: AppTheme.white,
                                ),
                              ),
                            ),
                            error: (error, stack) => Center(
                              child: Text(
                                context.l10n.errorLoadingCode,
                                style: const TextStyle(color: AppTheme.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.l10n.rewardSummary,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.referredUsers),
                            child: _StatCard(
                              icon: LucideIcons.users,
                              label: context.l10n.invitesSent,
                              value: (customerAsync.value?.invitesSent ?? 0)
                                  .toString()
                                  .padLeft(2, '0'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: LucideIcons.checkCircle2,
                            label: context.l10n.statusLabel,
                            value:
                                customerAsync.value?.referralStatus ??
                                context.l10n.active,
                            valueColor:
                                (customerAsync.value?.referralStatus
                                        ?.toLowerCase() ==
                                    'inactive')
                                ? AppTheme.error
                                : AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    ref
                        .watch(referralSettingsProvider)
                        .when(
                          data: (steps) {
                            if (steps.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.howItWorks,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 24),
                                Column(
                                  children: steps.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final step = entry.value;
                                    // Assign a default icon based on index if not available
                                    IconData getIcon(int i) {
                                      if (i == 0) return LucideIcons.share2;
                                      if (i == 1) return LucideIcons.userPlus;
                                      if (i == 2) return LucideIcons.gift;
                                      return LucideIcons.checkCircle;
                                    }

                                    String getBilingualText(
                                      dynamic data,
                                      String lang,
                                    ) {
                                      if (data is String) return data;
                                      if (data is Map) {
                                        return (data[lang] ?? data['en'] ?? '')
                                            .toString();
                                      }
                                      return '';
                                    }

                                    final currentLang = Localizations.localeOf(
                                      context,
                                    ).languageCode;

                                    return _InfoRow(
                                      icon: getIcon(index),
                                      step: index + 1,
                                      title: getBilingualText(
                                        step['title'],
                                        currentLang,
                                      ),
                                      subtitle: getBilingualText(
                                        step['subtitle'],
                                        currentLang,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral500),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.midnightNavy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: valueColor ?? AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final int step;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.step,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.midnightNavy.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.midnightNavy, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $step',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.midnightNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
