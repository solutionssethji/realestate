import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AboutCompanyPage extends StatelessWidget {
  const AboutCompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.aboutCompany),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            context,
            title: context.l10n.companyProfile,
            icon: LucideIcons.building,
            content: 'We are a leading real estate platform dedicated to helping you find your dream property. With years of experience in the industry, we bring transparency and trust to every transaction.',
          ),
          AppSpacing.hXl,
          _buildSection(
            context,
            title: context.l10n.vision,
            icon: LucideIcons.eye,
            content: 'To revolutionize the real estate industry by creating a seamless, transparent, and technology-driven experience for all buyers and sellers.',
          ),
          AppSpacing.hXl,
          _buildSection(
            context,
            title: context.l10n.mission,
            icon: LucideIcons.target,
            content: 'Our mission is to empower individuals with the right tools, knowledge, and support to make informed property investment decisions.',
          ),
          AppSpacing.hXl,
          _buildSection(
            context,
            title: context.l10n.whyChooseUs,
            icon: LucideIcons.award,
            content: '• Verified Properties\n• Transparent Pricing\n• End-to-End Support\n• Dedicated RM for every customer\n• Easy EMI options',
          ),
          AppSpacing.hXl,
          _buildSection(
            context,
            title: context.l10n.contactInformation,
            icon: LucideIcons.mail,
            content: 'Email: support@realestate.com\nPhone: +91 9876543210\nAddress: 123, Real Estate Tower, Business District.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required String content}) {
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
