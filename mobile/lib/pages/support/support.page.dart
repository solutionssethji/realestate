import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/error_state.dart';
import '../../widgets/app_loading_view.dart';
import 'support.logic.dart';

class SupportPage extends HookConsumerWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(supportLogicProvider);
    final logic = ref.read(supportLogicProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.supportCenter),
      body: FutureBuilder<Map<String, String>>(
        future: ApiService.getContactSettings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: () => ref.invalidate(supportLogicProvider),
            );
          }
          if (!snapshot.hasData) {
            return const AppLoadingView();
          }

          final settings = snapshot.data!;
          final whatsapp = settings['whatsapp'] ?? '';
          final phone = settings['phone'] ?? '';
          final email = settings['email'] ?? '';

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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

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

                const SizedBox(height: 48),
                Text(
                  l10n.faqTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Mini FAQ section
                _buildFaqItem(context, l10n.faq1Question, l10n.faq1Answer),
                _buildFaqItem(context, l10n.faq2Question, l10n.faq2Answer),
                _buildFaqItem(context, l10n.faq3Question, l10n.faq3Answer),
              ],
            ),
          );
        },
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

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: Theme.of(context).textTheme.titleSmall),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}
