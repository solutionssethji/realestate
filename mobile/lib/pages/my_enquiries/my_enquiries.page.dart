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
        message:
            context.l10n.noEnquiriesMessage,
        buttonText: null,
        onAction: null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myEnquiriesLogicProvider),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: enquiries.length,
        itemBuilder: (context, index) {
          final enquiry = enquiries[index];
          return _buildEnquiryCard(context, enquiry, l10n);
        },
      ),
    );
  }

  Widget _buildEnquiryCard(
    BuildContext context,
    Map<String, dynamic> enquiry,
    l10n,
  ) {
    final createdAt = enquiry['createdAt']?.toDate();
    final dateStr = createdAt != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt)
        : context.l10n.unknownDate;
    final status = enquiry['status'] ?? 'NEW';
    final plotReq = enquiry['plotRequirement'];
    final budget = enquiry['budget'];
    final message = enquiry['message'];

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
            if (plotReq != null && plotReq.toString().isNotEmpty) ...[
              _buildDetailRow(context, context.l10n.requirementLabel, plotReq),
              const SizedBox(height: 4),
            ],
            if (budget != null && budget.toString().isNotEmpty) ...[
              _buildDetailRow(context, context.l10n.budgetLabel, budget),
              const SizedBox(height: 4),
            ],
            if (message != null && message.toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.messageLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
            ],
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
          width: 100,
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
      case 'IN_PROGRESS':
        return AppTheme.warning;
      case 'RESOLVED':
      case 'COMPLETED':
        return AppTheme.success;
      case 'CLOSED':
        return AppTheme.textSecondary;
      default:
        return AppTheme.midnightNavy;
    }
  }
}
