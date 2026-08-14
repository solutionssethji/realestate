import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'calculator.logic.dart';
import '../../../utils/price_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';

class CalculatorPage extends HookConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(calculatorLogicProvider);
    final logic = ref.read(calculatorLogicProvider.notifier);

    // Form controllers for direct input
    final priceCtrl = useTextEditingController(
      text: state.propertyPrice.toInt().toString(),
    );
    final dpCtrl = useTextEditingController(
      text: state.downPayment.toInt().toString(),
    );

    final loanAmount = state.propertyPrice - state.downPayment;

    return Scaffold(
      appBar: PremiumAppBar(title: loc.emiCalculator),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    context.l10n.estimatedMonthlyEmi,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    PriceFormatter.format(state.estimatedEMI),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.principalAmount,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            PriceFormatter.format(loanAmount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.l10n.totalInterest,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            PriceFormatter.format(state.totalInterest),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Inputs
            Text(
              context.l10n.propertyDetails,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Property Price
            _buildSliderInput(
              context,
              label: context.l10n.propertyPrice,
              value: state.propertyPrice,
              min: 1000000,
              max: 50000000,
              divisions: 490,
              controller: priceCtrl,
              onChanged: (val) {
                logic.updatePropertyPrice(val);
                priceCtrl.text = val.toInt().toString();
                // update dpCtrl if it got auto-adjusted
                dpCtrl.text = ref
                    .read(calculatorLogicProvider)
                    .downPayment
                    .toInt()
                    .toString();
              },
              onSubmitted: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) logic.updatePropertyPrice(parsed);
              },
            ),
            const SizedBox(height: 24),

            // Down Payment
            _buildSliderInput(
              context,
              label: context.l10n.downPayment,
              value: state.downPayment,
              min: 0,
              max: state.propertyPrice,
              divisions: 100,
              controller: dpCtrl,
              onChanged: (val) {
                logic.updateDownPayment(val);
                dpCtrl.text = val.toInt().toString();
              },
              onSubmitted: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) logic.updateDownPayment(parsed);
              },
            ),

            const Divider(height: 48),
            Text(
              context.l10n.loanDetails,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Interest Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.interestRate,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${state.interestRate.toStringAsFixed(2)} %',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Slider(
              value: state.interestRate,
              min: 5.0,
              max: 15.0,
              divisions: 100,
              onChanged: logic.updateInterestRate,
            ),

            const SizedBox(height: 16),

            // Tenure
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.loanTenure,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${state.tenureYears} ${context.l10n.years}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Slider(
              value: state.tenureYears.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              onChanged: (val) => logic.updateTenure(val.toInt()),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderInput(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required TextEditingController controller,
    required ValueChanged<double> onChanged,
    required ValueChanged<String> onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(
              width: 120,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions > 0 ? divisions : 1,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
