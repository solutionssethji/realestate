import 'package:customer_app/widgets/app_cached_image.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import 'project_details.logic.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/premium_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/shimmer_loader.dart';
import '../../routes/app_routes.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';

class ProjectDetailsPage extends HookConsumerWidget {
  final String projectId;

  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectDetailsLogicProvider(projectId));

    final project = state.project;

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.projects),
      body: SafeArea(
        top: false,
        child: state.isLoading
            ? const DetailPageSkeleton()
            : state.isError
            ? ErrorState(
                message: state.errorMessage,
                onRetry: () => ref
                    .read(projectDetailsLogicProvider(projectId).notifier)
                    .loadProject(projectId),
              )
            : project == null
            ? EmptyState(
                title: context.l10n.unableToLoadProject,
                message: context.l10n.unableToLoadProject,
                icon: Icons.apartment_rounded,
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(projectDetailsLogicProvider(projectId).notifier)
                      .loadProject(projectId);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () =>
                            _showImageViewer(context, project.coverImage),
                        child: AppCachedImage(
                          imageUrl: project.coverImage,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
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
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'FEATURED',
                                              style: TextStyle(
                                                color: AppTheme.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                          AppSpacing.wSm,
                                        ],
                                        if (project
                                            .developmentStatus
                                            .isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.softGold,
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                            context.l10n.totalPlots(
                                              project.plotCount,
                                            ),
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
      ),
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
                    child: GestureDetector(
                      onTap: () =>
                          _showImageViewer(context, project.gallery[i]),
                      child: AppCachedImage(
                        imageUrl: project.gallery[i],
                        width: 260,
                        fit: BoxFit.cover,
                      ),
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
            color: AppTheme.surface,
            borderRadius: AppRadius.circularLg,
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withValues(alpha: 0.05),
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
                onPressed: project.availablePlotsCount > 0
                    ? () => context.push(AppRoutes.plotAvailability(projectId))
                    : null,
              ),
              AppSpacing.hMd,
              PremiumButton(
                text: context.l10n.bookSiteVisit,
                style: PremiumButtonStyle.outline,
                icon: Icons.directions_car_outlined,
                onPressed: () =>
                    context.push(AppRoutes.siteVisitWithProject(projectId)),
              ),
              AppSpacing.hMd,
              if (project.googleMap.isNotEmpty) ...[
                PremiumButton(
                  text: context.l10n.viewOnGoogleMaps,
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
                    context.push(AppRoutes.enquiryWithProject(projectId)),
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
                  ).textTheme.titleLarge?.copyWith(color: AppTheme.white),
                ),
                AppSpacing.hXs,
                Text(
                  context.l10n.walkThroughProperty,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.white70),
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

void _showImageViewer(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black87),
          ),
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: AppCachedImage(imageUrl: imageUrl, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}
