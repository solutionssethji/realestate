import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/l10n_extension.dart';
import 'support.logic.dart';

class SupportPage extends HookConsumerWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.read(supportLogicProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.supportCenter),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.support_agent, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              l10n.howCanWeHelp,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.supportDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Contact Options
            _buildContactCard(
              icon: Icons.chat,
              title: l10n.whatsappSupport,
              subtitle: l10n.whatsappSubtitle,
              color: Colors.green,
              onTap: () => logic.launchSupportUrl('https://wa.me/919876543210'),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              icon: Icons.phone,
              title: l10n.callUs,
              subtitle: l10n.callUsSubtitle,
              color: Colors.blue,
              onTap: () => logic.launchSupportUrl('tel:+919876543210'),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              icon: Icons.email,
              title: l10n.emailSupport,
              subtitle: l10n.emailSupportSubtitle,
              color: Colors.orange,
              onTap: () => logic.launchSupportUrl(
                'mailto:support@realestate.com?subject=App%20Support',
              ),
            ),

            const SizedBox(height: 48),
            Text(
              l10n.faqTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Mini FAQ section
            _buildFaqItem(l10n.faq1Question, l10n.faq1Answer),
            _buildFaqItem(l10n.faq2Question, l10n.faq2Answer),
            _buildFaqItem(l10n.faq3Question, l10n.faq3Answer),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
