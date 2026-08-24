import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'project_details.logic.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/premium_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsPage extends ConsumerWidget {
  final String projectId;

  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(projectDetailsLogicProvider(projectId));

    final project = state.project;

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.projects),
      body: SafeArea(
        top: false,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : (state.isError || state.project == null || project == null)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.unableToLoadProject,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.hLg,
                    OutlinedButton.icon(
                      onPressed: () => ref
                          .read(projectDetailsLogicProvider(projectId).notifier)
                          .loadProject(projectId),
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.tryAgain),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Image.network(
                      project.coverImage,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // ── Body Content ────────────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        padding: AppSpacing.allLg,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xl,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (project.isFeatured) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.midnightNavy,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            'FEATURED',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                        AppSpacing.wSm,
                                      ],
                                      if (project.developmentStatus.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.softGold,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            project.developmentStatus,
                                            style: const TextStyle(
                                              color: AppTheme.midnightNavy,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (project.isFeatured ||
                                      project.developmentStatus.isNotEmpty)
                                    AppSpacing.hSm,
                                  Text(
                                    project.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  AppSpacing.hXs,
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AppTheme.textSecondary,
                                        size: 16,
                                      ),
                                      AppSpacing.wXs,
                                      Expanded(
                                        child: Text(
                                          project.location,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (project.plotCount > 0) ...[
                                    AppSpacing.hSm,
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.grid_view_rounded,
                                          color: AppTheme.midnightNavy,
                                          size: 16,
                                        ),
                                        AppSpacing.wXs,
                                        Text(
                                          '${project.plotCount} Total Plots',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppTheme.midnightNavy,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            _LeftContent(project: project),
                            AppSpacing.hXXl,
                            _RightActions(
                              projectId: projectId,
                              project: project,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      // // Mobile sticky bottom bar
      // bottomNavigationBar: isDesktop
      //     ? null
      //     : SafeArea(
      //         child: Container(
      //           padding: AppSpacing.allLg,
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             boxShadow: [
      //               BoxShadow(
      //                 color: Colors.black.withValues(alpha: 0.06),
      //                 blurRadius: 12,
      //                 offset: const Offset(0, -4),
      //               ),
      //             ],
      //           ),
      //           child: Row(
      //             children: [
      //               Expanded(
      //                 child: PremiumButton(
      //                   text: context.l10n.viewPlots,
      //                   icon: Icons.grid_view_rounded,
      //                   onPressed: () =>
      //                       context.push('/home/project/$projectId/plots'),
      //                 ),
      //               ),
      //               AppSpacing.wMd,
      //               Expanded(
      //                 child: PremiumButton(
      //                   text: context.l10n.siteVisit,
      //                   style: PremiumButtonStyle.secondary,
      //                   icon: Icons.directions_car_outlined,
      //                   onPressed: () => context.push(
      //                     '/home/site-visit?projectId=$projectId',
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
    );
  }
}

// ─── Left Column ─────────────────────────────────────────────────────────────

class _LeftContent extends StatelessWidget {
  final dynamic project;

  const _LeftContent({required this.project});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (project.description.isNotEmpty) ...[
          _Section(
            title: loc.aboutTheProject,
            child: Text(
              project.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ),
          AppSpacing.hXXl,
        ],

        if (project.gallery.isNotEmpty) ...[
          AppSpacing.hXXl,
          _Section(
            title: loc.gallery,
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: project.gallery.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: ClipRRect(
                    borderRadius: AppRadius.circularMd,
                    child: CachedNetworkImage(
                      imageUrl: project.gallery[i],
                      width: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        if (project.amenities.isNotEmpty) ...[
          AppSpacing.hXXl,
          _Section(
            title: loc.amenities,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: (project.amenities as List<String>)
                  .map(
                    (a) => Chip(
                      label: Text(
                        a,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      avatar: const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.softGold,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Right Column ─────────────────────────────────────────────────────────────

class _RightActions extends StatelessWidget {
  final String projectId;
  final dynamic project;

  const _RightActions({required this.projectId, required this.project});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        // Pricing & CTA
        Container(
          padding: AppSpacing.allLg,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.circularLg,
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.priceRange.isNotEmpty) ...[
                Text(
                  context.l10n.startingFrom,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  project.priceRange,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.midnightNavy,
                  ),
                ),
                AppSpacing.hLg,
              ],
              PremiumButton(
                text: context.l10n.viewPlotAvailability,
                icon: Icons.grid_view_rounded,
                onPressed: () => context.push('/home/project/$projectId/plots'),
              ),
              AppSpacing.hMd,
              PremiumButton(
                text: context.l10n.bookSiteVisit,
                style: PremiumButtonStyle.outline,
                icon: Icons.directions_car_outlined,
                onPressed: () =>
                    context.push('/home/site-visit?projectId=$projectId'),
              ),
              AppSpacing.hMd,
              if (project.googleMap.isNotEmpty) ...[
                PremiumButton(
                  text: 'View on Google Maps',
                  style: PremiumButtonStyle.outline,
                  icon: Icons.map_outlined,
                  onPressed: () async {
                    final uri = Uri.parse(project.googleMap);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                AppSpacing.hMd,
              ],
              PremiumButton(
                text: loc.enquireNow,
                style: PremiumButtonStyle.ghost,
                onPressed: () =>
                    context.push('/home/enquiry?projectId=$projectId'),
              ),
            ],
          ),
        ),
        AppSpacing.hLg,

        // 360° Card / Video
        if (project.projectVideo.isNotEmpty)
          Container(
            width: double.infinity,
            padding: AppSpacing.allLg,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.midnightNavy, AppTheme.slateBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.circularLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.threesixty,
                  color: AppTheme.softGold,
                  size: 36,
                ),
                AppSpacing.hSm,
                Text(
                  context.l10n.virtual360Tour,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                AppSpacing.hXs,
                Text(
                  context.l10n.walkThroughProperty,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                AppSpacing.hLg,
                PremiumButton(
                  text: context.l10n.launch360Tour,
                  style: PremiumButtonStyle.secondary,
                  icon: Icons.play_circle_outline,
                  isFullWidth: false,
                  onPressed: () async {
                    final uri = Uri.parse(project.projectVideo);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppTheme.midnightNavy),
        ),
        AppSpacing.hMd,
        child,
      ],
    );
  }
}
