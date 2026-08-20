import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/premium_app_bar.dart';
import '../../widgets/premium_button.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/cms_service.dart';
import '../../models/company_info.dart';
import '../../widgets/generic_shimmer_loader.dart';
import '../../config/locale_provider.dart';

class ContactUsPage extends ConsumerWidget {
  const ContactUsPage({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.contactUs),
      body: FutureBuilder<CompanyInfo?>(
        future: CmsService.getContactInfo(currentLocale.languageCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoader();
          }

          final info = snapshot.data;

          if (info == null) {
            return Center(child: Text(context.l10n.aboutUnavailable)); // Or contactUnavailable
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.midnightNavy, AppTheme.slateBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.headphones, color: Colors.white, size: 48),
                    AppSpacing.hMd,
                    Text(
                      'We are here to help!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.hSm,
                    Text(
                      'Reach out to us for any queries related to your property search or investments.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hXl,

              Text(
                context.l10n.contactInformation,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              AppSpacing.hLg,

              PremiumButton(
                text: context.l10n.directCall,
                icon: LucideIcons.phone,
                onPressed: () => _launchUrl('tel:${info.phone}'),
              ),
              AppSpacing.hMd,
              PremiumButton(
                text: context.l10n.whatsapp,
                icon: LucideIcons.messageCircle,
                style: PremiumButtonStyle.secondary,
                onPressed: () => _launchUrl('https://wa.me/${info.whatsapp}'),
              ),
              AppSpacing.hMd,
              PremiumButton(
                text: context.l10n.googleMaps,
                icon: LucideIcons.mapPin,
                style: PremiumButtonStyle.outline,
                onPressed: () => _launchUrl(info.googleMapsUrl),
              ),

              AppSpacing.hXl,

              _buildInfoCard(
                context,
                icon: LucideIcons.phoneCall,
                title: context.l10n.contactNumber,
                content: info.contactNumberDisplay.isNotEmpty ? info.contactNumberDisplay : info.phone,
              ),
              AppSpacing.hLg,
              _buildInfoCard(
                context,
                icon: LucideIcons.map,
                title: context.l10n.officeLocation,
                content: info.officeAddress,
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.midnightNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.midnightNavy, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.midnightNavy,
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
