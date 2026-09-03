import 'package:customer_app/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../utils/l10n_extension.dart';
import 'booking_details.logic.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/empty_state.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/premium_app_bar.dart';
import '../../services/payment_receipt_service.dart';

class BookingDetailsPage extends HookConsumerWidget {
  final String plotId;

  const BookingDetailsPage({super.key, required this.plotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingDetailsLogicProvider(plotId));
    final logic = ref.watch(bookingDetailsLogicProvider(plotId).notifier);
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final bookingData = state.bookingData ?? {};

    Widget buildBody() {
      if (state.isLoading) {
        return const _BookingDetailsSkeleton();
      }

      if (state.errorMessage != null) {
        return ErrorState(
          message: state.errorMessage,
          onRetry: () async {
            await logic.loadPlotDetails(plotId);
            logic.listenToPayments(plotId);
          },
        );
      }

      if (bookingData.isEmpty) {
        return Center(
          child: EmptyState(
            icon: Icons.article_outlined,
            title: l10n.noDetailsFound,
            message: l10n.noBookingDetailsMsg,
          ),
        );
      }

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.allLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Property Info Card ────────────────────────────────────
                  _InfoCard(
                    child: Row(
                      children: [
                        _IconBox(icon: Icons.bookmark_outline),
                        AppSpacing.wLg,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookingData['projectName']?.toString() ??
                                    l10n.naLabel,
                                style: tt.titleLarge?.copyWith(
                                  color: AppTheme.midnightNavy,
                                ),
                              ),
                              AppSpacing.hXs,
                              Text(
                                l10n.plotLabel(
                                  bookingData['plotNumber']?.toString() ??
                                      l10n.naLabel,
                                ),
                                style: tt.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusChip(
                          label: _translateStatus(
                              context,
                              bookingData['status']?.toString() ?? l10n.naLabel),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.hLg,

                  // ── Applicant Info Card ───────────────────────────────────
                  _InfoCard(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _IconBox(icon: Icons.person_outline),
                            AppSpacing.wLg,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookingData['firstApplicantName']
                                            ?.toString() ??
                                        l10n.naLabel,
                                    style: tt.titleLarge?.copyWith(
                                      color: AppTheme.midnightNavy,
                                    ),
                                  ),
                                  AppSpacing.hXs,
                                  Text(
                                    bookingData['firstApplicantMobile']
                                            ?.toString() ??
                                        l10n.naLabel,
                                    style: tt.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.bookingDate,
                              style: tt.labelSmall?.copyWith(
                                color: AppTheme.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _formatDate(bookingData['createdAt'], locale),
                              style: tt.titleSmall?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.hLg,

                  // ── Payment & EMI Tracking Card ───────────────────────────
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Header
                        Row(
                          children: [
                            const Icon(
                              Icons.payment_outlined,
                              color: AppTheme.midnightNavy,
                              size: 20,
                            ),
                            AppSpacing.wSm,
                            Text(
                              l10n.paymentEmiTracking,
                              style: tt.titleMedium?.copyWith(
                                color: AppTheme.midnightNavy,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.hXXl,

                        // Summary Boxes
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final boxes = [
                              _SummaryBox(
                                label: l10n.totalAmount,
                                value: currencyFormat.format(state.totalAmount),
                                bgColor: AppTheme.neutral50,
                                valueColor: AppTheme.midnightNavy,
                              ),
                              _SummaryBox(
                                label: l10n.paidAmount,
                                value: currencyFormat.format(state.paidAmount),
                                bgColor: const Color(0xFFF0FFF4),
                                valueColor: AppColors.success,
                              ),
                              _SummaryBox(
                                label: l10n.pendingBalance,
                                value: currencyFormat.format(
                                  state.balance > 0 ? state.balance : 0,
                                ),
                                bgColor: const Color(0xFFFFF5F5),
                                valueColor: AppTheme.error,
                              ),
                            ];

                            if (constraints.maxWidth < 500) {
                              return Column(
                                children: [
                                  boxes[0],
                                  AppSpacing.hMd,
                                  boxes[1],
                                  AppSpacing.hMd,
                                  boxes[2],
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: boxes[0]),
                                AppSpacing.wMd,
                                Expanded(child: boxes[1]),
                                AppSpacing.wMd,
                                Expanded(child: boxes[2]),
                              ],
                            );
                          },
                        ),

                        AppSpacing.hSection,

                        // Ledger Header
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.lg,
                          runSpacing: AppSpacing.md,
                          children: [
                            Text(
                              l10n.recentPaymentsLedger,
                              style: tt.titleSmall?.copyWith(
                                color: AppTheme.midnightNavy,
                              ),
                            ),
                            if (state.payments.isNotEmpty)
                              Row(
                                spacing: AppSpacing.sm,
                                children: [
                                  Expanded(
                                    child: _LedgerButton(
                                      icon: Icons.visibility_outlined,
                                      label: l10n.viewAll,
                                      onPressed: () {
                                        PaymentReceiptService.viewAll(
                                          bookingData,
                                          state.payments,
                                        );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: _LedgerButton(
                                      icon: Icons.file_download_outlined,
                                      label: l10n.downloadAll,
                                      onPressed: () {
                                        PaymentReceiptService.downloadAll(
                                          bookingData,
                                          state.payments,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        AppSpacing.hLg,

                        // Payments List
                        if (state.payments.isEmpty)
                          Padding(
                            padding: AppSpacing.verticalLg,
                            child: Center(
                              child: Text(
                                l10n.noPaymentRecords,
                                style: tt.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: state.payments.map((p) {
                              final amount = p['amount'] ?? 0;
                              final dateStr = p['createdAt'] ?? '';
                              final mode = p['mode']?.toString() ?? '';
                              final txnId =
                                  p['transactionId']?.toString() ?? '';
                              final notes = p['notes']?.toString() ?? '';

                              String subtitle = mode.isNotEmpty
                                  ? _translateMode(context, mode)
                                  : l10n.paymentModeCash;
                              if (txnId.isNotEmpty) {
                                subtitle += ' (Txn: $txnId)';
                              }
                              if (notes.isNotEmpty) {
                                subtitle += ' - $notes';
                              }
                              if (mode.isEmpty &&
                                  txnId.isEmpty &&
                                  notes.isEmpty) {
                                subtitle = l10n.initialPaymentDesc;
                              }

                              DateTime? date;
                              if (dateStr.isNotEmpty) {
                                try {
                                  date = DateTime.parse(dateStr);
                                } catch (_) {}
                              }

                              final dateFormatted = date != null
                                  ? _formatDate(dateStr, locale)
                                  : l10n.naLabel;

                              return _PaymentRow(
                                amount: currencyFormat.format(amount),
                                subtitle: subtitle,
                                dateFormatted: dateFormatted,
                                statusLabel: l10n.paymentCompleted,
                                onView: () {
                                  PaymentReceiptService.view(bookingData, p);
                                },
                                onDownload: () {
                                  PaymentReceiptService.download(
                                    bookingData,
                                    p,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.largeSection),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.bookingDetailsTitle),
      backgroundColor: AppTheme.background,
      body: buildBody(),
    );
  }

  String _formatDate(dynamic raw, Locale locale) {
    if (raw == null || raw.toString().isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(raw.toString());
      if (locale.languageCode == 'hi') {
        // Hindi date format: day month year, time
        final months = [
          'जन', 'फ़र', 'मार्च', 'अप्र', 'मई', 'जून',
          'जुल', 'अग', 'सित', 'अक्ट', 'नव', 'दिस'
        ];
        final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
        final minute = date.minute.toString().padLeft(2, '0');
        final amPm = date.hour >= 12 ? 'PM' : 'AM';
        return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $amPm';
      }
      return DateFormat('MMM d, yyyy, h:mm a').format(date);
    } catch (_) {
      return raw.toString();
    }
  }

  String _translateStatus(BuildContext context, String status) {
    final l10n = context.l10n;
    switch (status.toUpperCase()) {
      case 'BOOKED':
        return l10n.booked.toUpperCase();
      case 'SOLD':
        return l10n.bookedSold.toUpperCase();
      case 'AVAILABLE':
        return l10n.available.toUpperCase();
      case 'HOLD':
        return l10n.hold.toUpperCase();
      default:
        return status.toUpperCase();
    }
  }

  String _translateMode(BuildContext context, String mode) {
    final l10n = context.l10n;
    switch (mode.toUpperCase()) {
      case 'CASH':
        return l10n.paymentModeCash;
      case 'UPI':
        return l10n.paymentModeUpi;
      case 'BANK_TRANSFER':
      case 'BANK TRANSFER':
        return l10n.paymentModeBankTransfer;
      case 'CHEQUE':
      case 'CHECK':
        return l10n.paymentModeCheque;
      case 'ONLINE':
        return l10n.paymentModeOnline;
      default:
        return mode;
    }
  }
}

// ── Reusable Sub-Widgets ──────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppRadius.circularMd,
        border: Border.all(color: AppTheme.border),
      ),
      padding: AppSpacing.allLg,
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppTheme.midnightNavy.withValues(alpha: 0.08),
        borderRadius: AppRadius.circularSm,
      ),
      child: Icon(icon, color: AppTheme.midnightNavy, size: 20),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.midnightNavy.withValues(alpha: 0.08),
        borderRadius: AppRadius.circularPill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.midnightNavy,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Color valueColor;

  const _SummaryBox({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.circularSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: valueColor.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          AppSpacing.hSm,
          Text(
            value,
            style: tt.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _LedgerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.midnightNavy,
        side: BorderSide(color: AppTheme.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        textStyle: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String amount;
  final String subtitle;
  final String dateFormatted;
  final String statusLabel;
  final VoidCallback onView;
  final VoidCallback onDownload;

  const _PaymentRow({
    required this.amount,
    required this.subtitle,
    required this.dateFormatted,
    required this.statusLabel,
    required this.onView,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: AppRadius.circularSm,
      ),
      padding: AppSpacing.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amount,
                      style: tt.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dateFormatted,
                    style: tt.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  AppSpacing.hSm,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: AppRadius.circularPill,
                    ),
                    child: Text(
                      statusLabel,
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: _LedgerButton(
                  icon: Icons.visibility_outlined,
                  label: l10n.view,
                  onPressed: onView,
                ),
              ),
              Expanded(
                child: _LedgerButton(
                  icon: Icons.file_download_outlined,
                  label: l10n.download,
                  onPressed: onDownload,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Skeleton ──────────────────────────────────────────────────────────

class _BookingDetailsSkeleton extends StatelessWidget {
  const _BookingDetailsSkeleton();

  Widget _card(double height) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppRadius.circularMd,
        border: Border.all(color: AppTheme.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.neutral200,
      highlightColor: AppTheme.neutral100,
      child: SingleChildScrollView(
        padding: AppSpacing.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_card(80), _card(120), _card(320)],
        ),
      ),
    );
  }
}
