import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';

// Contact info constants — easy to swap with real data from Firestore/Config
const _phone = '+91 98765 43210';
const _whatsapp = '919876543210'; // digits only for wa.me URL
const _email = 'info@yourcompany.com';
const _address = '123 Real Estate Blvd,\nBusiness District,\nCity — 400001';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bool isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      appBar: PremiumAppBar(title: loc.contactUs),
      body: SingleChildScrollView(
        padding: AppSpacing.allLg,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _LeftContact(context: context)),
                      AppSpacing.wXXl,
                      Expanded(child: _RightOffice(context: context)),
                    ],
                  )
                : Column(
                    children: [
                      _LeftContact(context: context),
                      AppSpacing.hXXl,
                      _RightOffice(context: context),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _LeftContact extends StatelessWidget {
  const _LeftContact({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final loc = AppLocalizations.of(ctx);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.getInTouch,
          style: ctx.textTheme.displaySmall?.copyWith(
            color: AppTheme.midnightNavy,
          ),
        ),
        AppSpacing.hSm,
        Text(
          context.l10n.ourTeamIsAvailable,
          style: ctx.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        AppSpacing.hXXl,
        _ContactTile(
          icon: Icons.phone_outlined,
          title: loc.callUs,
          value: _phone,
          onTap: () => _launch('tel:$_phone'),
        ),
        AppSpacing.hLg,
        _ContactTile(
          icon: Icons.chat_bubble_outline_rounded,
          title: loc.whatsapp,
          value: _phone,
          onTap: () => _launch('https://wa.me/$_whatsapp'),
        ),
        AppSpacing.hLg,
        _ContactTile(
          icon: Icons.mail_outline_rounded,
          title: loc.email,
          value: _email,
          onTap: () => _launch('mailto:$_email'),
        ),
      ],
    );
  }
}

class _RightOffice extends StatelessWidget {
  const _RightOffice({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppRadius.circularLg,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.corporateOffice,
            style: ctx.textTheme.headlineSmall,
          ),
          AppSpacing.hMd,
          Text(
            _address,
            style: ctx.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          AppSpacing.hLg,
          ClipRRect(
            borderRadius: AppRadius.circularMd,
            child: Image.network(
              'https://images.unsplash.com/photo-1497366216548-37526070297c'
              '?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: AppTheme.border,
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 40,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.circularMd,
      child: Container(
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: AppRadius.circularMd,
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.allSm,
              decoration: BoxDecoration(
                color: AppTheme.midnightNavy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.midnightNavy, size: 22),
            ),
            AppSpacing.wLg,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // Silently fail — real error handling would show a snackbar
  }
}
