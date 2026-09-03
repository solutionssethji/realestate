import 'package:customer_app/theme/spacing.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:customer_app/widgets/empty_state.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../utils/l10n_extension.dart';
import '../../theme/theme.dart';
import '../../widgets/generic_shimmer_loader.dart';
import 'my_enquiries.logic.dart';

class MyEnquiriesPage extends HookConsumerWidget {
  const MyEnquiriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myEnquiriesLogicProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.myEnquiries),
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

    final enquiries = state.enquiries;
    if (enquiries.isEmpty) {
      return EmptyState(
        icon: LucideIcons.inbox,
        title: context.l10n.noEnquiriesYet,
        message: context.l10n.noEnquiriesMessage,
        buttonText: null,
        onAction: null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myEnquiriesLogicProvider),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!state.isFetchingMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            ref.read(myEnquiriesLogicProvider.notifier).loadMore();
          }
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: enquiries.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == enquiries.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final enquiry = enquiries[index];
            return _buildEnquiryCard(context, enquiry, l10n);
          },
        ),
      ),
    );
  }

  Widget _buildEnquiryCard(
    BuildContext context,
    Map<String, dynamic> enquiry,
    l10n,
  ) {
    final createdAt = enquiry['createdAt']?.toDate();
    final locale = Localizations.localeOf(context);
    final dateStr = createdAt != null
        ? formatDate(createdAt, locale)
        : context.l10n.unknownDate;
    final status = enquiry['status'] ?? 'NEW';
    final plotReq = enquiry['plotRequirement'];
    final budget = enquiry['budget'];
    final message = enquiry['message'];
    final projectId = enquiry['projectId'];
    final plotId = enquiry['plotId'];
    final projectName = enquiry['projectName'];
    final plotName = enquiry['plotName'];

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
                            : (plotId != null
                                  ? (plotName != null
                                        ? l10n.plotTitle(plotName)
                                        : plotId)
                                  : l10n.generalEnquiry),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Show plot name as subtitle if both projectId and plotId exist
                      if (plotId != null &&
                          projectId != null &&
                          plotName != null)
                        Text(
                          l10n.plotTitle(plotName),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.midnightNavy,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      else
                        Text(
                          projectId != null
                              ? l10n.project
                              : (plotId != null ? l10n.plot : l10n.support),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppTheme.neutral500),
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
                        l10n.dateLabel.toUpperCase(),
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
            if (budget != null && budget.toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (plotReq != null && plotReq.toString().isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.plotRequirement.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neutral500,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plotReq.toString(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.budget.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neutral500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.inrPrice(budget.toString()),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (message != null && message.toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.message.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neutral500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
