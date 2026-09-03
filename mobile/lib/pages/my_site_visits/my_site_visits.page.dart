import 'package:customer_app/theme/spacing.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/empty_state.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import '../../widgets/generic_shimmer_loader.dart';
import 'my_site_visits.logic.dart';

class MySiteVisitsPage extends HookConsumerWidget {
  const MySiteVisitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mySiteVisitsLogicProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.mySiteVisits),
      body: SafeArea(child: _buildBody(context, ref, state, l10n)),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, state, l10n) {
    if (state.isLoading) {
      return const ShimmerLoader();
    }

    if (state.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.section),
          child: Text(
            state.errorMessage ?? 'Error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      );
    }

    final visits = state.visits;
    if (visits.isEmpty) {
      return EmptyState(
        icon: LucideIcons.mapPin,
        title: context.l10n.noSiteVisitsScheduled,
        message: context.l10n.noSiteVisitsMessage,
        buttonText: null,
        onAction: null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(mySiteVisitsLogicProvider),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!state.isFetchingMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            ref.read(mySiteVisitsLogicProvider.notifier).loadMore();
          }
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: visits.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == visits.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final visit = visits[index];
            return _buildVisitCard(context, visit, l10n);
          },
        ),
      ),
    );
  }

  Widget _buildVisitCard(
    BuildContext context,
    Map<String, dynamic> visit,
    l10n,
  ) {
    final createdAt = visit['createdAt']?.toDate();
    final locale = Localizations.localeOf(context);
    final dateStr = createdAt != null
        ? formatDate(createdAt, locale)
        : context.l10n.unknownDate;
    final status = visit['status'] ?? 'NEW';
    final preferredDateStr = visit['preferredDate'];
    final preferredTime = visit['preferredTime'];

    String formattedPrefDate = context.l10n.unknownDate;
    if (preferredDateStr != null) {
      try {
        final dt = DateTime.parse(preferredDateStr);
        if (locale.languageCode == 'hi') {
          final months = [
            'जन',
            'फ़र',
            'मार्च',
            'अप्र',
            'मई',
            'जून',
            'जुल',
            'अग',
            'सित',
            'अक्ट',
            'नव',
            'दिस',
          ];
          formattedPrefDate =
              '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
        } else {
          formattedPrefDate = DateFormat('MMM dd, yyyy').format(dt);
        }
      } catch (_) {
        formattedPrefDate = preferredDateStr;
      }
    }

    final projectId = visit['projectId'];
    final plotId = visit['plotId'];
    final projectName = visit['projectName'];
    final plotName = visit['plotName'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: AppTheme.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Project Info + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.building,
                    size: 20,
                    color: AppTheme.midnightNavy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        projectId != null
                            ? (projectName ?? projectId)
                            : (plotId != null ? (plotName ?? plotId) : '—'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        projectId != null ? l10n.project : l10n.plot,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withValues(alpha: 0.1),
                    border: Border.all(
                      color: getStatusColor(status).withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    translateStatus(context, status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: getStatusColor(status),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppTheme.neutral200),
            ),
            // Details Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dateSubmitted.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutral500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.scheduledDate.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutral500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedPrefDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.scheduledTime.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutral500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preferredTime ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
