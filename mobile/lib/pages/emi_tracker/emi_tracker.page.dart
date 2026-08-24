import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../utils/l10n_extension.dart';
import 'emi_tracker.logic.dart';

class EmiTrackerPage extends HookConsumerWidget {
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
        body: const Center(child: CircularProgressIndicator()),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.totalAmount,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                currencyFormat.format(state.totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.amountPaid,
                                style: const TextStyle(color: Colors.green),
                              ),
                              Text(
                                currencyFormat.format(state.paidAmount),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
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
                                style: const TextStyle(color: Colors.red),
                              ),
                              Text(
                                currencyFormat.format(
                                  state.balance > 0 ? state.balance : 0,
                                ),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text(
                    currencyFormat.format(amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateFormatted),
                      if (notes.isNotEmpty)
                        Text(
                          context.l10n.paymentRef(notes.toString()),
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Text(
                    mode,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }, childCount: state.payments.length),
            ),
        ],
      ),
    );
  }
}
