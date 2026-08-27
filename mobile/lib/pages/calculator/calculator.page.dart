import 'package:flutter/material.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'calculator.logic.dart';
import '../../utils/price_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';

class CalculatorPage extends HookConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(calculatorLogicProvider);
    final logic = ref.read(calculatorLogicProvider.notifier);

    final loanAmount = state.propertyPrice - state.downPayment;

    return Scaffold(
      appBar: PremiumAppBar(title: loc.emiCalculator),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Property Price
              _buildSliderRow(
                context,
                label: context.l10n.propertyPrice,
                displayValue: PriceFormatter.format(state.propertyPrice),
                sliderValue: state.propertyPrice,
                min: 500000,
                max: 50000000,
                divisions: 990,
                onChanged: (val) => logic.updatePropertyPrice(val),
              ),
              const SizedBox(height: 24),

              // Down Payment
              _buildSliderRow(
                context,
                label: context.l10n.downPayment,
                displayValue: PriceFormatter.format(state.downPayment),
                sliderValue: state.downPayment,
                min: 0,
                max: state.propertyPrice,
                divisions: 100,
                onChanged: (val) => logic.updateDownPayment(val),
              ),

              const Divider(height: 48),
              Text(
                context.l10n.loanDetails,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Interest Rate
              _buildSliderRow(
                context,
                label: context.l10n.interestRate,
                displayValue: '${state.interestRate.toStringAsFixed(2)} %',
                sliderValue: state.interestRate,
                min: 5.0,
                max: 15.0,
                divisions: 100,
                onChanged: logic.updateInterestRate,
              ),

              const SizedBox(height: 16),

              // Tenure
              _buildSliderRow(
                context,
                label: context.l10n.loanTenure,
                displayValue: context.l10n.years(state.tenureYears),
                sliderValue: state.tenureYears.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                onChanged: (val) => logic.updateTenure(val.toInt()),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow(
    BuildContext context, {
    required String label,
    required String displayValue,
    required double sliderValue,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Slider(
          value: sliderValue.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions > 0 ? divisions : 1,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
