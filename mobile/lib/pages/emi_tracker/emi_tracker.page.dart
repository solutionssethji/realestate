import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../utils/l10n_extension.dart';
import 'emi_tracker.logic.dart';
import '../../widgets/shimmer_loader.dart';
import '../../theme/theme.dart';

class EmiTrackerPage extends ConsumerWidget {
  final String plotId;

  const EmiTrackerPage({super.key, required this.plotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emiTrackerLogicProvider(plotId));
    final l10n = context.l10n;
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    );

    if (state.isLoading) {
      return Scaffold(
        appBar: PremiumAppBar(title: l10n.emiAndPayments),
        body: const DetailPageSkeleton(),
      );
    }

    if (state.errorMessage != null) {
      return Scaffold(
        appBar: PremiumAppBar(title: l10n.emiAndPayments),
        body: Center(child: Text(state.errorMessage!)),
      );
    }

    return Scaffold(
      appBar: PremiumAppBar(title: l10n.emiAndPayments),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.paymentSummary,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.totalAmount,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                currencyFormat.format(state.totalAmount),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.amountPaid,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              Text(
                                currencyFormat.format(state.paidAmount),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.pendingBalance,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                              Text(
                                currencyFormat.format(
                                  state.balance > 0 ? state.balance : 0,
                                ),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.paymentHistory,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Payments List
          if (state.payments.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(l10n.noPaymentRecords)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final p = state.payments[index];
                final amount = p['amount'] ?? 0;
                final mode = p['mode'] ?? 'Unknown';
                final dateStr = p['createdAt'] ?? '';
                final notes = p['notes'] ?? '';

                DateTime? date;
                if (dateStr.isNotEmpty) {
                  try {
                    date = DateTime.parse(dateStr);
                  } catch (_) {}
                }

                final dateFormatted = date != null
                    ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
                    : 'N/A';

                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.success,
                    child: Icon(Icons.check, color: AppTheme.white),
                  ),
                  title: Text(
                    currencyFormat.format(amount),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateFormatted),
                      if (notes.isNotEmpty)
                        Text(
                          context.l10n.paymentRef(notes.toString()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: Text(
                    mode,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }, childCount: state.payments.length),
            ),
        ],
      ),
    );
  }
}
