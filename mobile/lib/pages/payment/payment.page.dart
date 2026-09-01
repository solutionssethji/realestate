import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'payment.logic.dart';
import '../../models/payment_intent.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/premium_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../routes/app_routes.dart';

class PaymentPage extends HookConsumerWidget {
  final double amount;
  final String referenceId;
  final String description;

  const PaymentPage({
    super.key,
    required this.amount,
    required this.referenceId,
    required this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(paymentLogicProvider);
    final logic = ref.read(paymentLogicProvider.notifier);
    final bool isSuccess = state.status == PaymentStatus.success;
    final bool isFailed = state.status == PaymentStatus.failed;

    return Scaffold(
      appBar: PremiumAppBar(title: loc.secureCheckout),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView(
            padding: AppSpacing.allLg,
            children: [
              // Security Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.lock,
                    color: AppTheme.success,
                    size: 18,
                  ),
                  AppSpacing.wSm,
                  Text(
                    context.l10n.sslEncrypted,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: AppTheme.success),
                  ),
                ],
              ),
              AppSpacing.hXXl,

              // Order Summary Card
              Container(
                padding: AppSpacing.allLg,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: AppRadius.circularLg,
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.bookingSummary,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(height: 28),
                    _SummaryRow(label: loc.reference, value: referenceId),
                    AppSpacing.hMd,
                    _SummaryRow(label: loc.description, value: description),
                    AppSpacing.hMd,
                    _SummaryRow(
                      label: loc.paymentType,
                      value: context.l10n.advanceBooking,
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.totalPayable,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '₹${amount.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppTheme.midnightNavy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.hXXl,

              // Error Banner
              if (isFailed) ...[
                Container(
                  padding: AppSpacing.allMd,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.08),
                    borderRadius: AppRadius.circularMd,
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.error,
                        size: 20,
                      ),
                      AppSpacing.wSm,
                      Expanded(
                        child: Text(
                          state.errorMessage ?? context.l10n.paymentFailed,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Success View
              if (isSuccess) ...[
                Container(
                  padding: AppSpacing.allXXl,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.08),
                    borderRadius: AppRadius.circularLg,
                    border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.success,
                        size: 64,
                      ),
                      AppSpacing.hLg,
                      Text(
                        context.l10n.paymentSuccessful,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppTheme.success),
                      ),
                      AppSpacing.hSm,
                      Text(
                        context.l10n.bookingConfirmedMsg,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (state.currentIntent?.transactionId != null) ...[
                        AppSpacing.hMd,
                        Text(
                          'TXN: ${state.currentIntent!.transactionId}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                      AppSpacing.hXXl,
                      PremiumButton(
                        text: loc.backToHome,
                        onPressed: () => context.go(AppRoutes.home),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Pay Button
                PremiumButton(
                  text: context.l10n.payAmountSecurely(
                    amount.toStringAsFixed(0),
                  ),
                  isLoading: state.isLoading,
                  icon: LucideIcons.creditCard,
                  onPressed: state.isLoading
                      ? null
                      : () {
                          logic.initiatePayment(
                            amount: amount,
                            referenceId: referenceId,
                            description: description,
                          );
                        },
                ),
                if (isFailed) ...[
                  AppSpacing.hMd,
                  PremiumButton(
                    text: loc.tryAgain,
                    style: PremiumButtonStyle.outline,
                    onPressed: () {
                      logic.reset();
                    },
                  ),
                ],
                AppSpacing.hLg,
                Text(
                  context.l10n.termsAndCancellation,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
