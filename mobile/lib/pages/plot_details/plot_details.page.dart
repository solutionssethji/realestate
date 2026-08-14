import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'plot_details.logic.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../models/plot_status.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/status_badge.dart';

class PlotDetailsPage extends ConsumerWidget {
  final String projectId;
  final String plotId;

  const PlotDetailsPage({
    super.key,
    required this.projectId,
    required this.plotId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(plotDetailsLogicProvider(projectId, plotId));
    final bool isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.isError || state.plot == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.unableToLoadProject)),
      );
    }

    final plot = state.plot!;
    final bool isAvailable = plot.status == PlotStatus.available;

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.plotTitle(plot.plotNumber)),
      body: SingleChildScrollView(
        padding: AppSpacing.allLg,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card with dark background
                Container(
                  width: double.infinity,
                  padding: AppSpacing.allXXl,
                  decoration: BoxDecoration(
                    color: AppTheme.midnightNavy,
                    borderRadius: AppRadius.circularLg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.plotTitle(plot.plotNumber),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            AppSpacing.hXs,
                            Text(
                              context.l10n.residentialPlot,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.softGold),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: plot.status),
                    ],
                  ),
                ),
                AppSpacing.hXXl,

                // Specifications
                Text(
                  context.l10n.specifications,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                AppSpacing.hLg,
                GridView.count(
                  crossAxisCount: isDesktop ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 2.0,
                  children: [
                    _SpecBox(
                      title: loc.area,
                      value: context.l10n.sqFtLabel(
                        plot.sizeInSqFt.toStringAsFixed(0),
                      ),
                      icon: Icons.square_foot,
                    ),
                    _SpecBox(
                      title: loc.dimensions,
                      value: plot.dimensions,
                      icon: Icons.straighten,
                    ),
                    _SpecBox(
                      title: loc.facing,
                      value: plot.facing,
                      icon: Icons.explore_outlined,
                    ),
                    _SpecBox(
                      title: loc.roadWidth,
                      value: plot.roadWidth,
                      icon: Icons.add_road,
                    ),
                  ],
                ),
                AppSpacing.hXXl,

                // Pricing & Actions
                Container(
                  padding: AppSpacing.allLg,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.circularLg,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.l10n.totalPrice,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '₹${plot.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: AppTheme.midnightNavy),
                          ),
                        ],
                      ),
                      AppSpacing.hXXl,
                      PremiumButton(
                        text: context.l10n.enquireAboutPlot,
                        style: PremiumButtonStyle.outline,
                        onPressed: () => context.push(
                          '/home/enquiry?projectId=$projectId&plotId=${plot.id}',
                        ),
                      ),
                      AppSpacing.hMd,
                      PremiumButton(
                        text: isAvailable
                            ? context.l10n.proceedToPayment
                            : context.l10n.plotNotAvailable,
                        style: isAvailable
                            ? PremiumButtonStyle.primary
                            : PremiumButtonStyle.ghost,
                        onPressed: isAvailable
                            ? () => context.push(
                                '/home/payment'
                                '?refId=${plot.id}'
                                '&desc=Plot+${plot.plotNumber}'
                                '&amount=${(plot.price * 0.1).toStringAsFixed(0)}',
                              )
                            : null,
                      ),
                      if (!isAvailable) ...[
                        AppSpacing.hSm,
                        Text(
                          context.l10n.plotCurrentlyStatus(
                            plot.status == PlotStatus.hold
                                ? context.l10n.plotOnHold
                                : context.l10n.plotBookedSold,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SpecBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppRadius.circularMd,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.textSecondary),
              AppSpacing.wXs,
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.hXs,
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
