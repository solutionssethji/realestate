import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../widgets/premium_app_bar.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/generic_shimmer_loader.dart';
import 'about.logic.dart';

class AboutCompanyPage extends HookConsumerWidget {
  const AboutCompanyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aboutLogicProvider);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.aboutCompany),
      body: SafeArea(child: _buildBody(context, state)),
    );
  }

  Widget _buildBody(BuildContext context, state) {
    if (state.isLoading) {
      return const ShimmerLoader();
    }

    if (state.isError) {
      return Center(
        child: Text(
          state.errorMessage ?? 'Error loading about info',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final info = state.companyInfo;
    if (info == null) {
      return Center(child: Text(context.l10n.aboutUnavailable));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSection(
          context,
          title: context.l10n.companyProfile,
          icon: LucideIcons.building,
          content: info.about.isNotEmpty
              ? info.about
              : 'We are a leading real estate platform...',
        ),
        AppSpacing.hXl,
        _buildSection(
          context,
          title: context.l10n.vision,
          icon: LucideIcons.eye,
          content: info.vision.isNotEmpty
              ? info.vision
              : 'To revolutionize the real estate industry...',
        ),
        AppSpacing.hXl,
        _buildSection(
          context,
          title: context.l10n.mission,
          icon: LucideIcons.target,
          content: info.mission.isNotEmpty
              ? info.mission
              : 'Our mission is to empower individuals...',
        ),
        if (info.whyChooseUs.isNotEmpty) ...[
          AppSpacing.hXl,
          _buildSection(
            context,
            title: context.l10n.whyChooseUs,
            icon: LucideIcons.award,
            content: info.whyChooseUs.map((e) => '• $e').join('\n'),
          ),
        ],
        AppSpacing.hXl,
        _buildSection(
          context,
          title: context.l10n.contactInformation,
          icon: LucideIcons.mail,
          content:
              'Email: ${info.email}\nPhone: ${info.phone}\nAddress: ${info.officeAddress}',
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.midnightNavy, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.midnightNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
