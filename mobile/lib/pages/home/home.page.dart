import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget;
import 'home.logic.dart';
import '../../widgets/property_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/section_header.dart';
import '../../widgets/premium_button.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/offer_card.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(homeLogicProvider);
    final logic = ref.read(homeLogicProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Image.asset(
          'assets/logo_with_text.png',
          height: 60,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.midnightNavy),
            onPressed: () {
              context.push('/home/settings');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: logic.loadData,
        child: CustomScrollView(
          slivers: [
            // ── Featured Projects ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: SectionHeader(
                  title: loc.featuredProjects,
                  actionLabel: context.l10n.viewAll,
                  onAction: () => context.push('/home/projects'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: state.isLoading
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: AppSpacing.horizontalLg,
                      child: Row(
                        children: [
                          for (var i = 0; i < 3; i++) ...[
                            const SizedBox(
                              width: 280,
                              child: ProjectCardSkeleton(),
                            ),
                            if (i != 2) AppSpacing.wLg,
                          ],
                        ],
                      ),
                    )
                  : state.isError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            color: AppTheme.textSecondary,
                            size: 40,
                          ),
                          AppSpacing.hSm,
                          Text(context.l10n.unableToLoadProjects),
                          TextButton(
                            onPressed: logic.loadData,
                            child: Text(context.l10n.commonRetry),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: AppSpacing.horizontalLg,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (
                            var i = 0;
                            i <
                                (state.projects.length > 10
                                    ? 10
                                    : state.projects.length);
                            i++
                          ) ...[
                            SizedBox(
                              width: 280,
                              child: PropertyCard(
                                project: state.projects[i],
                                onTap: () => context.push(
                                  '/home/project/${state.projects[i].id}',
                                ),
                              ),
                            ),
                            if (i !=
                                (state.projects.length > 10
                                    ? 9
                                    : state.projects.length - 1))
                              AppSpacing.wLg,
                          ],
                        ],
                      ),
                    ),
            ),

            // ── Latest Offers ──────────────────────────────────────────────
            if (state.isLoading || state.offers.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.section,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: SectionHeader(
                    title: loc.offers,
                    actionLabel: state.offers.length > 6
                        ? context.l10n.viewAll
                        : null,
                    onAction: state.offers.length > 6
                        ? () => context.push('/home/offers')
                        : null,
                  ),
                ),
              ),
            if (state.isLoading || state.offers.isNotEmpty)
              SliverToBoxAdapter(
                child: state.isLoading
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          children: [
                            for (var i = 0; i < 3; i++) ...[
                              const SizedBox(
                                width: 280,
                                child: ProjectCardSkeleton(),
                              ),
                              if (i != 2) AppSpacing.wLg,
                            ],
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (
                              var i = 0;
                              i <
                                  (state.offers.length > 6
                                      ? 6
                                      : state.offers.length);
                              i++
                            ) ...[
                              SizedBox(
                                width: 280,
                                child: OfferCard(
                                  offer: state.offers[i],
                                  onTap: () {
                                    final offer = state.offers[i];
                                    context.push('/home/offers/${offer.id}');
                                  },
                                ),
                              ),
                              if (i !=
                                  (state.offers.length > 6
                                      ? 5
                                      : state.offers.length - 1))
                                AppSpacing.wLg,
                            ],
                          ],
                        ),
                      ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: PremiumButton(
                  text: context.l10n.enquireNow,
                  icon: Icons.support_agent_rounded,
                  onPressed: () => context.push('/home/enquiry'),
                  isFullWidth: true,
                ),
              ),
              AppSpacing.wSm,
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.midnightNavy,
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () async {
                  final phone = state.contactPhone;
                  if (phone == null || phone.isEmpty) return;
                  final uri = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
                icon: const Icon(Icons.phone),
              ),
              AppSpacing.wSm,
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () async {
                  final whatsapp = state.contactWhatsapp;
                  if (whatsapp == null || whatsapp.isEmpty) return;
                  final Uri uri = Uri.parse('https://wa.me/$whatsapp');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
                icon: const Icon(Icons.chat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
