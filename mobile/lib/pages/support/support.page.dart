import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import '../../widgets/generic_shimmer_loader.dart';
import 'support.logic.dart';

class SupportPage extends HookConsumerWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supportLogicProvider);
    final logic = ref.read(supportLogicProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.supportCenter),
      body: SafeArea(child: _buildBody(context, logic, state, l10n)),
    );
  }

  Widget _buildBody(BuildContext context, SupportLogic logic, state, l10n) {
    if (state.isLoading) {
      return const ShimmerLoader();
    }
    if (state.isError) {
      return Center(
        child: Text(state.errorMessage ?? context.l10n.errorLoadingSupportInfo),
      );
    }

    final info = state.companyInfo;
    if (info == null) {
      return Center(child: Text(l10n.aboutUnavailable));
    }

    final whatsapp = info.whatsapp;
    final phone = info.phone;
    final email = info.email;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.support_agent, size: 80, color: AppTheme.info),
          const SizedBox(height: 16),
          Text(
            l10n.howCanWeHelp,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.supportDesc,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),

          // About Company
          _buildContactCard(
            context: context,
            icon: Icons.info_outline,
            title: l10n.aboutCompany,
            subtitle: l10n.companyProfile,
            color: AppTheme.midnightNavy,
            onTap: () => context.push(AppRoutes.about),
          ),
          const SizedBox(height: 16),

          // Contact Options
          _buildContactCard(
            context: context,
            icon: Icons.chat,
            title: l10n.whatsappSupport,
            subtitle: l10n.whatsappSubtitle,
            color: AppTheme.success,
            onTap: whatsapp.isEmpty
                ? null
                : () => logic.launchSupportUrl('https://wa.me/$whatsapp'),
          ),
          const SizedBox(height: 16),

          _buildContactCard(
            context: context,
            icon: Icons.phone,
            title: l10n.callUs,
            subtitle: l10n.callUsSubtitle,
            color: AppTheme.info,
            onTap: phone.isEmpty
                ? null
                : () => logic.launchSupportUrl('tel:$phone'),
          ),
          const SizedBox(height: 16),

          _buildContactCard(
            context: context,
            icon: Icons.email,
            title: l10n.emailSupport,
            subtitle: l10n.emailSupportSubtitle,
            color: AppTheme.darkGold,
            onTap: email.isEmpty
                ? null
                : () => logic.launchSupportUrl(
                    'mailto:$email?subject=App%20Support',
                  ),
          ),
          const SizedBox(height: 16),

          _buildContactCard(
            context: context,
            icon: Icons.location_on,
            title: l10n.officeLocation,
            subtitle: info.officeAddress,
            color: AppTheme.midnightNavy,
            onTap: info.googleMapsUrl.isEmpty
                ? null
                : () => logic.launchSupportUrl(info.googleMapsUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
