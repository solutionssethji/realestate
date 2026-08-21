import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import 'payment_history.logic.dart';

class PaymentHistoryPage extends ConsumerWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(paymentHistoryLogicProvider);
    final userPhone =
        FirebaseAuth.instance.currentUser?.phoneNumber ??
        context.l10n.yourNumberAlt;

    return Scaffold(
      appBar: PremiumAppBar(
        title: loc.paymentHistory,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            tooltip: context.l10n.signOut,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/home');
              }
            },
          ),
        ],
      ),
      body: _buildBody(context, state, userPhone),
    );
  }

  Widget _buildBody(BuildContext context, state, String userPhone) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError) {
      return Center(
        child: Text(
          context.l10n.errorLoadingHistoryVerbose(state.errorMessage ?? 'Error'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.error),
        ),
      );
    }

    final payments = state.payments;

    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.receipt,
              size: 64,
              color: AppTheme.border,
            ),
            AppSpacing.hLg,
            Text(
              context.l10n.noPaymentsFoundFor(userPhone),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: AppSpacing.allMd,
      itemCount: payments.length,
      separatorBuilder: (_, __) => AppSpacing.hSm,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _PaymentCard(payment: payment);
      },
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    final status =
        payment['status']?.toString().toUpperCase() ??
        context.l10n.statusUnknown;
    final amount = payment['amount'] ?? 0;
    final description =
        payment['description']?.toString() ?? context.l10n.payment;
    final createdAtStr = payment['createdAt']?.toString();

    DateTime? date;
    if (createdAtStr != null) {
      date = DateTime.tryParse(createdAtStr);
    }

    final formattedDate = date != null
        ? DateFormat.yMMMd().add_jm().format(date)
        : context.l10n.unknownDate;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'SUCCESS':
        statusColor = AppTheme.success;
        statusIcon = LucideIcons.checkCircle2;
        break;
      case 'FAILED':
      case 'CANCELLED':
        statusColor = AppTheme.error;
        statusIcon = LucideIcons.xCircle;
        break;
      default:
        statusColor = AppTheme.warning;
        statusIcon = LucideIcons.clock;
    }

    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppRadius.circularMd,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '₹$amount',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          AppSpacing.hXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
