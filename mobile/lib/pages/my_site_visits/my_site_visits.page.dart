import 'package:customer_app/theme/spacing.dart';
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
        message:
            context.l10n.noSiteVisitsMessage,
        buttonText: null,
        onAction: null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(mySiteVisitsLogicProvider),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          return _buildVisitCard(context, visit, l10n);
        },
      ),
    );
  }

  Widget _buildVisitCard(
    BuildContext context,
    Map<String, dynamic> visit,
    l10n,
  ) {
    final createdAt = visit['createdAt']?.toDate();
    final dateStr = createdAt != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt)
        : context.l10n.unknownDate;
    final status = visit['status'] ?? 'NEW';
    final preferredDateStr = visit['preferredDate'];
    final preferredTime = visit['preferredTime'];

    String formattedPrefDate = 'Unknown';
    if (preferredDateStr != null) {
      try {
        final dt = DateTime.parse(preferredDateStr);
        formattedPrefDate = DateFormat('MMM dd, yyyy').format(dt);
      } catch (_) {
        formattedPrefDate = preferredDateStr;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(context, context.l10n.scheduledDate, formattedPrefDate),
            const SizedBox(height: 4),
            _buildDetailRow(
              context,
              context.l10n.scheduledTime,
              preferredTime ?? 'Unknown',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
        return AppTheme.info;
      case 'CONFIRMED':
      case 'COMPLETED':
        return AppTheme.success;
      case 'CANCELLED':
        return AppTheme.error;
      default:
        return AppTheme.midnightNavy;
    }
  }
}
